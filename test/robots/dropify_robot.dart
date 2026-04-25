import 'package:flutter_test/flutter_test.dart';

// ignore: avoid_relative_lib_imports
import '../../example/lib/raw_demo_keys.dart';

/// Robot actions for Dropify example journeys.
class DropifyRobot {
  /// Creates a robot backed by [tester].
  const DropifyRobot(this.tester);

  /// Widget tester used by the robot.
  final WidgetTester tester;

  /// Opens the raw demo from the gallery.
  Future<void> openRawDemo() async {
    await tester.tap(find.byKey(RawDemoKeys.rawNavTile));
    await tester.pumpAndSettle();
  }

  /// Opens the raw single dropdown.
  Future<void> openRawSingle() async {
    await tester.tap(find.byKey(RawDemoKeys.singleAnchor));
    await tester.pumpAndSettle();
  }

  /// Searches the open raw dropdown.
  Future<void> search(String query) async {
    await tester.enterText(find.byKey(RawDemoKeys.searchField), query);
    await tester.pumpAndSettle();
  }

  /// Selects a raw demo row by value.
  Future<void> selectRow(String value) async {
    await tester.tap(find.byKey(RawDemoKeys.row(value)));
    await tester.pumpAndSettle();
  }
}
