import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_data_source.dart';
import '../core/dropify_state.dart';
import '../core/raw_dropify.dart';
import '../theme/dropify_theme.dart';
import '../theme/dropify_theme_data.dart';
import '_dropify_anchor.dart';
import '_dropify_panel.dart';
import 'dropify_dropdown.dart';

/// Builds a footer while a paginated dropdown loads another page.
typedef DropifyNewPageProgressBuilder = Widget Function(BuildContext context);

/// Builds a footer for a failed later page in a paginated dropdown.
typedef DropifyNewPageErrorBuilder =
    Widget Function(BuildContext context, Object error, VoidCallback retry);

/// Builds a footer after a paginated dropdown reaches the end.
typedef DropifyNoMoreItemsBuilder = Widget Function(BuildContext context);

/// A searchable dropdown that loads entries one page at a time.
///
/// Use this widget for large or remote result sets. It handles first-page
/// loading, next-page loading, page-level retry, no-more-items footers, and
/// query resets through [DropifyPage] results.
///
/// {@tool snippet}
/// ```dart
/// DropifyPaginatedDropdown<String>(
///   fetchPage: (pageKey, query) async => DropifyPage(
///     entries: [DropifyEntry(value: '$pageKey', label: 'Page $pageKey')],
///     nextPageKey: pageKey + 1,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [DropifyDropdown], for local static entries.
///  * [DropifyAsyncDropdown], for non-paginated async search.
///  * [DropifyFormField], for `Form` integration.
///  * [RawDropify], for fully custom dropdown chrome.
class DropifyPaginatedDropdown<T> extends StatefulWidget {
  /// Creates a single-select paginated dropdown.
  const DropifyPaginatedDropdown({
    super.key,
    this.controller,
    required this.fetchPage,
    this.firstPageKey = 0,
    this.pageSize = 20,
    this.initialValue,
    ValueChanged<T?>? onChanged,
    this.label,
    this.hintText,
    this.errorText,
    this.searchEnabled = true,
    this.searchHint,
    this.itemBuilder,
    this.anchorBuilder,
    this.panelDecoration,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.newPageProgressBuilder,
    this.newPageErrorBuilder,
    this.noMoreItemsBuilder,
    this.theme,
    this.enabled = true,
    this.focusNode,
    this.queryDebounce = const Duration(milliseconds: 300),
  }) : _isMulti = false,
       initialValues = const <Never>[],
       minSelection = null,
       maxSelection = null,
       chipBuilder = null,
       closeOnSelect = null,
       _onSingleChanged = onChanged,
       _onMultiChanged = null;

  /// Creates a multi-select paginated dropdown.
  const DropifyPaginatedDropdown.multi({
    super.key,
    this.controller,
    required this.fetchPage,
    this.firstPageKey = 0,
    this.pageSize = 20,
    this.initialValues = const <Never>[],
    ValueChanged<List<T>>? onChanged,
    this.minSelection,
    this.maxSelection,
    this.chipBuilder,
    this.closeOnSelect = false,
    this.label,
    this.hintText,
    this.errorText,
    this.searchEnabled = true,
    this.searchHint,
    this.itemBuilder,
    this.anchorBuilder,
    this.panelDecoration,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.newPageProgressBuilder,
    this.newPageErrorBuilder,
    this.noMoreItemsBuilder,
    this.theme,
    this.enabled = true,
    this.focusNode,
    this.queryDebounce = const Duration(milliseconds: 300),
  }) : _isMulti = true,
       initialValue = null,
       _onSingleChanged = null,
       _onMultiChanged = onChanged;

  /// Optional external controller.
  final DropifyController<T>? controller;

  /// Fetches a page for the current query.
  final DropifyPageFetcher<T> fetchPage;

  /// First page key passed to [fetchPage].
  final int firstPageKey;

  /// Requested page size used by the data source.
  final int pageSize;

  /// Initial selected value for internally controlled single dropdowns.
  final T? initialValue;

  /// Initial selected values for internally controlled multi dropdowns.
  final List<T> initialValues;

  /// Minimum number of selected values for multi-select dropdowns.
  final int? minSelection;

  /// Maximum number of selected values for multi-select dropdowns.
  final int? maxSelection;

  /// Builds selected chips for multi-select dropdowns.
  final DropifyDropdownChipBuilder<T>? chipBuilder;

  /// Whether selecting an entry closes the dropdown.
  final bool? closeOnSelect;

  /// Optional label shown above the selected value or chips.
  final String? label;

  /// Text shown when there is no selection.
  final String? hintText;

  /// Optional error text shown by the default anchor.
  final String? errorText;

  /// Whether the default panel includes a search field.
  final bool searchEnabled;

  /// Hint text for the default search field.
  final String? searchHint;

  /// Builds custom rows for the default panel.
  final DropifyDropdownItemBuilder<T>? itemBuilder;

  /// Replaces the default anchor when provided.
  final DropifyAnchorBuilder<T>? anchorBuilder;

  /// Overrides the default panel decoration.
  final Decoration? panelDecoration;

  /// Builds the loading state for the first page.
  final DropifyDropdownLoadingBuilder? loadingBuilder;

  /// Builds the error state for the first page.
  final DropifyDropdownErrorBuilder? errorBuilder;

  /// Builds the empty state for the first page.
  final DropifyDropdownEmptyBuilder? emptyBuilder;

  /// Builds the loading footer for a later page.
  final DropifyNewPageProgressBuilder? newPageProgressBuilder;

  /// Builds the error footer for a later page.
  final DropifyNewPageErrorBuilder? newPageErrorBuilder;

