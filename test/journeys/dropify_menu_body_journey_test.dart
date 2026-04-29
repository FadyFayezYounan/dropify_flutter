import 'package:dropify_flutter/dropify_flutter.dart';
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
}

String _fruitLabel(String value) {
  return switch (value) {
    'apple' => 'Apple',
    'banana' => 'Banana',
    'disabled' => 'Disabled',
    _ => value,
  };
}
