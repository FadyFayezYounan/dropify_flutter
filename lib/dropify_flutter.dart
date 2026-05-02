/// Universal dropdown widgets for static, async, and paginated Flutter data.
///
/// Import this library when building Dropify dropdowns:
///
/// ```dart
/// import 'package:dropify_flutter/dropify_flutter.dart';
/// ```
///
/// The package is organized in layers. [RawDropify] provides the unstyled
/// overlay, selection, search, validation, and controller core. The raw
/// specialized widgets add static, async, or paginated data behavior. The
/// themed widgets provide Material-oriented defaults through [DropifyThemeData].
///
/// See also:
///
///  * [DropifyDropdown], a Material-styled dropdown for in-memory entries.
///  * [DropifyAsyncDropdown], a Material-styled dropdown for debounced async
///    search.
///  * [DropifyPaginatedDropdown], a Material-styled dropdown for caller-owned
///    paginated state.
library;

export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show Defaulted, Omit, PagingState, PagingStateBase;

export 'src/core/dropify_cancel_token.dart'
    show DropifyCancelToken, DropifyCancelledException;
export 'src/core/dropify_controller.dart' show DropifyController;
export 'src/core/dropify_entry.dart' show DropifyEntry;
export 'src/core/dropify_menu_body_mode.dart' show DropifyMenuBodyMode;
export 'src/core/dropify_paging_state.dart' show DropifyPagingState;
export 'src/core/dropify_selection.dart' show DropifySelectionMode;
export 'src/core/dropify_value.dart'
    show DropifyMultiValue, DropifySingleValue, DropifyValue;
export 'src/core/raw_dropify.dart'
    show
        AnchorBuilder,
        DropifyAnchorState,
        DropifyPanelState,
        PanelBuilder,
        RawDropify;
export 'src/theme/dropify_theme.dart' show DropifyTheme;
export 'src/theme/dropify_theme_data.dart' show DropifyThemeData;
export 'src/widgets/dropify_async_dropdown.dart' show DropifyAsyncDropdown;
export 'src/widgets/dropify_dropdown.dart' show DropifyDropdown;
export 'src/widgets/dropify_paginated_dropdown.dart'
    show DropifyPaginatedDropdown;
export 'src/widgets/raw_async_dropify.dart'
    show
        DropifyAsyncData,
        DropifyAsyncEmpty,
        DropifyAsyncError,
        DropifyAsyncFetcher,
        DropifyAsyncIdle,
        DropifyAsyncLoading,
        DropifyAsyncRefreshing,
        DropifyAsyncState,
        RawAsyncDropify;
export 'src/widgets/raw_paginated_dropify.dart' show RawPaginatedDropify;
export 'src/widgets/raw_static_dropify.dart' show RawStaticDropify;
