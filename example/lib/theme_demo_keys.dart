import 'package:flutter/widgets.dart';

/// Stable keys used by the theming example and journey tests.
abstract final class ThemeDemoKeys {
  /// The theming page navigation tile.
  static const Key themeNavTile = ValueKey<String>('theme-demo-nav-tile');

  /// Selects the light Dropify theme.
  static const Key lightButton = ValueKey<String>('theme-demo-light-button');

  /// Selects the dark Dropify theme.
  static const Key darkButton = ValueKey<String>('theme-demo-dark-button');

  /// Selects the custom Dropify theme.
  static const Key customButton = ValueKey<String>('theme-demo-custom-button');
}
