import 'package:flutter_test/flutter_test.dart';

// ignore: avoid_relative_lib_imports
import '../../example/lib/main.dart';
// ignore: avoid_relative_lib_imports
import '../../example/lib/raw_demo_keys.dart';
import '../robots/dropify_robot.dart';

void main() {
  testWidgets('raw demo opens searches and selects with stable keys', (
    tester,
  ) async {
    final DropifyRobot robot = DropifyRobot(tester);

    await tester.pumpWidget(const DropifyExampleApp());
    await robot.openRawDemo();
    await robot.openRawSingle();
    await robot.search('ban');

    expect(find.byKey(RawDemoKeys.row('apple')), findsNothing);
    expect(find.byKey(RawDemoKeys.row('banana')), findsOneWidget);

    await robot.selectRow('banana');

    expect(find.text('banana'), findsOneWidget);

    await robot.openRawMulti();
    await robot.selectRow('apple');
    await robot.selectRow('coconut');

    expect(find.text('apple, coconut'), findsOneWidget);
  });
}
