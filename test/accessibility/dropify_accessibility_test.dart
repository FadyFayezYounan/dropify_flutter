import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/dropify_fixtures.dart';
import '../helpers/dropify_test_app.dart';

void main() {
  testWidgets('default anchor exposes button semantics and expanded state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      dropifyTestApp(
        const DropifyDropdown<String>(
          entries: fruitEntries,
          hintText: 'Pick fruit',
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byKey(const ValueKey<String>('dropify.anchor'))),
      matchesSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        isExpanded: false,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byKey(const ValueKey<String>('dropify.anchor'))),
      matchesSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        isExpanded: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );

    semantics.dispose();
  });

  testWidgets('default anchor opens with keyboard activation', (tester) async {
    await tester.pumpWidget(
      dropifyTestApp(
        const DropifyDropdown<String>(
          entries: fruitEntries,
          hintText: 'Pick fruit',
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('dropify.panel')), findsOneWidget);
  });
}
