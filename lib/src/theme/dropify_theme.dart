import 'package:flutter/widgets.dart';

import 'dropify_theme_data.dart';

/// Applies Dropify visual defaults to descendant widgets.
class DropifyTheme extends InheritedWidget {
  /// Creates a Dropify theme.
  const DropifyTheme({super.key, required this.data, required super.child});

  /// Theme data for descendants.
  final DropifyThemeData data;

  /// Returns the nearest Dropify theme, or light defaults when none exists.
  static DropifyThemeData of(BuildContext context) {
    return maybeOf(context) ?? DropifyThemeData.light();
  }

  /// Returns the nearest Dropify theme, if one exists.
  static DropifyThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DropifyTheme>()?.data;
  }

  @override
  bool updateShouldNotify(DropifyTheme oldWidget) {
    return data != oldWidget.data;
  }
}
