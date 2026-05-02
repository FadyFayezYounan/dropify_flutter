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

  test('static single constructors expose menu body defaults', () {
    expect(DropifyMenuBodyMode.values, const [
      DropifyMenuBodyMode.automatic,
      DropifyMenuBodyMode.eagerColumn,
      DropifyMenuBodyMode.lazyIndexed,
    ]);

    final raw = RawStaticDropify<String>(
      entries: const [],
      anchorBuilder: (context, state) => const SizedBox.shrink(),
    );
    expect(raw.menuBodyMode, DropifyMenuBodyMode.automatic);
    expect(raw.scrollToSelectedOnOpen, isTrue);

    const themed = DropifyDropdown<String>(entries: []);
    expect(themed.menuBodyMode, DropifyMenuBodyMode.automatic);
    expect(themed.scrollToSelectedOnOpen, isTrue);
  });

  test('static multi constructors expose menu body controls', () {
    final defaultRaw = RawStaticDropify<String>.multi(
      entries: const [],
      anchorBuilder: (context, state) => const SizedBox.shrink(),
    );
    expect(defaultRaw.menuBodyMode, DropifyMenuBodyMode.automatic);
    expect(defaultRaw.scrollToSelectedOnOpen, isTrue);

    final raw = RawStaticDropify<String>.multi(
      entries: const [],
      anchorBuilder: (context, state) => const SizedBox.shrink(),
      menuBodyMode: DropifyMenuBodyMode.lazyIndexed,
      scrollToSelectedOnOpen: false,
    );
    expect(raw.menuBodyMode, DropifyMenuBodyMode.lazyIndexed);
    expect(raw.scrollToSelectedOnOpen, isFalse);

    const defaultThemed = DropifyDropdown<String>.multi(entries: []);
    expect(defaultThemed.menuBodyMode, DropifyMenuBodyMode.automatic);
    expect(defaultThemed.scrollToSelectedOnOpen, isTrue);

    const themed = DropifyDropdown<String>.multi(
      entries: [],
      menuBodyMode: DropifyMenuBodyMode.eagerColumn,
      scrollToSelectedOnOpen: false,
    );
    expect(themed.menuBodyMode, DropifyMenuBodyMode.eagerColumn);
    expect(themed.scrollToSelectedOnOpen, isFalse);
  });

  test('async constructors expose menu body controls', () {
    Future<List<String>> fetcher(String query, {required cancel}) async =>
        const [];
    Widget itemBuilder(
      BuildContext context,
      String item,
      bool selected,
      VoidCallback onTap,
    ) {
      return const SizedBox.shrink();
    }

    final rawSingle = RawAsyncDropify<String>(
      fetcher: fetcher,
      anchorBuilder: (context, state) => const SizedBox.shrink(),
      itemBuilder: itemBuilder,
    );
    expect(rawSingle.menuBodyMode, DropifyMenuBodyMode.automatic);
    expect(rawSingle.scrollToSelectedOnOpen, isTrue);

    final rawMulti = RawAsyncDropify<String>.multi(
      fetcher: fetcher,
      anchorBuilder: (context, state) => const SizedBox.shrink(),
      itemBuilder: itemBuilder,
      menuBodyMode: DropifyMenuBodyMode.eagerColumn,
      scrollToSelectedOnOpen: false,
    );
    expect(rawMulti.menuBodyMode, DropifyMenuBodyMode.eagerColumn);
    expect(rawMulti.scrollToSelectedOnOpen, isFalse);

    final themedSingle = DropifyAsyncDropdown<String>(
      fetcher: fetcher,
      itemLabelBuilder: (item) => item,
    );
    expect(themedSingle.menuBodyMode, DropifyMenuBodyMode.automatic);
    expect(themedSingle.scrollToSelectedOnOpen, isTrue);

    final themedMulti = DropifyAsyncDropdown<String>.multi(
      fetcher: fetcher,
      itemLabelBuilder: (item) => item,
      menuBodyMode: DropifyMenuBodyMode.lazyIndexed,
      scrollToSelectedOnOpen: false,
    );
    expect(themedMulti.menuBodyMode, DropifyMenuBodyMode.lazyIndexed);
    expect(themedMulti.scrollToSelectedOnOpen, isFalse);
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
    expect(materialDefaults.anchorDecorationTheme, isNotNull);
    expect(
      materialDefaults.anchorDecorationTheme?.border,
      isA<OutlineInputBorder>(),
    );
  });
}
