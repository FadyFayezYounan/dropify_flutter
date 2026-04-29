import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public package exports key v0.1.0 symbols', () {
    expect(DropifyEntry<String>, isNotNull);
    expect(DropifyController<String>.single, isNotNull);
    expect(DropifyCancelToken, isNotNull);
    expect(DropifyPagingState<int, String>, isNotNull);
    expect(RawDropify<String>, isNotNull);
    expect(RawStaticDropify<String>, isNotNull);
    expect(RawAsyncDropify<String>, isNotNull);
    expect(RawPaginatedDropify<int, String>, isNotNull);
    expect(DropifyDropdown<String>, isNotNull);
    expect(DropifyAsyncDropdown<String>, isNotNull);
    expect(DropifyPaginatedDropdown<int, String>, isNotNull);
  });

  test('theme data exposes Material panel chrome fields', () {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );
    final data = DropifyThemeData(
      panelColor: Colors.blue,
      panelShadowColor: Colors.green,
      panelSurfaceTintColor: Colors.yellow,
      panelShape: shape,
      panelSide: const BorderSide(color: Colors.purple),
      panelClipBehavior: Clip.antiAlias,
    );

    expect(data.panelColor, Colors.blue);
    expect(data.panelShadowColor, Colors.green);
    expect(data.panelSurfaceTintColor, Colors.yellow);
    expect(data.panelShape, shape);
    expect(data.panelSide, const BorderSide(color: Colors.purple));
    expect(data.panelClipBehavior, Clip.antiAlias);
    expect(
      DropifyThemeData.merge(const DropifyThemeData(), data).panelColor,
      Colors.blue,
    );
    expect(data.copyWith(panelColor: Colors.red).panelColor, Colors.red);
    expect(
      data.lerp(const DropifyThemeData(panelColor: Colors.red), 1).panelColor,
      isSameColorAs(Colors.red),
    );
    final materialDefaults = DropifyThemeData.fromMaterial(ThemeData());
    expect(materialDefaults.panelColor, isNotNull);
    expect(materialDefaults.panelShadowColor, isNotNull);
    expect(materialDefaults.panelSurfaceTintColor, isNotNull);
    expect(materialDefaults.panelShape, isNotNull);
    expect(materialDefaults.panelSide, isNotNull);
    expect(materialDefaults.panelClipBehavior, Clip.none);
    expect(materialDefaults.panelDecoration?.boxShadow, isNull);
  });
}
