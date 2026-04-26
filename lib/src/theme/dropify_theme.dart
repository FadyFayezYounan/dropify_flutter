import 'package:flutter/material.dart';

import 'dropify_theme_data.dart';

/// An inherited widget that provides [DropifyThemeData] to its descendants.
///
/// Place a [DropifyTheme] above any Dropify widgets in the tree to apply
/// a shared set of styling tokens.
///
/// {@tool snippet}
/// ```dart
/// DropifyTheme(
///   data: DropifyThemeData(
///     panelMaxHeight: 400,
///   ),
///   child: MyApp(),
/// )
/// ```
/// {@end-tool}
class DropifyTheme extends InheritedTheme {
  const DropifyTheme({super.key, required this.data, required super.child});

  /// The theme data for the subtree.
  final DropifyThemeData data;

  /// Returns the nearest [DropifyThemeData] ancestor.
  ///
  /// Falls back to [DropifyThemeData.fromMaterial] if no [DropifyTheme]
  /// ancestor exists in the tree and no [ThemeExtension] is registered.
  static DropifyThemeData of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<DropifyTheme>();
    if (inherited != null) {
      return inherited.data;
    }
    final extension = Theme.of(context).extension<DropifyThemeData>();
    if (extension != null) {
      return extension;
    }
    return DropifyThemeData.fromMaterial(Theme.of(context));
  }

  @override
  bool updateShouldNotify(covariant DropifyTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return DropifyTheme(data: data, child: child);
  }
}
