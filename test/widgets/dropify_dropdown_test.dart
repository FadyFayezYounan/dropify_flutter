import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const List<DropifyEntry<String>> _entries = <DropifyEntry<String>>[
  DropifyEntry<String>(value: 'apple', label: 'Apple'),
  DropifyEntry<String>(value: 'banana', label: 'Banana'),
  DropifyEntry<String>(value: 'disabled', label: 'Disabled', enabled: false),
];

void main() {
  testWidgets('static single selection updates value callback and closes', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyDropdown<String>(
            entries: _entries,
            label: 'Fruit',
            hintText: 'Choose fruit',
            onChanged: (String? value) {
              selected = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(DropifyKeys.row('banana')));
    await tester.pumpAndSettle();

    expect(selected, 'banana');
    expect(find.text('Banana'), findsOneWidget);
    expect(find.byKey(DropifyKeys.panel), findsNothing);
  });

  testWidgets(
    'static multi chips update and enforce min max while staying open',
    (tester) async {
      const List<DropifyEntry<String>> entries = <DropifyEntry<String>>[
        ..._entries,
        DropifyEntry<String>(value: 'cherry', label: 'Cherry'),
      ];
      final DropifyController<String> controller =
          DropifyController<String>.multi(
            initialValues: <String>['apple'],
            minSelection: 1,
            maxSelection: 2,
          );
      List<String> selected = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropifyDropdown<String>.multi(
              controller: controller,
              entries: entries,
              label: 'Fruit',
              hintText: 'Choose fruits',
              onChanged: (List<String> values) {
                selected = values;
              },
            ),
          ),
        ),
      );

      expect(find.byKey(DropifyKeys.chip('apple')), findsOneWidget);

      await tester.tap(find.byKey(DropifyKeys.anchor));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(DropifyKeys.row('banana')));
      await tester.pumpAndSettle();

      expect(selected, <String>['apple', 'banana']);
      expect(find.byKey(DropifyKeys.panel), findsOneWidget);

      await tester.tap(find.byKey(DropifyKeys.row('cherry')));
      await tester.pumpAndSettle();

      expect(selected, <String>['apple', 'banana']);
      expect(
        controller.lastRejectionReason,
        DropifySelectionRejectionReason.maxSelectionViolated,
      );

      await tester.tap(find.byKey(DropifyKeys.row('banana')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(DropifyKeys.row('apple')));
      await tester.pumpAndSettle();

      expect(controller.multiValues, <String>['apple']);
      expect(
        controller.lastRejectionReason,
        DropifySelectionRejectionReason.minSelectionViolated,
      );
    },
  );

  testWidgets('search disabled hides search while selection still works', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyDropdown<String>(
            entries: _entries,
            searchEnabled: false,
            onChanged: (String? value) {
              selected = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pumpAndSettle();

    expect(find.byKey(DropifyKeys.searchField), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(selected, 'apple');
  });

  testWidgets('long chips and constrained panel avoid layout exceptions', (
    tester,
  ) async {
    final DropifyController<String> controller =
        DropifyController<String>.multi(
          initialValues: <String>['very-long-value'],
        );
    final List<DropifyEntry<String>> longEntries = <DropifyEntry<String>>[
      const DropifyEntry<String>(
        value: 'very-long-value',
        label: 'A very long selected label that should wrap without overflow',
      ),
      ..._entries,
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            child: DropifyDropdown<String>.multi(
              controller: controller,
              entries: longEntries,
              theme: DropifyThemeData.light().copyWith(panelMaxHeight: 180),
            ),
          ),
        ),
      ),
    );

    controller.open();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(DropifyKeys.panel), findsOneWidget);
  });
}
