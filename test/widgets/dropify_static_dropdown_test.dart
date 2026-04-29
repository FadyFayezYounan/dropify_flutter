import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/dropify_fixtures.dart';
import '../helpers/dropify_test_app.dart';

void main() {
  testWidgets(
    'searchable static dropdown opens Material panel, scrolls rows, selects, and closes',
    (tester) async {
      String? selected;

      await tester.pumpWidget(
        dropifyTestApp(
          DropifyDropdown<String>(
            entries: fruitEntries,
            hintText: 'Pick fruit',
            searchable: true,
            itemLabelBuilder: _fruitLabel,
            onChanged: (value) => selected = value,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
      await tester.pumpAndSettle();

      final panel = find.byKey(const ValueKey<String>('dropify.panel'));
      expect(panel, findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('dropify.search.field')),
        findsOneWidget,
      );
      expect(find.byType(Scrollbar), findsOneWidget);

      final material = tester.widget<Material>(
        find.ancestor(of: panel, matching: find.byType(Material)).first,
      );
      expect(material.type, isNot(MaterialType.transparency));
      expect(material.elevation, greaterThan(0));

      expect(find.text('Apple'), findsOneWidget);
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      expect(selected, 'banana');
      expect(panel, findsNothing);
      expect(find.text('Banana'), findsOneWidget);
    },
  );

  testWidgets('static rows choose eager or lazy body from filtered count', (
    tester,
  ) async {
    await _pumpRawStaticDropdown(tester, entries: _numberedEntries(50));
    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(ListView), findsNothing);

    await _pumpRawStaticDropdown(tester, entries: _numberedEntries(51));
    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();

    final listView = tester.widget<ListView>(find.byType(ListView));
    expect(listView.shrinkWrap, isFalse);

    await _pumpRawStaticDropdown(
      tester,
      entries: _numberedEntries(100),
      matcher: (entry, query) =>
          entry.value == 'Item 0' || entry.value == 'Item 1',
    );
    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsNothing);
  });

  testWidgets('static disabled and selected rows keep semantics and behavior', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      dropifyTestApp(
        SizedBox(
          width: 240,
          child: RawStaticDropify<String>(
            entries: fruitEntries,
            initialValue: 'apple',
            onChanged: (value) => selected = value,
            anchorBuilder: (context, state) => TextButton(
              key: const ValueKey<String>('dropify.anchor'),
              onPressed: state.open,
              child: Text(state.value ?? 'Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Apple' &&
            widget.properties.selected == true,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Disabled' &&
            widget.properties.enabled == false,
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Disabled'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(selected, isNull);
    expect(find.byKey(const ValueKey<String>('dropify.panel')), findsOneWidget);
  });
}

Future<void> _pumpRawStaticDropdown(
  WidgetTester tester, {
  required List<DropifyEntry<String>> entries,
  bool Function(DropifyEntry<String> entry, String query)? matcher,
}) async {
  await tester.pumpWidget(
    dropifyTestApp(
      SizedBox(
        width: 240,
        child: RawStaticDropify<String>(
          entries: entries,
          matcher: matcher,
          anchorBuilder: (context, state) => TextButton(
            key: const ValueKey<String>('dropify.anchor'),
            onPressed: state.open,
            child: Text(state.value ?? 'Open'),
          ),
          panelConstraints: const BoxConstraints(maxHeight: 120),
        ),
      ),
    ),
  );
}

List<DropifyEntry<String>> _numberedEntries(int count) {
  return [
    for (var index = 0; index < count; index++)
      DropifyEntry(value: 'Item $index'),
  ];
}

String _fruitLabel(String value) {
  return switch (value) {
    'apple' => 'Apple',
    'banana' => 'Banana',
    'disabled' => 'Disabled',
    _ => value,
  };
}
