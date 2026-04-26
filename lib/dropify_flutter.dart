library;

/// A universal Flutter dropdown package for static, async, paginated,
/// multi-select, and form use cases.
///
/// ## Quick start
///
/// ```dart
/// import 'package:dropify_flutter/dropify_flutter.dart';
///
/// DropifyDropdown<String>(
///   entries: const [
///     DropifyEntry(value: 'apple', label: 'Apple'),
///     DropifyEntry(value: 'banana', label: 'Banana'),
///   ],
///   label: 'Fruit',
///   searchable: true,
///   onChanged: (value) {},
/// )
/// ```

// Core (Layer 1)
export 'src/core/raw_dropify.dart' show RawDropify;
export 'src/core/dropify_controller.dart' show DropifyController;
export 'src/core/dropify_entry.dart' show DropifyEntry;
export 'src/core/dropify_selection.dart' show DropifySelectionMode;
export 'src/core/dropify_value.dart'
    show DropifyValue, DropifySingleValue, DropifyMultiValue;
export 'src/core/dropify_cancel_token.dart'
    show DropifyCancelToken, DropifyCancelledException;
export 'src/core/dropify_paging_state.dart' show DropifyPagingState;

// Specialized (Layer 2)
export 'src/widgets/raw_static_dropify.dart' show RawStaticDropify;
export 'src/widgets/raw_async_dropify.dart'
    show RawAsyncDropify, DropifyAsyncState, DropifyAsyncFetcher;
export 'src/widgets/raw_paginated_dropify.dart' show RawPaginatedDropify;

// Themed (Layer 3)
export 'src/widgets/dropify_dropdown.dart' show DropifyDropdown;
export 'src/widgets/dropify_async_dropdown.dart' show DropifyAsyncDropdown;
export 'src/widgets/dropify_paginated_dropdown.dart'
    show DropifyPaginatedDropdown;

// Theme
export 'src/theme/dropify_theme.dart' show DropifyTheme;
export 'src/theme/dropify_theme_data.dart' show DropifyThemeData;

// Re-export paging types so consumers don't need to import
// infinite_scroll_pagination directly.
export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingState, PagingStateBase, Defaulted, Omit;
