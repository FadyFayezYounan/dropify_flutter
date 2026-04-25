import 'package:flutter/widgets.dart';

/// Stable keys used by the raw Dropify example and journey tests.
abstract final class RawDemoKeys {
  /// The raw page navigation tile.
  static const Key rawNavTile = ValueKey<String>('raw-demo-nav-tile');

  /// The single-select raw anchor.
  static const Key singleAnchor = ValueKey<String>('raw-demo-single-anchor');

  /// The multi-select raw anchor.
  static const Key multiAnchor = ValueKey<String>('raw-demo-multi-anchor');

  /// The raw search field.
  static const Key searchField = ValueKey<String>('raw-demo-search-field');

  /// The raw dropdown panel.
  static const Key panel = ValueKey<String>('raw-demo-panel');

  /// Returns the key for an item row.
  static Key row(String value) => ValueKey<String>('raw-demo-row-$value');
}
