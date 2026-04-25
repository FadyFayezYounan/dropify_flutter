import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_data_source.dart';
import '../core/dropify_entry.dart';
import '../core/dropify_state.dart';
import '../core/raw_dropify.dart';
import '../theme/dropify_theme.dart';
import '../theme/dropify_theme_data.dart';
import '_dropify_anchor.dart';
import '_dropify_panel.dart';

/// Builds a custom row for a default static Dropify dropdown panel.
typedef DropifyDropdownItemBuilder<T> =
    Widget Function(
      BuildContext context,
      DropifyEntry<T> entry,
      bool selected,
      VoidCallback? onSelect,
    );

/// Builds a chip for a selected value in a multi-select Dropify dropdown.
typedef DropifyDropdownChipBuilder<T> =
    Widget Function(
      BuildContext context,
      DropifyEntry<T> entry,
      VoidCallback? onDeleted,
    );

/// Builds the empty state for a default Dropify dropdown panel.
typedef DropifyDropdownEmptyBuilder =
    Widget Function(BuildContext context, String query);

/// A searchable static dropdown built on [RawDropify].
class DropifyDropdown<T> extends StatefulWidget {
  /// Creates a single-select static dropdown.
  const DropifyDropdown({
    super.key,
    this.controller,
    required this.entries,
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
    this.emptyBuilder,
    this.staticMatcher,
    this.theme,
    this.enabled = true,
    this.focusNode,
  }) : _isMulti = false,
       initialValues = const <Never>[],
       minSelection = null,
       maxSelection = null,
       chipBuilder = null,
       closeOnSelect = null,
       _onSingleChanged = onChanged,
       _onMultiChanged = null;

  /// Creates a multi-select static dropdown.
  const DropifyDropdown.multi({
    super.key,
    this.controller,
    required this.entries,
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
    this.emptyBuilder,
    this.staticMatcher,
    this.theme,
    this.enabled = true,
    this.focusNode,
  }) : _isMulti = true,
       initialValue = null,
       _onSingleChanged = null,
       _onMultiChanged = onChanged;

  /// Optional external controller.
  final DropifyController<T>? controller;

  /// Entries available to the dropdown.
  final List<DropifyEntry<T>> entries;

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

  /// Builds the default panel empty state.
  final DropifyDropdownEmptyBuilder? emptyBuilder;

  /// Overrides static filtering.
  final DropifyStaticMatcher<T>? staticMatcher;

  /// Per-widget theme override.
  final DropifyThemeData? theme;

  /// Whether the default anchor can open the dropdown.
  final bool enabled;

  /// Optional focus node for the default anchor.
  final FocusNode? focusNode;

  final bool _isMulti;
  final ValueChanged<T?>? _onSingleChanged;
  final ValueChanged<List<T>>? _onMultiChanged;

  @override
  State<DropifyDropdown<T>> createState() => _DropifyDropdownState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<DropifyEntry<T>>('entries', entries));
    properties.add(FlagProperty('isMulti', value: _isMulti, ifTrue: 'multi'));
    properties.add(
      FlagProperty('searchEnabled', value: searchEnabled, ifFalse: 'no search'),
    );
    properties.add(
      FlagProperty('enabled', value: enabled, ifFalse: 'disabled'),
    );
    properties.add(StringProperty('label', label, defaultValue: null));
    properties.add(StringProperty('hintText', hintText, defaultValue: null));
    properties.add(StringProperty('errorText', errorText, defaultValue: null));
  }
}

class _DropifyDropdownState<T> extends State<DropifyDropdown<T>> {
  DropifyController<T>? _internalController;
  late DropifyController<T> _controller;

  @override
  void initState() {
    super.initState();
    _bindController();
  }

  @override
  void didUpdateWidget(DropifyDropdown<T> oldWidget) {
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
    final DropifyThemeData effectiveTheme =
        widget.theme ??
        DropifyTheme.maybeOf(context) ??
        DropifyThemeData.light();
    final StaticDropifyDataSource<T> dataSource = StaticDropifyDataSource<T>(
      entries: widget.entries,
    );
    if (widget._isMulti) {
      return RawDropify<T>.multi(
        controller: _controller,
        dataSource: dataSource,
        staticMatcher: widget.staticMatcher,
        closeOnSelect: widget.closeOnSelect,
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
      staticMatcher: widget.staticMatcher,
      closeOnSelect: widget.closeOnSelect,
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
          entries: widget.entries,
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
      emptyBuilder: widget.emptyBuilder,
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
