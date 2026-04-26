import 'package:flutter_test/flutter_test.dart';
import 'package:dropify_flutter/dropify_flutter.dart';

// ignore: avoid_relative_lib_imports
import '../../example/lib/async_demo_keys.dart';
// ignore: avoid_relative_lib_imports
import '../../example/lib/form_demo_keys.dart';
// ignore: avoid_relative_lib_imports
import '../../example/lib/paginated_demo_keys.dart';
// ignore: avoid_relative_lib_imports
import '../../example/lib/raw_demo_keys.dart';
// ignore: avoid_relative_lib_imports
import '../../example/lib/static_demo_keys.dart';

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

  /// Opens the static dropdown demo from the gallery.
  Future<void> openStaticDemo() async {
    await tester.tap(find.byKey(StaticDemoKeys.staticNavTile));
    await tester.pumpAndSettle();
  }

  /// Opens the default static single dropdown.
  Future<void> openStaticSingle() async {
    await tester.tap(find.byKey(DropifyKeys.anchor).first);
    await tester.pumpAndSettle();
  }

  /// Opens the default static multi dropdown.
  Future<void> openStaticMulti() async {
    await tester.tap(find.byKey(DropifyKeys.anchor).at(1));
    await tester.pumpAndSettle();
  }

  /// Searches the open default dropdown.
  Future<void> searchDefault(String query) async {
    await tester.enterText(find.byKey(DropifyKeys.searchField), query);
    await tester.pumpAndSettle();
  }

  /// Selects a default dropdown row by value.
  Future<void> selectDefaultRow(String value) async {
    await tester.tap(find.byKey(DropifyKeys.row(value)));
    await tester.pumpAndSettle();
  }

  /// Opens the async dropdown demo from the gallery.
  Future<void> openAsyncDemo() async {
    await tester.tap(find.byKey(AsyncDemoKeys.asyncNavTile));
    await tester.pumpAndSettle();
  }

  /// Waits for async example requests to settle.
  Future<void> settleAsyncExample() async {
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();
  }

  /// Opens the paginated dropdown demo from the gallery.
  Future<void> openPaginatedDemo() async {
    await tester.tap(find.byKey(PaginatedDemoKeys.paginatedNavTile));
    await tester.pumpAndSettle();
  }

  /// Waits for paginated example requests to settle.
  Future<void> settlePaginatedExample() async {
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
  }

  /// Opens the form dropdown demo from the gallery.
  Future<void> openFormDemo() async {
    await tester.tap(find.byKey(FormDemoKeys.formNavTile));
    await tester.pumpAndSettle();
  }

  /// Submits the form demo.
  Future<void> submitFormDemo() async {
    await tester.tap(find.byKey(FormDemoKeys.submitButton));
    await tester.pumpAndSettle();
  }
}
