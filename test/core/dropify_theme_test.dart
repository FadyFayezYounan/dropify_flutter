import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('theme lookup falls back to Material and reads inherited data', (
    tester,
  ) async {
    late DropifyThemeData fallback;
    late DropifyThemeData material;
    late DropifyThemeData? maybe;
    late DropifyThemeData inherited;
    final DropifyThemeData data = DropifyThemeData.dark();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
        home: Builder(
          builder: (BuildContext context) {
            fallback = DropifyTheme.of(context);
            material = DropifyThemeData.fromMaterial(context);
            maybe = DropifyTheme.maybeOf(context);
            return DropifyTheme(
              data: data,
              child: Builder(
                builder: (BuildContext context) {
                  inherited = DropifyTheme.of(context);
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      ),
    );

    expect(fallback, material);
    expect(maybe, isNull);
    expect(inherited, data);
  });

  testWidgets('fromMaterial and lerp produce theme data', (tester) async {
    late DropifyThemeData materialData;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
        home: Builder(
          builder: (BuildContext context) {
            materialData = DropifyThemeData.fromMaterial(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(materialData.panelColor, isNotNull);
    expect(
      DropifyThemeData.lerp(
        DropifyThemeData.light(),
        DropifyThemeData.dark(),
        0,
      ),
      DropifyThemeData.light(),
    );
  });

  test('lerp preserves non-lerpable theme fields by nearest endpoint', () {
    const InputDecoration leftDecoration = InputDecoration(hintText: 'Left');
    const InputDecoration rightDecoration = InputDecoration(hintText: 'Right');
    final DropifyThemeData left = DropifyThemeData.light().copyWith(
      searchDecoration: leftDecoration,
      chevronIcon: Icons.keyboard_arrow_down,
      hintText: 'Left hint',
      searchHintText: 'Left search',
    );
    final DropifyThemeData right = DropifyThemeData.dark().copyWith(
      searchDecoration: rightDecoration,
      chevronIcon: Icons.keyboard_arrow_up,
      hintText: 'Right hint',
      searchHintText: 'Right search',
    );

    final DropifyThemeData nearLeft = DropifyThemeData.lerp(left, right, 0.25);
    final DropifyThemeData nearRight = DropifyThemeData.lerp(left, right, 0.75);

    expect(nearLeft.searchDecoration, leftDecoration);
    expect(nearLeft.chevronIcon, Icons.keyboard_arrow_down);
    expect(nearLeft.hintText, 'Left hint');
    expect(nearLeft.searchHintText, 'Left search');
    expect(nearRight.searchDecoration, rightDecoration);
    expect(nearRight.chevronIcon, Icons.keyboard_arrow_up);
    expect(nearRight.hintText, 'Right hint');
    expect(nearRight.searchHintText, 'Right search');
  });
}
