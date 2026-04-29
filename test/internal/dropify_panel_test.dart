import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:dropify_flutter/src/internal/_dropify_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('explicit panel fields override conflicting panelDecoration', (
    tester,
  ) async {
    final decoration = BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.orange),
    );

    await _pumpPanel(
      tester,
      DropifyThemeData(
        panelDecoration: decoration,
        panelColor: Colors.blue,
        panelElevation: 7,
        panelShadowColor: Colors.green,
        panelSurfaceTintColor: Colors.yellow,
        panelShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        panelSide: const BorderSide(color: Colors.purple, width: 3),
        panelClipBehavior: Clip.antiAlias,
      ),
    );

    final material = _panelMaterial(tester);
    final shape = material.shape! as RoundedRectangleBorder;
    expect(material.color, Colors.blue);
    expect(material.elevation, 7);
    expect(material.shadowColor, Colors.green);
    expect(material.surfaceTintColor, Colors.yellow);
    expect(material.clipBehavior, Clip.antiAlias);
    expect(shape.borderRadius, BorderRadius.circular(20));
    expect(shape.side, const BorderSide(color: Colors.purple, width: 3));
  });

  testWidgets(
    'representable panelDecoration maps to Material without repainting',
    (tester) async {
      final decoration = BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green, width: 2),
      );

      await _pumpPanel(tester, DropifyThemeData(panelDecoration: decoration));

      final material = _panelMaterial(tester);
      final shape = material.shape! as RoundedRectangleBorder;
      expect(material.type, MaterialType.canvas);
      expect(material.color, Colors.red);
      expect(shape.borderRadius, BorderRadius.circular(8));
      expect(shape.side, const BorderSide(color: Colors.green, width: 2));
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('dropify.panel')),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox && widget.decoration == decoration,
          ),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'non-representable panelDecoration keeps legacy decoration fallback',
    (tester) async {
      const decoration = BoxDecoration(
        gradient: LinearGradient(colors: [Colors.red, Colors.blue]),
      );

      await _pumpPanel(
        tester,
        const DropifyThemeData(panelDecoration: decoration),
      );

      final material = _panelMaterial(tester);
      expect(material.type, MaterialType.transparency);
      expect(material.elevation, 0);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('dropify.panel')),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox && widget.decoration == decoration,
          ),
        ),
        findsOneWidget,
      );
    },
  );
}

Future<void> _pumpPanel(WidgetTester tester, DropifyThemeData data) async {
  final searchController = TextEditingController();
  addTearDown(searchController.dispose);

  await tester.pumpWidget(
    MaterialApp(
      home: DropifyTheme(
        data: data,
        child: Scaffold(
          body: DropifyPanel(
            searchable: false,
            searchController: searchController,
            onSearchChanged: (_) {},
            anchorWidth: 240,
            matchAnchorWidth: true,
            confirmable: false,
            onApply: () {},
            onCancel: () {},
            child: const SizedBox(height: 48, child: Text('Body')),
          ),
        ),
      ),
    ),
  );
}

Material _panelMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find
        .ancestor(
          of: find.byKey(const ValueKey<String>('dropify.panel')),
          matching: find.byType(Material),
        )
        .first,
  );
}
