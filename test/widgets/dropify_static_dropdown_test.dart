import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('default anchor uses Material InputDecorator chrome', (
    tester,
  ) async {
    await tester.pumpWidget(
      dropifyTestApp(
        const SizedBox(
          width: 280,
          child: DropifyDropdown<String>(
            entries: fruitEntries,
            label: 'Fruit',
            hintText: 'Pick fruit',
            helperText: 'Choose one fruit',
            prefixIcon: Icon(Icons.local_grocery_store),
            itemLabelBuilder: _fruitLabel,
          ),
        ),
      ),
    );

    final inputDecorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(inputDecorator.decoration.labelText, 'Fruit');
    expect(inputDecorator.decoration.hintText, 'Pick fruit');
    expect(inputDecorator.decoration.helperText, 'Choose one fruit');
    expect(inputDecorator.decoration.prefixIcon, isA<Icon>());
    expect(inputDecorator.isEmpty, isTrue);

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();

    final selectedDecorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(selectedDecorator.isEmpty, isFalse);
    expect(find.text('Banana'), findsOneWidget);
  });

  testWidgets('default anchor applies anchor decoration theme', (tester) async {
    const fillColor = Color(0xfff1e6ff);

    await tester.pumpWidget(
      dropifyTestApp(
        DropifyTheme(
          data: const DropifyThemeData(
            anchorDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: fillColor,
              contentPadding: EdgeInsets.all(24),
            ),
          ),
          child: const SizedBox(
            width: 280,
            child: DropifyDropdown<String>(
              entries: fruitEntries,
              hintText: 'Pick fruit',
            ),
          ),
        ),
      ),
    );

    final inputDecorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(inputDecorator.decoration.filled, isTrue);
    expect(inputDecorator.decoration.fillColor, fillColor);
    expect(inputDecorator.decoration.contentPadding, const EdgeInsets.all(24));
  });

  testWidgets('default anchor renders validation and clear affordance', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    String? selected = 'apple';

    await tester.pumpWidget(
      dropifyTestApp(
        Form(
          key: formKey,
          child: SizedBox(
            width: 280,
            child: DropifyDropdown<String>(
              entries: fruitEntries,
              initialValue: 'apple',
              showClearButton: true,
              itemLabelBuilder: _fruitLabel,
              onChanged: (value) => selected = value,
              validator: (value) =>
                  value is DropifySingleValue<String> && value.value == null
                  ? 'Required'
                  : null,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Apple'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('dropify.anchor.clear')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('dropify.anchor.clear')),
    );
    await tester.pumpAndSettle();

    expect(selected, isNull);
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    final inputDecorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(inputDecorator.decoration.error, isA<Text>());
    expect(
      find.byKey(const ValueKey<String>('dropify.validation.error')),
      findsOneWidget,
    );
  });

  testWidgets('disabled default anchor does not open panel', (tester) async {
    await tester.pumpWidget(
      dropifyTestApp(
        const SizedBox(
          width: 280,
          child: DropifyDropdown<String>(
            entries: fruitEntries,
            hintText: 'Pick fruit',
            enabled: false,
          ),
        ),
      ),
    );

    final inputDecorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(inputDecorator.decoration.enabled, isFalse);

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('dropify.panel')), findsNothing);
  });

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

  testWidgets(
    'confirmable multi-select cancel, outside tap, Escape, and apply',
    (tester) async {
      Set<String>? selected;

      await tester.pumpWidget(
        dropifyTestApp(
          DropifyDropdown<String>.multi(
            entries: fruitEntries,
            hintText: 'Pick fruit',
            confirmable: true,
            itemLabelBuilder: _fruitLabel,
            onChanged: (values) => selected = values,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('dropify.multi.cancel')),
      );
      await tester.pumpAndSettle();
      expect(selected, isNull);
      expect(find.byKey(const ValueKey<String>('dropify.panel')), findsNothing);

      await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(790, 590));
      await tester.pumpAndSettle();
      expect(selected, isNull);

      await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(selected, isNull);

      await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('dropify.multi.apply')),
      );
      await tester.pumpAndSettle();

      expect(selected, {'apple'});
      expect(find.byKey(const ValueKey<String>('dropify.panel')), findsNothing);
    },
  );

  testWidgets('static selection identity honors keyOf and equals', (
    tester,
  ) async {
    final initial = _TestFruit(1, 'Initial apple');
    _TestFruit? selected;

    await tester.pumpWidget(
      dropifyTestApp(
        RawStaticDropify<_TestFruit>(
          entries: const [
            DropifyEntry(value: _TestFruit(1, 'Apple'), label: 'Apple'),
            DropifyEntry(value: _TestFruit(2, 'Banana'), label: 'Banana'),
          ],
          initialValue: initial,
          keyOf: (item) => item.id,
          equals: (a, b) => a.id == b.id,
          onChanged: (value) => selected = value,
          anchorBuilder: (context, state) => TextButton(
            key: const ValueKey<String>('dropify.anchor'),
            onPressed: state.open,
            child: Text(state.value?.label ?? 'Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('dropify.item.selectedIcon')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('dropify.item.1')),
      findsOneWidget,
    );

    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();

    expect(selected?.id, 2);
  });

  testWidgets('overlay placement clamps, offsets, max height, and width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 120,
              child: RawDropify<String>(
                initialValue: 'value',
                alignmentOffset: const Offset(12, 8),
                panelConstraints: const BoxConstraints(maxHeight: 80),
                anchorBuilder: _rawAnchorBuilder,
                panelBuilder: _largePanelBuilder,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();

    final anchorRect = tester.getRect(
      find.byKey(const ValueKey<String>('dropify.anchor')),
    );
    final panelRect = tester.getRect(
      find.byKey(const ValueKey<String>('dropify.panel')),
    );
    expect(panelRect.left, anchorRect.left + 12);
    expect(panelRect.top, anchorRect.bottom + 8);
    expect(panelRect.width, anchorRect.width);
    expect(panelRect.height, lessThanOrEqualTo(80));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: 160,
              child: RawDropify<String>(
                initialValue: 'value',
                alignmentOffset: const Offset(40, 4),
                panelConstraints: const BoxConstraints(maxHeight: 120),
                anchorBuilder: _rawAnchorBuilder,
                panelBuilder: _largePanelBuilder,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();

    final bottomAnchorRect = tester.getRect(
      find.byKey(const ValueKey<String>('dropify.anchor')),
    );
    final bottomPanelRect = tester.getRect(
      find.byKey(const ValueKey<String>('dropify.panel')),
    );
    expect(bottomPanelRect.left, greaterThanOrEqualTo(0));
    expect(bottomPanelRect.right, lessThanOrEqualTo(800));
    expect(bottomPanelRect.bottom, lessThanOrEqualTo(bottomAnchorRect.top));
  });
}

@immutable
class _TestFruit {
  const _TestFruit(this.id, this.label);

  final int id;
  final String label;
}

Widget _rawAnchorBuilder(
  BuildContext context,
  DropifyAnchorState<String> state,
) {
  return TextButton(
    key: const ValueKey<String>('dropify.anchor'),
    onPressed: state.open,
    child: const Text('Open'),
  );
}

Widget _largePanelBuilder(
  BuildContext context,
  DropifyPanelState<String> state,
) {
  return const SizedBox(width: 240, height: 240, child: Text('Panel body'));
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
