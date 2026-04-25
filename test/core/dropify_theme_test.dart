import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('theme lookup falls back and reads inherited data', (
    tester,
  ) async {
    late DropifyThemeData fallback;
    late DropifyThemeData? maybe;
    late DropifyThemeData inherited;
    final DropifyThemeData data = DropifyThemeData.dark();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (BuildContext context) {
            fallback = DropifyTheme.of(context);
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

    expect(fallback, DropifyThemeData.light());
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
}
