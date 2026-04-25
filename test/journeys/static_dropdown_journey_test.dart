import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore: avoid_relative_lib_imports
import '../../example/lib/main.dart';
import '../robots/dropify_robot.dart';

void main() {
  testWidgets('static demo supports single and multi happy paths', (
    tester,
  ) async {
    final DropifyRobot robot = DropifyRobot(tester);

    await tester.pumpWidget(const DropifyExampleApp());
    await robot.openStaticDemo();
    await robot.openStaticSingle();
    await robot.searchDefault('ban');

    expect(find.byKey(DropifyKeys.row('apple')), findsNothing);
    expect(find.byKey(DropifyKeys.row('banana')), findsOneWidget);

    await robot.selectDefaultRow('banana');

    expect(find.text('Selected: banana'), findsOneWidget);

    await robot.openStaticMulti();
    await robot.selectDefaultRow('coconut');

    expect(find.byKey(DropifyKeys.chip('coconut')), findsOneWidget);
    expect(find.text('Selected: apple, coconut'), findsOneWidget);
  });
}
