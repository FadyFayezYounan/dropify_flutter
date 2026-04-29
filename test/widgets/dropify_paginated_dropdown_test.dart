import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../helpers/dropify_test_app.dart';

void main() {
  testWidgets('opening paginated dropdown defers initial load outside build', (
    tester,
  ) async {
    final controller = DropifyPaginatedHarnessController();

    await tester.pumpWidget(
      dropifyTestApp(
        DropifyPaginatedHarness(controller: controller, searchable: false),
      ),
    );

    expect(controller.pagingState.pages, isNull);

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();

    expect(tester.takeException(), isNull);
    await tester.pump();
    expect(controller.fetchNextPageCalls, greaterThanOrEqualTo(1));
    expect(find.text('Alpha'), findsOneWidget);
  });

  testWidgets('paginated body uses shared shell and caller-owned next page', (
    tester,
  ) async {
    final controller = DropifyPaginatedHarnessController();

    await tester.pumpWidget(
      dropifyTestApp(
        DropifyPaginatedHarness(controller: controller, searchable: false),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();
    await tester.pump();

    final pagedList = tester.widget<PagedListView<int, String>>(
      find.byType(PagedListView<int, String>),
    );
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(pagedList.controller, isNotNull);
    expect(pagedList.primary, isFalse);
    expect(pagedList.shrinkWrap, isFalse);
    expect(pagedList.padding, EdgeInsets.zero);

    await tester.fling(
      find.byType(PagedListView<int, String>),
      const Offset(0, -300),
      1000,
    );
    await tester.pump();
    await tester.pump();

    expect(controller.fetchNextPageCalls, greaterThanOrEqualTo(1));
  });

  testWidgets('paginated search delegates ownership to caller', (tester) async {
    final controller = DropifyPaginatedHarnessController();

    await tester.pumpWidget(
      dropifyTestApp(DropifyPaginatedHarness(controller: controller)),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey<String>('dropify.search.field')),
      'al',
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(controller.searchQueries, const ['al']);
    expect(controller.pagingState.search, 'al');
    expect(controller.fetchNextPageCalls, greaterThanOrEqualTo(1));
  });

  testWidgets('paginated delegate state builders resolve', (tester) async {
    await _pumpRawPaginated(tester, state: DropifyPagingState<int, String>());
    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();
    expect(
      find.byKey(const ValueKey<String>('firstPageProgress')),
      findsOneWidget,
    );

    await _pumpRawPaginated(
      tester,
      state: DropifyPagingState<int, String>(error: StateError('first')),
    );
    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();
    expect(
      find.byKey(const ValueKey<String>('firstPageError')),
      findsOneWidget,
    );

    await _pumpRawPaginated(
      tester,
      state: DropifyPagingState<int, String>(
        pages: const [<String>[]],
        keys: const [0],
        hasNextPage: false,
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('noItems')), findsOneWidget);

    await _pumpRawPaginated(
      tester,
      state: DropifyPagingState<int, String>(
        pages: const [
          <String>['Alpha'],
        ],
        keys: const [0],
        hasNextPage: true,
        isLoading: true,
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();
    expect(
      find.byKey(const ValueKey<String>('newPageProgress')),
      findsOneWidget,
    );

    await _pumpRawPaginated(
      tester,
      state: DropifyPagingState<int, String>(
        pages: const [
          <String>['Alpha'],
        ],
        keys: const [0],
        hasNextPage: true,
        error: StateError('next'),
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('newPageError')), findsOneWidget);

    await _pumpRawPaginated(
      tester,
      state: DropifyPagingState<int, String>(
        pages: const [
          <String>['Alpha'],
        ],
        keys: const [0],
        hasNextPage: false,
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('noMoreItems')), findsOneWidget);
  });
}

Future<void> _pumpRawPaginated(
  WidgetTester tester, {
  required DropifyPagingState<int, String> state,
}) async {
  await tester.pumpWidget(
    dropifyTestApp(
      RawPaginatedDropify<int, String>(
        state: state,
        fetchNextPage: () {},
        anchorBuilder: (context, anchorState) => SizedBox(
          width: 240,
          child: TextButton(
            key: const ValueKey<String>('dropify.anchor'),
            onPressed: anchorState.open,
            child: const Text('Open'),
          ),
        ),
        itemBuilder: (context, item, index, selected, onTap) =>
            SizedBox(height: 40, child: Text(item)),
        firstPageProgressBuilder: (context) => const SizedBox(
          key: ValueKey<String>('firstPageProgress'),
          child: Text('First loading'),
        ),
        newPageProgressBuilder: (context) => const SizedBox(
          key: ValueKey<String>('newPageProgress'),
          child: Text('New loading'),
        ),
        firstPageErrorBuilder: (context, error, retry) => const SizedBox(
          key: ValueKey<String>('firstPageError'),
          child: Text('First error'),
        ),
        newPageErrorBuilder: (context, error, retry) => const SizedBox(
          key: ValueKey<String>('newPageError'),
          child: Text('New error'),
        ),
        noItemsFoundBuilder: (context) => const SizedBox(
          key: ValueKey<String>('noItems'),
          child: Text('No items'),
        ),
        noMoreItemsBuilder: (context) => const SizedBox(
          key: ValueKey<String>('noMoreItems'),
          child: Text('No more'),
        ),
        searchable: false,
        loadOnOpen: false,
      ),
    ),
  );
}
