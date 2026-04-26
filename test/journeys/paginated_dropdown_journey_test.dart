import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore: avoid_relative_lib_imports
import '../../example/lib/main.dart';
import '../robots/dropify_robot.dart';

void main() {
  testWidgets('paginated demo supports load select and page retry', (
    tester,
  ) async {
    final DropifyRobot robot = DropifyRobot(tester);

    await tester.pumpWidget(const DropifyExampleApp());
    await robot.openPaginatedDemo();
    await tester.tap(find.byKey(DropifyKeys.anchor).first);
    await robot.settlePaginatedExample();

    expect(find.byKey(DropifyKeys.row('item-1')), findsOneWidget);

    await tester.drag(find.byType(Scrollable).last, const Offset(0, -700));
    await robot.settlePaginatedExample();

    await tester.scrollUntilVisible(
      find.byKey(DropifyKeys.row('item-21')),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byKey(DropifyKeys.row('item-21')), findsOneWidget);

    await tester.drag(find.byType(Scrollable).last, const Offset(0, -900));
    await robot.settlePaginatedExample();

    await tester.scrollUntilVisible(
      find.byKey(DropifyKeys.pageRetryButton),
      120,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.byKey(DropifyKeys.pageRetryButton), findsOneWidget);

    await tester.tap(find.byKey(DropifyKeys.pageRetryButton));
    await robot.settlePaginatedExample();

    expect(find.byKey(DropifyKeys.row('item-41')), findsOneWidget);

    await tester.tap(find.byKey(DropifyKeys.row('item-41')));
    await tester.pumpAndSettle();

    expect(find.text('Selected: item-41'), findsOneWidget);
  });
}
