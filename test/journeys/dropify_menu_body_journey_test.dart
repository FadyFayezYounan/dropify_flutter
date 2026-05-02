import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/dropify_fixtures.dart';
import '../helpers/dropify_test_app.dart';
import '../robots/dropify_robot.dart';

void main() {
  testWidgets('static single-select journey searches, selects, and closes', (
    tester,
  ) async {
    String? selected;
    final robot = DropifyRobot(tester);

    await tester.pumpWidget(
      dropifyTestApp(
        DropifyDropdown<String>(
          entries: fruitEntries,
          hintText: 'Pick fruit',
          searchable: true,
          itemLabelBuilder: _fruitLabel,
          onChanged: (value) => selected = value,
        ),
      ),
    );

    await robot.openDropdown();
    robot.expectPanelOpen();

    await robot.enterSearch('ban');
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);

    await robot.selectItem('Banana');

    expect(selected, 'banana');
    robot.expectPanelClosed();
    expect(find.text('Banana'), findsOneWidget);
  });

  testWidgets('static long-list journey opens at selected item', (
    tester,
  ) async {
    final robot = DropifyRobot(tester);

    await tester.pumpWidget(
      dropifyTestApp(
        SizedBox(
          width: 280,
          child: DropifyDropdown<String>(
            entries: _longEntries(100),
            initialValue: 'item_90',
            keyOf: (item) => item,
          ),
        ),
      ),
    );

    await robot.openDropdown();

    robot.expectPanelOpen();
    robot.expectItemVisibleByKey('item_90');
  });

  testWidgets('confirmable multi-select journey cancels and applies', (
    tester,
  ) async {
    final robot = DropifyRobot(tester);
    Set<String>? selected;

    await tester.pumpWidget(
      dropifyTestApp(
        DropifyDropdown<String>.multi(
          entries: fruitEntries,
          hintText: 'Pick fruit',
          confirmable: true,
          itemLabelBuilder: _fruitLabel,
          onChanged: (values) => selected = values,
        ),
      ),
    );

    await robot.openDropdown();
    await robot.selectItem('Apple');
    await robot.cancelMultiSelect();
    robot.expectPanelClosed();
    expect(selected, isNull);

    await robot.openDropdown();
    await robot.selectItem('Apple');
    await robot.selectItem('Banana');
    await robot.applyMultiSelect();

    expect(selected, {'apple', 'banana'});
    robot.expectPanelClosed();
  });

  testWidgets('async journey retries, resolves, selects, and closes', (
    tester,
  ) async {
    final fetcher = ControlledStringFetcher();
    final robot = DropifyRobot(tester);
    String? selected;

    await tester.pumpWidget(
      dropifyTestApp(
        DropifyAsyncDropdown<String>(
          fetcher: fetcher.call,
          itemLabelBuilder: (item) => item,
          hintText: 'Pick remote fruit',
          onChanged: (value) => selected = value,
        ),
      ),
    );

    await robot.openDropdown(settle: false);
    robot.expectPanelOpen();
    expect(
      find.byKey(const ValueKey<String>('dropify.async.loading')),
      findsOneWidget,
    );

    fetcher.requests.single.fail(StateError('boom'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('dropify.async.error')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.async.retry')));
    await tester.pump();
    fetcher.requests.last.complete(const ['Remote Banana']);
    await tester.pumpAndSettle();

    await robot.selectItem('Remote Banana');

    expect(selected, 'Remote Banana');
    robot.expectPanelClosed();
  });

  testWidgets('async loaded-data journey opens at selected item', (
    tester,
  ) async {
    final fetcher = ControlledStringFetcher();
    final robot = DropifyRobot(tester);

    await tester.pumpWidget(
      dropifyTestApp(
        SizedBox(
          width: 280,
          child: DropifyAsyncDropdown<String>(
            fetcher: fetcher.call,
            itemLabelBuilder: (item) => item,
            initialValue: 'Remote 90',
            keyOf: (item) => item,
          ),
        ),
      ),
    );

    await robot.openDropdown(settle: false);
    fetcher.requests.single.complete(
      List<String>.generate(100, (index) => 'Remote $index'),
    );
    await robot.pumpUntilSettled();

    robot.expectPanelOpen();
    robot.expectItemVisibleByKey('Remote_90');
  });

  testWidgets('paginated journey loads pages and delegates search', (
    tester,
  ) async {
    final controller = DropifyPaginatedHarnessController();
    final robot = DropifyRobot(tester);

    await tester.pumpWidget(
      dropifyTestApp(DropifyPaginatedHarness(controller: controller)),
    );

    await robot.openDropdown();
    robot.expectPanelOpen();
    expect(find.text('Alpha'), findsOneWidget);
    expect(controller.fetchNextPageCalls, greaterThanOrEqualTo(1));

    await tester.pumpAndSettle();
    expect(find.text('Gamma'), findsOneWidget);

    await robot.enterSearch('ga');

    expect(controller.searchQueries, const ['ga']);
    expect(controller.pagingState.search, 'ga');
  });
}

String _fruitLabel(String value) {
  return switch (value) {
    'apple' => 'Apple',
    'banana' => 'Banana',
    'disabled' => 'Disabled',
    _ => value,
  };
}

List<DropifyEntry<String>> _longEntries(int count) {
  return [
    for (var index = 0; index < count; index++)
      DropifyEntry(value: 'item_$index', label: 'Item $index'),
  ];
}
