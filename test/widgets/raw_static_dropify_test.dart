import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dropify_flutter/dropify_flutter.dart';
import '../helpers/dropify_test_app.dart';

void main() {
  final entries = const [
    DropifyEntry(value: 'apple', label: 'Apple'),
    DropifyEntry(value: 'banana', label: 'Banana'),
    DropifyEntry(value: 'cherry', label: 'Cherry'),
  ];

  group('RawStaticDropify', () {
    testWidgets('renders entries in panel', (tester) async {
      await DropifyTestApp.pump(
        tester,
        RawStaticDropify<String>(
          entries: entries,
          anchorBuilder: (context, state) => const Text('Open'),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('selects entry and closes', (tester) async {
      String? selected;
      await DropifyTestApp.pump(
        tester,
        RawStaticDropify<String>(
          entries: entries,
          onChanged: (v) => selected = v,
          anchorBuilder: (context, state) => const Text('Open'),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      expect(selected, 'banana');
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('search filters entries', (tester) async {
      await DropifyTestApp.pump(
        tester,
        RawStaticDropify<String>(
          entries: entries,
          searchable: true,
          anchorBuilder: (context, state) => const Text('Open'),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Ban');
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsNothing);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsNothing);
    });

    testWidgets('opens large lazy lists without intrinsic layout errors', (
      tester,
    ) async {
      final manyEntries = List<DropifyEntry<String>>.generate(
        60,
        (index) => DropifyEntry(value: 'item-$index', label: 'Item $index'),
      );

      await DropifyTestApp.pump(
        tester,
        RawStaticDropify<String>(
          entries: manyEntries,
          anchorBuilder: (context, state) {
            return const SizedBox(width: 180, height: 40, child: Text('Open'));
          },
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Item 0'), findsOneWidget);
      expect(tester.getSize(find.byKey(const Key('dropify.panel'))).width, 180);
    });

    testWidgets('uses fallback panel width when anchor width matching is off', (
      tester,
    ) async {
      await DropifyTestApp.pump(
        tester,
        RawStaticDropify<String>(
          entries: entries,
          matchAnchorWidth: false,
          anchorBuilder: (context, state) {
            return const SizedBox(width: 180, height: 40, child: Text('Open'));
          },
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byKey(const Key('dropify.panel'))).width, 240);
    });

    testWidgets('disabled entry is not selectable', (tester) async {
      final entriesWithDisabled = [
        const DropifyEntry(value: 'a', label: 'A'),
        const DropifyEntry(value: 'b', label: 'B', enabled: false),
        const DropifyEntry(value: 'c', label: 'C'),
      ];

      String? selected;
      await DropifyTestApp.pump(
        tester,
        RawStaticDropify<String>(
          entries: entriesWithDisabled,
          onChanged: (v) => selected = v,
          anchorBuilder: (context, state) => const Text('Open'),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('B'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(selected, isNull);
    });
  });
}
