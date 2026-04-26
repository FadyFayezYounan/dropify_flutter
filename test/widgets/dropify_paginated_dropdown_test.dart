import 'dart:async';

import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('first page loads on open and explicit loadMore appends', (
    tester,
  ) async {
    final DropifyController<String> controller =
        DropifyController<String>.single();
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyPaginatedDropdown<String>(
            controller: controller,
            firstPageKey: 1,
            fetchPage: (int pageKey, String query) async {
              return DropifyPage<String>(
                entries: <DropifyEntry<String>>[
                  DropifyEntry<String>(
                    value: 'item-$pageKey',
                    label: 'Item $pageKey',
                  ),
                ],
                nextPageKey: pageKey == 1 ? 2 : null,
              );
            },
            onChanged: (String? value) {
              selected = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pumpAndSettle();

    expect(find.byKey(DropifyKeys.row('item-1')), findsOneWidget);

    controller.loadMore();
    await tester.pumpAndSettle();

    expect(find.byKey(DropifyKeys.row('item-2')), findsOneWidget);

    await tester.tap(find.byKey(DropifyKeys.row('item-2')));
    await tester.pumpAndSettle();

    expect(selected, 'item-2');
  });

  testWidgets('query reset reloads first page for latest query', (
    tester,
  ) async {
    final List<String> requests = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyPaginatedDropdown<String>(
            queryDebounce: Duration.zero,
            firstPageKey: 1,
            fetchPage: (int pageKey, String query) async {
              requests.add('$pageKey:$query');
              return DropifyPage<String>(
                entries: <DropifyEntry<String>>[
                  DropifyEntry<String>(value: query, label: 'Query $query'),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(DropifyKeys.searchField), 'abc');
    await tester.pumpAndSettle();

    expect(requests, <String>['1:', '1:abc']);
    expect(find.byKey(DropifyKeys.row('abc')), findsOneWidget);
  });

  testWidgets('first-page error uses main retry state', (tester) async {
    int calls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyPaginatedDropdown<String>(
            fetchPage: (int pageKey, String query) async {
              calls += 1;
              if (calls == 1) {
                throw Exception('first failed');
              }
              return const DropifyPage<String>(
                entries: <DropifyEntry<String>>[
                  DropifyEntry<String>(value: 'ok', label: 'OK'),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pumpAndSettle();

    expect(find.byKey(DropifyKeys.retryButton), findsOneWidget);

    await tester.tap(find.byKey(DropifyKeys.retryButton));
    await tester.pumpAndSettle();

    expect(find.byKey(DropifyKeys.row('ok')), findsOneWidget);
  });

  testWidgets('later-page error keeps entries and retries footer', (
    tester,
  ) async {
    final DropifyController<String> controller =
        DropifyController<String>.single();
    int pageTwoCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyPaginatedDropdown<String>(
            controller: controller,
            firstPageKey: 1,
            fetchPage: (int pageKey, String query) async {
              if (pageKey == 1) {
                return const DropifyPage<String>(
                  entries: <DropifyEntry<String>>[
                    DropifyEntry<String>(value: 'first', label: 'First'),
                  ],
                  nextPageKey: 2,
                );
              }
              pageTwoCalls += 1;
              if (pageTwoCalls == 1) {
                throw Exception('next failed');
              }
              return const DropifyPage<String>(
                entries: <DropifyEntry<String>>[
                  DropifyEntry<String>(value: 'second', label: 'Second'),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pumpAndSettle();
    controller.loadMore();
    await tester.pumpAndSettle();

    expect(find.byKey(DropifyKeys.row('first')), findsOneWidget);
    expect(find.byKey(DropifyKeys.pageRetryButton), findsOneWidget);

    await tester.tap(find.byKey(DropifyKeys.pageRetryButton));
    await tester.pumpAndSettle();

    expect(find.byKey(DropifyKeys.row('second')), findsOneWidget);
  });

  testWidgets('dispose during pending page ignores late completion', (
    tester,
  ) async {
    final Completer<DropifyPage<String>> completer =
        Completer<DropifyPage<String>>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyPaginatedDropdown<String>(
            fetchPage: (int pageKey, String query) => completer.future,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());

    completer.complete(
      const DropifyPage<String>(
        entries: <DropifyEntry<String>>[
          DropifyEntry<String>(value: 'late', label: 'Late'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
