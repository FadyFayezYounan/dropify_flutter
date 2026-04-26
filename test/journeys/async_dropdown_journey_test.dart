import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore: avoid_relative_lib_imports
import '../../example/lib/main.dart';
import '../robots/dropify_robot.dart';

void main() {
  testWidgets('async demo supports loading search select and retry', (
    tester,
  ) async {
    final DropifyRobot robot = DropifyRobot(tester);

    await tester.pumpWidget(const DropifyExampleApp());
    await robot.openAsyncDemo();
    await tester.tap(find.byKey(DropifyKeys.anchor).first);
    await tester.pump();

    expect(find.text('Fetching fruit...'), findsOneWidget);

    await robot.settleAsyncExample();
    await robot.searchDefault('ban');
    await robot.settleAsyncExample();

    expect(find.byKey(DropifyKeys.row('banana')), findsOneWidget);

    await robot.selectDefaultRow('banana');

    expect(find.text('Selected: banana'), findsOneWidget);

    await tester.tap(find.byKey(DropifyKeys.anchor).first);
    await tester.pump();
    await robot.searchDefault('err');
    await robot.settleAsyncExample();

    expect(find.byKey(DropifyKeys.retryButton), findsOneWidget);

    await robot.searchDefault('apple');
    await robot.settleAsyncExample();

    expect(find.byKey(DropifyKeys.row('apple')), findsOneWidget);
  });
}
