import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dropify_flutter/dropify_flutter.dart';
import '../helpers/dropify_test_app.dart';

void main() {
  group('RawDropify anchor', () {
    testWidgets('renders anchor builder widget', (tester) async {
      await DropifyTestApp.pump(
        tester,
        RawDropify<String>(
          anchorBuilder: (context, state) => const Text('Tap me'),
          panelBuilder: (context, state) => const Text('Panel'),
        ),
      );

      expect(find.text('Tap me'), findsOneWidget);
      expect(find.text('Panel'), findsNothing);
    });

    testWidgets('opens panel on anchor tap', (tester) async {
      await DropifyTestApp.pump(
        tester,
        RawDropify<String>(
          anchorBuilder: (context, state) => const Text('Tap me'),
          panelBuilder: (context, state) => const Text('Panel content'),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();

      expect(find.text('Panel content'), findsOneWidget);
    });

    testWidgets('disabled anchor does not open', (tester) async {
      await DropifyTestApp.pump(
        tester,
        RawDropify<String>(
          enabled: false,
          anchorBuilder: (context, state) => const Text('Tap me'),
          panelBuilder: (context, state) => const Text('Panel content'),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();

      expect(find.text('Panel content'), findsNothing);
    });
  });

  group('RawDropify selection', () {
    testWidgets('single select updates value', (tester) async {
      String? selected;
      await DropifyTestApp.pump(
        tester,
        RawDropify<String>(
          initialValue: null,
          onChanged: (v) => selected = v,
          anchorBuilder: (context, state) {
            if (state.isOpen) {
              return const Text('Open');
            }
            return Text(state.value ?? 'None');
          },
          panelBuilder: (context, state) {
            return InkWell(
              onTap: () => state.select('Apple'),
              child: const Text('Apple'),
            );
          },
        ),
      );

      await tester.tap(find.text('None'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();

      expect(selected, 'Apple');
    });

    testWidgets('multi select toggles values', (tester) async {
      Set<String>? selected;
      await DropifyTestApp.pump(
        tester,
        RawDropify<String>.multi(
          onChangedMulti: (v) => selected = v,
          anchorBuilder: (context, state) {
            if (state.isOpen) {
              return const Text('Open');
            }
            return Text('${state.values.length} selected');
          },
          panelBuilder: (context, state) {
            return InkWell(
              onTap: () => state.toggle('A'),
              child: Text(state.isSelected('A') ? 'A selected' : 'A'),
            );
          },
        ),
      );

      await tester.tap(find.text('0 selected'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(selected, contains('A'));
    });
  });
}
