import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A thin wrapper that pumps a [child] widget and returns the
/// [WidgetTester] and element for inspection.
///
/// Used by every widget test to avoid repeating `testWidgets`
/// boilerplate.
class DropifyTestApp {
  DropifyTestApp._();

  /// Pumps [child] wrapped in a [MaterialApp] so that `Navigator`,
  /// `Theme`, and `Overlay` infrastructure is available.
  static Future<WidgetTester> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
    );
    return tester;
  }

  /// Pumps [child] wrapped in a [MaterialApp] with [theme].
  static Future<WidgetTester> pumpWithTheme(
    WidgetTester tester,
    Widget child, {
    required ThemeData theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(body: Center(child: child)),
      ),
    );
    return tester;
  }

  /// Pumps [child] wrapped in a [MaterialApp] inside a [Form].
  static Future<WidgetTester> pumpWithForm(
    WidgetTester tester,
    Widget child, {
    GlobalKey<FormState>? formKey,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Form(key: formKey, child: child),
          ),
        ),
      ),
    );
    return tester;
  }
}
