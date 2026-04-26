/// A universal dropdown toolkit for Flutter.
///
/// Dropify exposes a layered API: [RawDropify] for custom dropdown chrome,
/// concrete widgets for static, async, and paginated data, and
/// [DropifyFormField] for `Form` integration.
///
/// See also:
///
///  * [DropifyDropdown], for local static entries.
///  * [DropifyAsyncDropdown], for debounced async search.
///  * [DropifyPaginatedDropdown], for incremental page loading.
///  * [DropifyTheme], for inherited visual defaults.
library;

export 'src/core/dropify_controller.dart' hide DropifyControllerScope;
export 'src/core/dropify_data_source.dart';
export 'src/core/dropify_entry.dart';
export 'src/core/dropify_state.dart';
export 'src/core/raw_dropify.dart';
export 'src/theme/dropify_theme.dart';
export 'src/theme/dropify_theme_data.dart';
export 'src/widgets/dropify_async_dropdown.dart';
export 'src/widgets/dropify_dropdown.dart';
export 'src/widgets/dropify_form_field.dart';
export 'src/widgets/dropify_keys.dart';
export 'src/widgets/dropify_paginated_dropdown.dart';
