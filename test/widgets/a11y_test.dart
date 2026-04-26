import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const List<DropifyEntry<String>> _entries = <DropifyEntry<String>>[
  DropifyEntry<String>(value: 'apple', label: 'Apple'),
  DropifyEntry<String>(value: 'banana', label: 'Banana'),
  DropifyEntry<String>(value: 'disabled', label: 'Disabled', enabled: false),
];

void main() {
  testWidgets('anchor and search field expose useful semantics', (
    tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    addTearDown(handle.dispose);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DropifyDropdown<String>(
            entries: _entries,
            label: 'Fruit',
            hintText: 'Choose fruit',
            searchHint: 'Search fruit',
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byKey(DropifyKeys.anchor)),
      matchesSemantics(
        label: 'Fruit',
        value: 'Choose fruit',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        isExpanded: false,
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byKey(DropifyKeys.anchor)),
      matchesSemantics(
        label: 'Fruit',
        value: 'Choose fruit',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        isExpanded: true,
      ),
    );
    expect(
      tester.getSemantics(find.byKey(DropifyKeys.searchField)),
      matchesSemantics(
        label: 'Search fruit',
        isTextField: true,
        hasEnabledState: true,
        isEnabled: true,
      ),
    );
  });

  testWidgets('rows expose selected and disabled semantics', (tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    addTearDown(handle.dispose);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DropifyDropdown<String>(
            entries: _entries,
            initialValue: 'banana',
            searchEnabled: false,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byKey(DropifyKeys.row('banana'))),
      matchesSemantics(
        isButton: true,
        isSelected: true,
        hasEnabledState: true,
        isEnabled: true,
      ),
    );
    expect(
      tester.getSemantics(find.byKey(DropifyKeys.row('disabled'))),
      matchesSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );
  });
}
