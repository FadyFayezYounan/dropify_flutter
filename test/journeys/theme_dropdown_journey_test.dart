import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore: avoid_relative_lib_imports
import '../../example/lib/main.dart';
import '../robots/dropify_robot.dart';

void main() {
  testWidgets('theme demo switches themes and keeps dropdowns usable', (
    tester,
  ) async {
    final DropifyRobot robot = DropifyRobot(tester);

    await tester.pumpWidget(const DropifyExampleApp());
    await robot.openThemeDemo();
    await robot.selectCustomTheme();
    await robot.openStaticSingle();
    await robot.selectDefaultRow('banana');

    expect(find.text('Banana'), findsOneWidget);
    expect(find.byKey(DropifyKeys.anchor), findsWidgets);
  });
}
