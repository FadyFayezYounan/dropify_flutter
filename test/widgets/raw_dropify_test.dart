import 'dart:async';

import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const List<DropifyEntry<String>> _entries = <DropifyEntry<String>>[
  DropifyEntry<String>(value: 'apple', label: 'Apple'),
  DropifyEntry<String>(value: 'banana', label: 'Banana'),
  DropifyEntry<String>(value: 'disabled', label: 'Disabled', enabled: false),
];

void main() {
  testWidgets('opens filters and single selection closes by default', (
    tester,
  ) async {
    final DropifyController<String> controller =
        DropifyController<String>.single();
    final List<String> queries = <String>[];
    String? selected;

    await tester.pumpWidget(
      _RawHarness(
        controller: controller,
        onSelectionChanged: (String? value, List<String> values) {
          selected = value;
        },
        onQueryChanged: queries.add,
      ),
    );

    await tester.tap(find.byKey(_HarnessKeys.anchor));
    await tester.pumpAndSettle();

    expect(find.byKey(_HarnessKeys.panel), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);

    await tester.enterText(find.byKey(_HarnessKeys.search), 'BAN');
    await tester.pump();

    expect(find.text('Apple'), findsNothing);
    expect(find.text('Banana'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    expect(queries, <String>['BAN']);

    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();

    expect(selected, 'banana');
    expect(controller.singleValue, 'banana');
    expect(find.byKey(_HarnessKeys.panel), findsNothing);
  });

  testWidgets('multi selection stays open and disabled rows are ignored', (
    tester,
  ) async {
    final DropifyController<String> controller =
        DropifyController<String>.multi();

    await tester.pumpWidget(_RawHarness.multi(controller: controller));
    await tester.tap(find.byKey(_HarnessKeys.anchor));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();

    expect(controller.multiValues, <String>['apple']);
    expect(find.byKey(_HarnessKeys.panel), findsOneWidget);

    await tester.tap(find.text('Disabled'));
    await tester.pumpAndSettle();

    expect(controller.multiValues, <String>['apple']);
    expect(
      controller.lastRejectionReason,
      DropifySelectionRejectionReason.entryDisabled,
    );
  });

  testWidgets('custom matcher and controller scope are honored', (
    tester,
  ) async {
    DropifyController<String>? scopedController;
    final DropifyController<String> controller =
        DropifyController<String>.single();

    await tester.pumpWidget(
      _RawHarness(
        controller: controller,
        matcher: (DropifyEntry<String> entry, String query) {
          return entry.value.startsWith(query);
        },
        captureScopedController: (DropifyController<String>? value) {
          scopedController = value;
        },
      ),
    );

    await tester.tap(find.byKey(_HarnessKeys.anchor));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(_HarnessKeys.search), 'b');
    await tester.pump();

    expect(scopedController, controller);
    expect(find.text('Apple'), findsNothing);
    expect(find.text('Banana'), findsOneWidget);
  });

  testWidgets('async source fetches on open and publishes data', (
    tester,
  ) async {
    final DropifyController<String> controller =
        DropifyController<String>.single();
    final Completer<List<DropifyEntry<String>>> completer =
        Completer<List<DropifyEntry<String>>>();

    await tester.pumpWidget(
      _RawHarness.async(
        controller: controller,
        fetch: (String query) => completer.future,
      ),
    );

    await tester.tap(find.byKey(_HarnessKeys.anchor));
    await tester.pump();

    expect(controller.status, DropifyStatus.loading);

    completer.complete(<DropifyEntry<String>>[
      const DropifyEntry<String>(value: 'async', label: 'Async'),
    ]);
    await tester.pumpAndSettle();

    expect(controller.status, DropifyStatus.data);
    expect(find.text('Async'), findsOneWidget);
  });
}

abstract final class _HarnessKeys {
  static const Key anchor = ValueKey<String>('raw-harness-anchor');
  static const Key panel = ValueKey<String>('raw-harness-panel');
  static const Key search = ValueKey<String>('raw-harness-search');
}

class _RawHarness extends StatelessWidget {
  const _RawHarness({
    required this.controller,
    this.matcher,
    this.onSelectionChanged,
    this.onQueryChanged,
    this.captureScopedController,
  }) : isMulti = false,
       isAsync = false,
       fetch = null;

  const _RawHarness.multi({required this.controller})
    : isMulti = true,
      isAsync = false,
      fetch = null,
      matcher = null,
      onSelectionChanged = null,
      onQueryChanged = null,
      captureScopedController = null;

  const _RawHarness.async({required this.controller, required this.fetch})
    : isMulti = false,
      isAsync = true,
      matcher = null,
      onSelectionChanged = null,
      onQueryChanged = null,
      captureScopedController = null;

  final bool isMulti;
  final bool isAsync;
  final DropifyController<String> controller;
  final DropifyAsyncFetcher<String>? fetch;
  final DropifyStaticMatcher<String>? matcher;
  final DropifySelectionChanged<String>? onSelectionChanged;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<DropifyController<String>?>? captureScopedController;

  @override
  Widget build(BuildContext context) {
    final Widget rawDropify = isMulti
        ? RawDropify<String>.multi(
            controller: controller,
            dataSource: const StaticDropifyDataSource<String>(
              entries: _entries,
            ),
            staticMatcher: matcher,
            onSelectionChanged: onSelectionChanged,
            onQueryChanged: onQueryChanged,
            anchorBuilder: _anchorBuilder,
            bodyBuilder: _bodyBuilder,
          )
        : isAsync
        ? RawDropify<String>(
            controller: controller,
            dataSource: AsyncDropifyDataSource<String>(fetch: fetch!),
            anchorBuilder: _anchorBuilder,
            bodyBuilder: _bodyBuilder,
          )
        : RawDropify<String>(
            controller: controller,
            dataSource: const StaticDropifyDataSource<String>(
              entries: _entries,
            ),
            staticMatcher: matcher,
            onSelectionChanged: onSelectionChanged,
            onQueryChanged: onQueryChanged,
            anchorBuilder: _anchorBuilder,
            bodyBuilder: _bodyBuilder,
          );
    return MaterialApp(
      home: Scaffold(body: Center(child: rawDropify)),
    );
  }

  Widget _anchorBuilder(
    BuildContext context,
    DropifyController<String> controller,
    Widget? child,
  ) {
    return TextButton(
      key: _HarnessKeys.anchor,
      onPressed: controller.isOpen ? controller.close : controller.open,
      child: const Text('Open'),
    );
  }

  Widget _bodyBuilder(BuildContext context, DropifyState<String> state) {
    captureScopedController?.call(DropifyController.maybeOf<String>(context));
    return Material(
      child: SizedBox(
        key: _HarnessKeys.panel,
        width: 240,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              key: _HarnessKeys.search,
              onChanged: state.controller.setQuery,
            ),
            for (final DropifyEntry<String> entry in state.entries)
              TextButton(
                onPressed: () => state.toggle(entry.value),
                child: Text(entry.label),
              ),
          ],
        ),
      ),
    );
  }
}
