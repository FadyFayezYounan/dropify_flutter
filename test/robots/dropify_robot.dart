import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class DropifyRobot {
  const DropifyRobot(this.tester);

  final WidgetTester tester;

  Future<void> openDropdown({bool settle = true}) async {
    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  Future<void> enterSearch(String query) async {
    await tester.enterText(
      find.byKey(const ValueKey<String>('dropify.search.field')),
      query,
    );
    await tester.pumpAndSettle();
  }

  Future<void> selectItem(String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> cancelMultiSelect() async {
    await tester.tap(
      find.byKey(const ValueKey<String>('dropify.multi.cancel')),
    );
    await tester.pumpAndSettle();
  }

  Future<void> applyMultiSelect() async {
    await tester.tap(find.byKey(const ValueKey<String>('dropify.multi.apply')));
    await tester.pumpAndSettle();
  }

  void expectPanelOpen() {
    expect(find.byKey(const ValueKey<String>('dropify.panel')), findsOneWidget);
  }

  void expectPanelClosed() {
    expect(find.byKey(const ValueKey<String>('dropify.panel')), findsNothing);
  }
}
