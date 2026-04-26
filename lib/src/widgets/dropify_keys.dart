import 'package:flutter/widgets.dart';

/// Stable keys used by the default Dropify widgets and journey tests.
abstract final class DropifyKeys {
  /// The default dropdown anchor.
  static const Key anchor = ValueKey<String>('dropify-anchor');

  /// The default dropdown panel.
  static const Key panel = ValueKey<String>('dropify-panel');

  /// The default search field.
  static const Key searchField = ValueKey<String>('dropify-search-field');

  /// The default retry button.
  static const Key retryButton = ValueKey<String>('dropify-retry-button');

  /// The default loading-more footer.
  static const Key loadingMoreFooter = ValueKey<String>(
    'dropify-loading-more-footer',
  );

  /// The default page retry button.
  static const Key pageRetryButton = ValueKey<String>(
    'dropify-page-retry-button',
  );

  /// The default no-more-items footer.
  static const Key noMoreItemsFooter = ValueKey<String>(
    'dropify-no-more-items-footer',
  );

  /// Returns the default row key for [value].
  static Key row(Object? value) => ValueKey<String>('dropify-row-$value');

  /// Returns the default chip key for [value].
  static Key chip(Object? value) => ValueKey<String>('dropify-chip-$value');
}
