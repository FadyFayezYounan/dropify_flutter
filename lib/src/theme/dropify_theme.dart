import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'dropify_theme_data.dart';

/// Applies Dropify theme data to a subtree.
class DropifyTheme extends InheritedTheme {
  /// Creates a Dropify theme.
  const DropifyTheme({super.key, required this.data, required super.child});

  /// Theme data for the subtree.
  final DropifyThemeData data;

  /// Returns the closest Dropify theme or Material-derived defaults.
  static DropifyThemeData of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<DropifyTheme>();
    final material = Theme.of(context);
    return inherited?.data ??
        material.extension<DropifyThemeData>() ??
        DropifyThemeData.fromMaterial(material);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return DropifyTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(DropifyTheme oldWidget) => data != oldWidget.data;
}
