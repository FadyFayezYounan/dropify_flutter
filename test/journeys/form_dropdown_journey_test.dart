import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore: avoid_relative_lib_imports
import '../../example/lib/main.dart';
import '../robots/dropify_robot.dart';

void main() {
  testWidgets('form demo validates corrects and saves selection', (
    tester,
  ) async {
    final DropifyRobot robot = DropifyRobot(tester);

    await tester.pumpWidget(const DropifyExampleApp());
    await robot.openFormDemo();
    await robot.submitFormDemo();

    expect(find.text('Choose a fruit before saving'), findsOneWidget);

    await robot.openStaticSingle();
    await robot.selectDefaultRow('banana');
    await robot.submitFormDemo();

    expect(find.text('Saved fruit: banana'), findsOneWidget);
    expect(find.text('Choose a fruit before saving'), findsNothing);
    expect(find.byKey(DropifyKeys.anchor), findsNWidgets(3));
  });
}
