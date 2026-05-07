import 'package:flutter/material.dart';

import 'dropify_theme_data.dart';

/// Applies Dropify styling to a widget subtree.
///
/// Values from this inherited theme override the host `ThemeData` extension and
/// Material-derived defaults for descendants.
class DropifyTheme extends InheritedTheme {
  /// Creates a Dropify theme.
  ///
  /// The [data] and [child] arguments are required.
  const DropifyTheme({super.key, required this.data, required super.child});

  /// The Dropify theme data for this subtree.
  final DropifyThemeData data;

  /// Resolves Dropify theme data from the nearest package theme, host theme,
  /// and Material defaults.
  static DropifyThemeData of(BuildContext context) {
    final material = DropifyThemeData.fromMaterial(Theme.of(context));
    final extension = Theme.of(context).extension<DropifyThemeData>();
    final inherited = context
        .dependOnInheritedWidgetOfExactType<DropifyTheme>();
    return DropifyThemeData.merge(
      DropifyThemeData.merge(material, extension),
      inherited?.data,
    );
  }

  @override
  bool updateShouldNotify(DropifyTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return DropifyTheme(data: data, child: child);
  }
}
