import 'dart:async';

import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../helpers/dropify_test_app.dart';

void main() {
  testWidgets('themed async default item exposes selected semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      dropifyTestApp(
        DropifyAsyncDropdown<String>(
          fetcher: (query, {required cancel}) async => const ['Remote'],
          itemLabelBuilder: (item) => item,
          keyOf: (item) => item,
          initialValue: 'Remote',
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Remote' &&
            widget.properties.selected == true,
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('dropify.item.Remote')),
      findsOneWidget,
    );
  });

  testWidgets('loaded async data uses lazy shell and preserves selection', (
    tester,
  ) async {
    final completer = Completer<List<String>>();
    String? selected;

    await tester.pumpWidget(
      dropifyTestApp(
        RawAsyncDropify<String>(
          fetcher: (query, {required cancel}) => completer.future,
          anchorBuilder: _anchorBuilder,
          itemBuilder: _asyncItemBuilder,
          onChanged: (value) => selected = value,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('dropify.async.loading')),
      findsOneWidget,
    );
    expect(find.byType(Scrollbar), findsNothing);

    completer.complete(List<String>.generate(60, (index) => 'Item $index'));
    await tester.pumpAndSettle();

    final listView = tester.widget<SuperListView>(find.byType(SuperListView));
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(listView.shrinkWrap, isFalse);

    await tester.tap(find.text('Item 0'));
    await tester.pumpAndSettle();

    expect(selected, 'Item 0');
    expect(find.byKey(const ValueKey<String>('dropify.panel')), findsNothing);
  });

  testWidgets('async lazy loaded rows reveal selected item after fetch', (
    tester,
  ) async {
    final completer = Completer<List<String>>();

    await tester.pumpWidget(
      dropifyTestApp(
        SizedBox(
          width: 240,
          child: DropifyAsyncDropdown<String>(
            fetcher: (query, {required cancel}) => completer.future,
            itemLabelBuilder: (item) => item,
            keyOf: (item) => item,
            initialValue: 'Item 90',
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();
    completer.complete(List<String>.generate(100, (index) => 'Item $index'));
    await tester.pumpAndSettle();

    expect(find.byType(SuperListView), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('dropify.item.Item_90')),
      findsOneWidget,
    );
  });

  testWidgets('async forced eager rows reveal selected item after fetch', (
    tester,
  ) async {
    final completer = Completer<List<String>>();

    await tester.pumpWidget(
      dropifyTestApp(
        SizedBox(
          width: 240,
          child: DropifyAsyncDropdown<String>(
            fetcher: (query, {required cancel}) => completer.future,
            itemLabelBuilder: (item) => item,
            keyOf: (item) => item,
            initialValue: 'Item 90',
            menuBodyMode: DropifyMenuBodyMode.eagerColumn,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();
    completer.complete(List<String>.generate(100, (index) => 'Item $index'));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    final panelRect = tester.getRect(
      find.byKey(const ValueKey<String>('dropify.panel')),
    );
    final selectedRect = tester.getRect(
      find.byKey(const ValueKey<String>('dropify.item.Item_90')),
    );
    expect(selectedRect.top, greaterThanOrEqualTo(panelRect.top));
    expect(selectedRect.bottom, lessThanOrEqualTo(panelRect.bottom));
  });

  testWidgets('async cache hit reopens selected item without extra fetch', (
    tester,
  ) async {
    var calls = 0;

    await tester.pumpWidget(
      dropifyTestApp(
        SizedBox(
          width: 240,
          child: DropifyAsyncDropdown<String>(
            fetcher: (query, {required cancel}) async {
              calls += 1;
              return List<String>.generate(100, (index) => 'Item $index');
            },
            itemLabelBuilder: (item) => item,
            keyOf: (item) => item,
            initialValue: 'Item 90',
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(
      find.byKey(const ValueKey<String>('dropify.item.Item_90')),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(790, 590));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(
      find.byKey(const ValueKey<String>('dropify.item.Item_90')),
      findsOneWidget,
    );
  });

  testWidgets('refreshing keeps stale rows plus progress in lazy shell', (
    tester,
  ) async {
    final requests = <Completer<List<String>>>[];

    await tester.pumpWidget(
      dropifyTestApp(
        RawAsyncDropify<String>(
          fetcher: (query, {required cancel}) {
            final request = Completer<List<String>>();
            requests.add(request);
            return request.future;
          },
          anchorBuilder: _anchorBuilder,
          itemBuilder: _asyncItemBuilder,
          searchDebounce: Duration.zero,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();
    requests.single.complete(const ['Old item']);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('dropify.search.field')),
      'new',
    );
    await tester.pump();

    expect(find.text('Old item'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('dropify.async.refreshing')),
      findsOneWidget,
    );
    expect(find.byType(Scrollbar), findsOneWidget);

    requests.last.complete(const ['New item']);
    await tester.pumpAndSettle();

    expect(find.text('Old item'), findsNothing);
    expect(find.text('New item'), findsOneWidget);
  });

  testWidgets(
    'empty and error async states stay direct and retry fetches again',
    (tester) async {
      var calls = 0;

      await tester.pumpWidget(
        dropifyTestApp(
          RawAsyncDropify<String>(
            fetcher: (query, {required cancel}) async {
              calls += 1;
              if (calls == 1) {
                return const <String>[];
              }
              if (calls == 2) {
                throw StateError('boom');
              }
              return const ['Recovered'];
            },
            anchorBuilder: _anchorBuilder,
            itemBuilder: _asyncItemBuilder,
            cacheItems: false,
            searchDebounce: Duration.zero,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('dropify.async.empty')),
        findsOneWidget,
      );
      expect(find.byType(Scrollbar), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey<String>('dropify.search.field')),
        'err',
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('dropify.async.error')),
        findsOneWidget,
      );
      expect(find.byType(Scrollbar), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey<String>('dropify.async.retry')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recovered'), findsOneWidget);
      expect(find.byType(Scrollbar), findsOneWidget);
    },
  );

  testWidgets('older async results never render after a newer query starts', (
    tester,
  ) async {
    final requests = <Completer<List<String>>>[];

    await tester.pumpWidget(
      dropifyTestApp(
        RawAsyncDropify<String>(
          fetcher: (query, {required cancel}) {
            final request = Completer<List<String>>();
            requests.add(request);
            return request.future;
          },
          anchorBuilder: _anchorBuilder,
          itemBuilder: _asyncItemBuilder,
          searchDebounce: Duration.zero,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();
    requests.single.complete(const ['Initial']);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('dropify.search.field')),
      'a',
    );
    await tester.pump();
    final staleRequest = requests.last;

    await tester.enterText(
      find.byKey(const ValueKey<String>('dropify.search.field')),
      'b',
    );
    await tester.pump();
    final freshRequest = requests.last;

    staleRequest.complete(const ['Stale']);
    await tester.pump();
    expect(find.text('Stale'), findsNothing);

    freshRequest.complete(const ['Fresh']);
    await tester.pumpAndSettle();
    expect(find.text('Fresh'), findsOneWidget);
  });

  testWidgets('search debounce coalesces fetches and cache reuses query data', (
    tester,
  ) async {
    final queries = <String>[];

    await tester.pumpWidget(
      dropifyTestApp(
        RawAsyncDropify<String>(
          fetcher: (query, {required cancel}) async {
            queries.add(query);
            return <String>['Result $query'];
          },
          anchorBuilder: _anchorBuilder,
          itemBuilder: _asyncItemBuilder,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('dropify.search.field')),
      'a',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 299));
    expect(queries, const ['']);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(queries, const ['', 'a']);

    await tester.enterText(
      find.byKey(const ValueKey<String>('dropify.search.field')),
      '',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(queries, const ['', 'a']);
    expect(find.text('Result '), findsOneWidget);
  });
}

Widget _anchorBuilder(BuildContext context, DropifyAnchorState<String> state) {
  return SizedBox(
    width: 240,
    child: TextButton(
      key: const ValueKey<String>('dropify.anchor'),
      onPressed: state.open,
      child: Text(state.value ?? 'Open'),
    ),
  );
}

Widget _asyncItemBuilder(
  BuildContext context,
  String item,
  bool selected,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    child: SizedBox(height: 40, child: Text(item)),
  );
}
