import 'dart:async';

import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('fetchOnOpen renders loading then data', (tester) async {
    final Completer<List<DropifyEntry<String>>> completer =
        Completer<List<DropifyEntry<String>>>();
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyAsyncDropdown<String>(
            fetch: (String query) => completer.future,
            loadingBuilder: (BuildContext context) => const Text('Loading...'),
            onChanged: (String? value) {
              selected = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pump();

    expect(find.text('Loading...'), findsOneWidget);

    completer.complete(<DropifyEntry<String>>[
      const DropifyEntry<String>(value: 'apple', label: 'Apple'),
    ]);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(DropifyKeys.row('apple')));
    await tester.pumpAndSettle();

    expect(selected, 'apple');
    expect(find.byKey(DropifyKeys.panel), findsNothing);
  });

  testWidgets('error builder can retry the latest query', (tester) async {
    int calls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyAsyncDropdown<String>(
            fetch: (String query) async {
              calls += 1;
              if (calls == 1) {
                throw StateError('failed');
              }
              return <DropifyEntry<String>>[
                const DropifyEntry<String>(value: 'retry', label: 'Retried'),
              ];
            },
            errorBuilder:
                (BuildContext context, Object error, VoidCallback retry) {
                  return TextButton(
                    key: DropifyKeys.retryButton,
                    onPressed: retry,
                    child: Text('$error'),
                  );
                },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pumpAndSettle();

    expect(find.textContaining('failed'), findsOneWidget);

    await tester.tap(find.byKey(DropifyKeys.retryButton));
    await tester.pumpAndSettle();

    expect(find.text('Retried'), findsOneWidget);
  });

  testWidgets('empty state renders when fetch returns no entries', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyAsyncDropdown<String>(
            fetch: (String query) async => List<DropifyEntry<String>>.empty(),
            emptyBuilder: (BuildContext context, String query) {
              return Text('No matches for "$query"');
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pumpAndSettle();

    expect(find.text('No matches for ""'), findsOneWidget);
  });

  testWidgets('rapid query drops stale responses', (tester) async {
    final List<Completer<List<DropifyEntry<String>>>> requests =
        <Completer<List<DropifyEntry<String>>>>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyAsyncDropdown<String>(
            fetchOnOpen: false,
            queryDebounce: Duration.zero,
            fetch: (String query) {
              final Completer<List<DropifyEntry<String>>> completer =
                  Completer<List<DropifyEntry<String>>>();
              requests.add(completer);
              return completer.future;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(DropifyKeys.searchField), 'a');
    await tester.pump();
    await tester.enterText(find.byKey(DropifyKeys.searchField), 'b');
    await tester.pump();

    requests[1].complete(<DropifyEntry<String>>[
      const DropifyEntry<String>(value: 'b', label: 'Beta'),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Beta'), findsOneWidget);

    requests[0].complete(<DropifyEntry<String>>[
      const DropifyEntry<String>(value: 'a', label: 'Alpha'),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('controller refresh refetches current query', (tester) async {
    final DropifyController<String> controller =
        DropifyController<String>.single();
    int calls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyAsyncDropdown<String>(
            controller: controller,
            fetch: (String query) async {
              calls += 1;
              return <DropifyEntry<String>>[
                DropifyEntry<String>(value: '$calls', label: 'Call $calls'),
              ];
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pumpAndSettle();

    expect(find.text('Call 1'), findsOneWidget);

    controller.refresh();
    await tester.pumpAndSettle();

    expect(find.text('Call 2'), findsOneWidget);
  });

  testWidgets('dispose during pending fetch ignores late completion', (
    tester,
  ) async {
    final Completer<List<DropifyEntry<String>>> completer =
        Completer<List<DropifyEntry<String>>>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyAsyncDropdown<String>(
            fetch: (String query) => completer.future,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());

    completer.complete(<DropifyEntry<String>>[
      const DropifyEntry<String>(value: 'late', label: 'Late'),
    ]);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
