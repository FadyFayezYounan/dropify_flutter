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
}

String _fruitLabel(String value) {
  return switch (value) {
    'apple' => 'Apple',
    'banana' => 'Banana',
    'disabled' => 'Disabled',
    _ => value,
  };
}