  /// Builds the end-of-list footer.
  final DropifyNoMoreItemsBuilder? noMoreItemsBuilder;

  /// Per-widget theme override.
  final DropifyThemeData? theme;

  /// Whether the default anchor can open the dropdown.
  final bool enabled;

  /// Optional focus node for the default anchor.
  final FocusNode? focusNode;

  /// Debounce applied before query resets pagination.
  final Duration queryDebounce;

  final bool _isMulti;
  final ValueChanged<T?>? _onSingleChanged;
  final ValueChanged<List<T>>? _onMultiChanged;

  @override
  State<DropifyPaginatedDropdown<T>> createState() =>
      _DropifyPaginatedDropdownState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('isMulti', value: _isMulti, ifTrue: 'multi'));
    properties.add(IntProperty('firstPageKey', firstPageKey));
    properties.add(IntProperty('pageSize', pageSize));
    properties.add(
      FlagProperty('searchEnabled', value: searchEnabled, ifFalse: 'no search'),
    );
    properties.add(
      FlagProperty('enabled', value: enabled, ifFalse: 'disabled'),
    );
    properties.add(StringProperty('label', label, defaultValue: null));
    properties.add(StringProperty('hintText', hintText, defaultValue: null));
    properties.add(StringProperty('errorText', errorText, defaultValue: null));
    properties.add(
      DiagnosticsProperty<Duration>('queryDebounce', queryDebounce),
    );
  }
}

class _DropifyPaginatedDropdownState<T>
    extends State<DropifyPaginatedDropdown<T>> {
  DropifyController<T>? _internalController;
  late DropifyController<T> _controller;

  @override
  void initState() {
    super.initState();
    _bindController();
  }

  @override
  void didUpdateWidget(DropifyPaginatedDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget._isMulti != widget._isMulti ||
        oldWidget.minSelection != widget.minSelection ||
        oldWidget.maxSelection != widget.maxSelection) {
      _disposeInternalController();
      _bindController();
    }
  }

  @override
  void dispose() {
    _disposeInternalController();
    super.dispose();
  }

  void _bindController() {
    _internalController = widget.controller == null
        ? (widget._isMulti
              ? DropifyController<T>.multi(
                  initialValues: widget.initialValues,
                  minSelection: widget.minSelection,
                  maxSelection: widget.maxSelection,
                )
              : DropifyController<T>.single(initialValue: widget.initialValue))
        : null;
    _controller = widget.controller ?? _internalController!;
  }

  void _disposeInternalController() {
    _internalController?.dispose();
    _internalController = null;
  }

  @override
  Widget build(BuildContext context) {
    final DropifyThemeData effectiveTheme = widget.theme ??
        DropifyTheme.of(context);
    final PaginatedDropifyDataSource<T> dataSource =
        PaginatedDropifyDataSource<T>(
          fetchPage: widget.fetchPage,
          firstPageKey: widget.firstPageKey,
          pageSize: widget.pageSize,
        );
    if (widget._isMulti) {
      return RawDropify<T>.multi(
        controller: _controller,
        dataSource: dataSource,
        closeOnSelect: widget.closeOnSelect,
        queryDebounce: widget.queryDebounce,
        onSelectionChanged: _handleSelectionChanged,
        anchorBuilder:
            (
              BuildContext context,
              DropifyController<T> controller,
              Widget? child,
            ) {
              return _buildAnchor(context, controller, child, effectiveTheme);
            },
        bodyBuilder: (BuildContext context, DropifyState<T> state) {
          return _buildPanel(context, state, effectiveTheme);
        },
      );
    }
    return RawDropify<T>(
      controller: _controller,
      dataSource: dataSource,
      closeOnSelect: widget.closeOnSelect,
      queryDebounce: widget.queryDebounce,
      onSelectionChanged: _handleSelectionChanged,
      anchorBuilder:
          (
            BuildContext context,
            DropifyController<T> controller,
            Widget? child,
          ) {
            return _buildAnchor(context, controller, child, effectiveTheme);
          },
      bodyBuilder: (BuildContext context, DropifyState<T> state) {
        return _buildPanel(context, state, effectiveTheme);
      },
    );
  }

  Widget _buildAnchor(
    BuildContext context,
    DropifyController<T> controller,
    Widget? child,
    DropifyThemeData theme,
  ) {
    return widget.anchorBuilder?.call(context, controller, child) ??
        DropifyAnchor<T>(
          controller: controller,
          entries: controller.entries,
          theme: theme,
          enabled: widget.enabled,
          label: widget.label,
          hintText: widget.hintText,
          errorText: widget.errorText,
          focusNode: widget.focusNode,
          chipBuilder: widget.chipBuilder,
        );
  }

  Widget _buildPanel(
    BuildContext context,
    DropifyState<T> state,
    DropifyThemeData theme,
  ) {
    return DropifyPanel<T>(
      state: state,
      theme: theme,
      searchEnabled: widget.searchEnabled,
      searchHint: widget.searchHint,
      panelDecoration: widget.panelDecoration,
      itemBuilder: widget.itemBuilder,
      loadingBuilder: widget.loadingBuilder,
      errorBuilder: widget.errorBuilder,
      emptyBuilder: widget.emptyBuilder,
      newPageProgressBuilder: widget.newPageProgressBuilder,
      newPageErrorBuilder: widget.newPageErrorBuilder,
      noMoreItemsBuilder: widget.noMoreItemsBuilder,
    );
  }

  void _handleSelectionChanged(T? value, List<T> values) {
    if (widget._isMulti) {
      widget._onMultiChanged?.call(List<T>.unmodifiable(values));
    } else {
      widget._onSingleChanged?.call(value);
    }
  }
}
