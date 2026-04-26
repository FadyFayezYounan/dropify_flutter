import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../theme/dropify_theme.dart';
import '../theme/dropify_theme_data.dart';
import 'dropify_controller.dart';
import 'dropify_selection.dart';
import 'dropify_value.dart';

/// Builds a Dropify anchor.
typedef AnchorBuilder<T> =
    Widget Function(BuildContext context, DropifyAnchorState<T> state);

/// Builds a Dropify panel body.
typedef PanelBuilder<T> =
    Widget Function(BuildContext context, DropifyPanelState<T> state);

/// Anchor state exposed to [AnchorBuilder].
@immutable
class DropifyAnchorState<T> {
  /// Creates anchor state.
  const DropifyAnchorState({
    required this.mode,
    required this.value,
    required this.values,
    required this.isOpen,
    required this.enabled,
    required this.open,
    required this.close,
    required this.clear,
    this.errorText,
  });

  /// The selection mode.
  final DropifySelectionMode mode;

  /// The current single value.
  final T? value;

  /// The current multi values.
  final Set<T> values;

  /// Whether the panel is open.
  final bool isOpen;

  /// Whether interaction is enabled.
  final bool enabled;

  /// Current validation error text.
  final String? errorText;

  /// Opens the panel.
  final VoidCallback open;

  /// Closes the panel.
  final VoidCallback close;

  /// Clears selection, or null when there is nothing to clear.
  final VoidCallback? clear;
}

/// Panel state exposed to [PanelBuilder].
@immutable
class DropifyPanelState<T> {
  /// Creates panel state.
  const DropifyPanelState({
    required this.mode,
    required this.value,
    required this.values,
    required this.searchQuery,
    required this.isSelected,
    required this.toggle,
    required this.select,
    required this.close,
    required this.focusScope,
  });

  /// The selection mode.
  final DropifySelectionMode mode;

  /// The current single value.
  final T? value;

  /// The current multi values.
  final Set<T> values;

  /// The current search query.
  final String searchQuery;

  /// Returns whether an item is selected.
  final bool Function(T item) isSelected;

  /// Toggles an item for multi mode.
  final void Function(T item) toggle;

  /// Selects an item for single mode.
  final void Function(T item) select;

  /// Closes the panel.
  final VoidCallback close;

  /// Focus node for panel traversal.
  final FocusNode focusScope;
}

/// The unstyled core Dropify dropdown.
class RawDropify<T> extends StatefulWidget {
  /// Creates a single-selection raw dropdown.
  const RawDropify({
    super.key,
    required this.panelBuilder,
    required this.anchorBuilder,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.searchController,
    this.searchable = false,
    this.searchHintText,
    this.searchDebounce = const Duration(milliseconds: 300),
    this.showClearButton = false,
    this.matchAnchorWidth = true,
    this.panelConstraints,
    this.alignmentOffset = const Offset(0, 4),
    this.useRootOverlay = false,
    this.consumeOutsideTaps = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.onOpen,
    this.onClose,
    this.validator,
    this.autovalidateMode,
    this.errorTextBuilder,
    this.keyOf,
    this.equals,
    this.onSearchChanged,
  }) : selectionMode = DropifySelectionMode.single,
       initialValues = null,
       onChangedMulti = null,
       confirmable = false,
       confirmLabel = null,
       cancelLabel = null;

  /// Creates a multi-selection raw dropdown.
  const RawDropify.multi({
    super.key,
    required this.panelBuilder,
    required this.anchorBuilder,
    this.controller,
    this.initialValues,
    ValueChanged<Set<T>>? onChanged,
    this.searchController,
    this.searchable = false,
    this.searchHintText,
    this.searchDebounce = const Duration(milliseconds: 300),
    this.showClearButton = false,
    this.matchAnchorWidth = true,
    this.panelConstraints,
    this.alignmentOffset = const Offset(0, 4),
    this.useRootOverlay = false,
    this.consumeOutsideTaps = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.onOpen,
    this.onClose,
    this.validator,
    this.autovalidateMode,
    this.errorTextBuilder,
    this.keyOf,
    this.equals,
    this.confirmable = false,
    this.confirmLabel,
    this.cancelLabel,
    this.onSearchChanged,
  }) : selectionMode = DropifySelectionMode.multi,
       initialValue = null,
       onChanged = null,
       onChangedMulti = onChanged;

  /// The selection mode.
  final DropifySelectionMode selectionMode;

  /// Optional external controller.
  final DropifyController<T>? controller;

  /// Initial single value.
  final T? initialValue;

  /// Initial multi values.
  final Set<T>? initialValues;

  /// Single value change callback.
  final ValueChanged<T?>? onChanged;

  /// Multi value change callback.
  final ValueChanged<Set<T>>? onChangedMulti;

  /// Builds the panel body.
  final PanelBuilder<T> panelBuilder;

  /// Builds the anchor.
  final AnchorBuilder<T> anchorBuilder;

  /// Optional external search controller.
  final TextEditingController? searchController;

  /// Whether the panel shows a search field.
  final bool searchable;

  /// Search field hint text.
  final String? searchHintText;

  /// Search debounce used by data widgets.
  final Duration searchDebounce;

  /// Whether the anchor should expose clear affordance.
  final bool showClearButton;

  /// Whether the panel should match the anchor width.
  final bool matchAnchorWidth;

  /// Constraints applied to the panel.
  final BoxConstraints? panelConstraints;

  /// Offset from anchor to panel.
  final Offset alignmentOffset;

  /// Whether to use the root overlay.
  final bool useRootOverlay;

  /// Whether outside taps are consumed.
  final bool consumeOutsideTaps;

  /// Whether interaction is enabled.
  final bool enabled;

  /// Whether the anchor autofocuses.
  final bool autofocus;

  /// Optional anchor focus node.
  final FocusNode? focusNode;

  /// Open callback.
  final VoidCallback? onOpen;

  /// Close callback.
  final VoidCallback? onClose;

  /// Validator for form integration.
  final FormFieldValidator<DropifyValue<T>>? validator;

  /// Autovalidate mode.
  final AutovalidateMode? autovalidateMode;

  /// Builds error text.
  final Widget Function(BuildContext, String error)? errorTextBuilder;

  /// Stable item identity resolver.
  final Object Function(T item)? keyOf;

  /// Custom equality resolver.
  final bool Function(T a, T b)? equals;

  /// Whether multi-select changes are staged until Apply.
  final bool confirmable;

  /// Apply button label.
  final String? confirmLabel;

  /// Cancel button label.
  final String? cancelLabel;

  /// Called when the search query changes.
  final ValueChanged<String>? onSearchChanged;

  @override
  State<RawDropify<T>> createState() => _RawDropifyState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      EnumProperty<DropifySelectionMode>('selectionMode', selectionMode),
    );
    properties.add(
      FlagProperty('searchable', value: searchable, ifTrue: 'searchable'),
    );
    properties.add(FlagProperty('enabled', value: enabled, ifTrue: 'enabled'));
    properties.add(
      FlagProperty('confirmable', value: confirmable, ifTrue: 'confirmable'),
    );
  }
}

class _RawDropifyState<T> extends State<RawDropify<T>> {
  final MenuController _menuController = MenuController();
  final FocusNode _panelFocusNode = FocusNode(debugLabel: 'Dropify panel');
  DropifyController<T>? _ownedController;
  TextEditingController? _ownedSearchController;
  FormFieldState<DropifyValue<T>>? _fieldState;
  Set<T>? _stagedValues;
  String _searchQuery = '';

  DropifyController<T> get _controller =>
      widget.controller ?? _ownedController!;
  TextEditingController get _searchController =>
      widget.searchController ?? _ownedSearchController!;

  @override
  void initState() {
    super.initState();
    _ownedController = widget.controller == null ? _createController() : null;
    _ownedSearchController = widget.searchController == null
        ? TextEditingController()
        : null;
    _searchQuery = _searchController.text;
    _searchController.addListener(_handleSearchChanged);
    _attachController();
  }

  @override
  void didUpdateWidget(covariant RawDropify<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      _ownedController = widget.controller == null ? _createController() : null;
      _attachController();
    }
    if (oldWidget.searchController != widget.searchController) {
      (oldWidget.searchController ?? _ownedSearchController)?.removeListener(
        _handleSearchChanged,
      );
      _ownedSearchController?.dispose();
      _ownedSearchController = widget.searchController == null
          ? TextEditingController()
          : null;
      _searchQuery = _searchController.text;
      _searchController.addListener(_handleSearchChanged);
    }
    _controller.attach(
      keyOf: widget.keyOf,
      equals: widget.equals,
      openHandler: _open,
      closeHandler: _close,
    );
  }

  DropifyController<T> _createController() {
    return widget.selectionMode == DropifySelectionMode.single
        ? DropifyController<T>.single(initialValue: widget.initialValue)
        : DropifyController<T>.multi(initialValues: widget.initialValues);
  }

  void _attachController() {
    _controller.attach(
      keyOf: widget.keyOf,
      equals: widget.equals,
      openHandler: _open,
      closeHandler: _close,
    );
    _controller.addListener(_handleControllerChanged);
  }

  void _handleControllerChanged() {
    if (mounted) {
      _fieldState?.didChange(_formValue);
      setState(() {});
    }
  }

  void _handleSearchChanged() {
    final query = _searchController.text;
    if (query == _searchQuery) {
      return;
    }
    setState(() => _searchQuery = query);
    widget.onSearchChanged?.call(query);
  }

  DropifyValue<T> get _formValue {
    return widget.selectionMode == DropifySelectionMode.single
        ? DropifySingleValue<T>(_controller.value)
        : DropifyMultiValue<T>(_controller.values);
  }

  void _open() {
    if (!widget.enabled) {
      return;
    }
    if (widget.confirmable) {
      _stagedValues = {..._controller.values};
    }
    _menuController.open();
  }

  void _close() {
    _stagedValues = null;
    _menuController.close();
  }

  void _handleOpen() {
    _controller.setOpenState(true);
    widget.onOpen?.call();
  }

  void _handleClose() {
    _stagedValues = null;
    _controller.setOpenState(false);
    widget.onClose?.call();
  }

  void _select(T item) {
    if (widget.selectionMode != DropifySelectionMode.single) {
      return;
    }
    _controller.setValue(item);
    widget.onChanged?.call(item);
    _fieldState?.didChange(_formValue);
    _close();
  }

  void _toggle(T item) {
    if (widget.selectionMode != DropifySelectionMode.multi) {
      return;
    }
    if (widget.confirmable) {
      setState(() {
        _stagedValues = dropifyToggledSet(
          _stagedValues ?? _controller.values,
          item,
          keyOf: widget.keyOf,
          equals: widget.equals,
        );
      });
      return;
    }
    _controller.toggle(item);
    widget.onChangedMulti?.call(_controller.values);
    _fieldState?.didChange(_formValue);
  }

  void _applyStaged() {
    final values = _stagedValues ?? _controller.values;
    _controller.setValues(values);
    widget.onChangedMulti?.call(_controller.values);
    _fieldState?.didChange(_formValue);
    _close();
  }

  void _clear() {
    _controller.clear();
    if (widget.selectionMode == DropifySelectionMode.single) {
      widget.onChanged?.call(null);
    } else {
      widget.onChangedMulti?.call(_controller.values);
    }
    _fieldState?.didChange(_formValue);
  }

  bool _hasSelection() {
    return widget.selectionMode == DropifySelectionMode.single
        ? _controller.value != null
        : _controller.values.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _controller.detach();
    _ownedController?.dispose();
    _searchController.removeListener(_handleSearchChanged);
    _ownedSearchController?.dispose();
    _panelFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DropifyValue<T>>(
      initialValue: _formValue,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
      onSaved: (_) {},
      builder: (field) {
        _fieldState = field;
        return RawMenuAnchor(
          controller: _menuController,
          childFocusNode: widget.focusNode,
          consumeOutsideTaps: widget.consumeOutsideTaps,
          useRootOverlay: widget.useRootOverlay,
          onOpen: _handleOpen,
          onClose: _handleClose,
          overlayBuilder: (context, info) {
            return Positioned(
              left: info.anchorRect.left + widget.alignmentOffset.dx,
              top: info.anchorRect.bottom + widget.alignmentOffset.dy,
              child: TapRegion(
                groupId: info.tapRegionGroupId,
                child: _DropifyPanel<T>(
                  width: widget.matchAnchorWidth ? info.anchorRect.width : null,
                  constraints: widget.panelConstraints,
                  searchable: widget.searchable,
                  searchHintText: widget.searchHintText,
                  searchController: _searchController,
                  state: _panelState,
                  confirmable:
                      widget.confirmable &&
                      widget.selectionMode == DropifySelectionMode.multi,
                  confirmLabel: widget.confirmLabel,
                  cancelLabel: widget.cancelLabel,
                  onApply: _applyStaged,
                  onCancel: _close,
                  panelBuilder: widget.panelBuilder,
                ),
              ),
            );
          },
          builder: (context, menuController, child) {
            final anchorState = DropifyAnchorState<T>(
              mode: widget.selectionMode,
              value: _controller.value,
              values: _controller.values,
              isOpen: _controller.isOpen,
              enabled: widget.enabled,
              errorText: field.errorText,
              open: _open,
              close: _close,
              clear: widget.enabled && widget.showClearButton && _hasSelection()
                  ? _clear
                  : null,
            );
            return Focus(
              autofocus: widget.autofocus,
              focusNode: widget.focusNode,
              child: GestureDetector(
                key: const ValueKey<String>('dropify.anchor'),
                behavior: HitTestBehavior.opaque,
                onTap: widget.enabled ? _open : null,
                child: Semantics(
                  button: true,
                  enabled: widget.enabled,
                  expanded: _controller.isOpen,
                  hint: 'Double tap to open dropdown',
                  child: widget.anchorBuilder(context, anchorState),
                ),
              ),
            );
          },
        );
      },
    );
  }

  DropifyPanelState<T> get _panelState {
    final visibleValues = widget.confirmable
        ? (_stagedValues ?? _controller.values)
        : _controller.values;
    return DropifyPanelState<T>(
      mode: widget.selectionMode,
      value: _controller.value,
      values: visibleValues,
      searchQuery: _searchQuery,
      isSelected: (item) => widget.selectionMode == DropifySelectionMode.single
          ? _controller.isSelected(item)
          : dropifyContains(
              visibleValues,
              item,
              keyOf: widget.keyOf,
              equals: widget.equals,
            ),
      toggle: _toggle,
      select: _select,
      close: _close,
      focusScope: _panelFocusNode,
    );
  }
}

class _DropifyPanel<T> extends StatelessWidget {
  const _DropifyPanel({
    required this.searchable,
    required this.searchController,
    required this.state,
    required this.confirmable,
    required this.onApply,
    required this.onCancel,
    required this.panelBuilder,
    this.width,
    this.constraints,
    this.searchHintText,
    this.confirmLabel,
    this.cancelLabel,
  });

  final double? width;
  final BoxConstraints? constraints;
  final bool searchable;
  final String? searchHintText;
  final TextEditingController searchController;
  final DropifyPanelState<T> state;
  final bool confirmable;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback onApply;
  final VoidCallback onCancel;
  final PanelBuilder<T> panelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = DropifyTheme.of(context);
    final effectiveConstraints =
        constraints ??
        BoxConstraints(
          minWidth: width ?? 0,
          maxWidth: width ?? double.infinity,
          maxHeight: theme.panelMaxHeight ?? 320,
        );
    return ConstrainedBox(
      constraints: effectiveConstraints,
      child: Material(
        key: const ValueKey<String>('dropify.panel'),
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: theme.panelDecoration ?? const BoxDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (searchable)
                Padding(
                  padding: theme.searchFieldPadding ?? const EdgeInsets.all(8),
                  child: TextField(
                    key: const ValueKey<String>('dropify.search.field'),
                    controller: searchController,
                    style: theme.searchTextStyle,
                    decoration:
                        (theme.searchInputDecoration ??
                                const InputDecoration(isDense: true))
                            .copyWith(
                              hintText: searchHintText,
                              suffixIcon: searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      key: const ValueKey<String>(
                                        'dropify.search.clear',
                                      ),
                                      icon: Icon(
                                        theme.searchClearIcon ?? Icons.clear,
                                      ),
                                      onPressed: searchController.clear,
                                    ),
                            ),
                  ),
                ),
              Flexible(child: panelBuilder(context, state)),
              if (confirmable)
                Padding(
                  key: const ValueKey<String>('dropify.multi.footer'),
                  padding: theme.footerPadding ?? const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        key: const ValueKey<String>('dropify.multi.cancel'),
                        style: theme.cancelButtonStyle,
                        onPressed: onCancel,
                        child: Text(cancelLabel ?? 'Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        key: const ValueKey<String>('dropify.multi.apply'),
                        style: theme.confirmButtonStyle,
                        onPressed: onApply,
                        child: Text(confirmLabel ?? 'Apply'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Builds a simple Material anchor used by themed widgets.
Widget buildDropifyMaterialAnchor<T>({
  required BuildContext context,
  required DropifyAnchorState<T> state,
  required String? label,
  required String? hintText,
  required String? valueText,
  required String? helperText,
  required Widget? prefixIcon,
  required Widget Function(BuildContext, String error)? errorTextBuilder,
}) {
  final theme = DropifyTheme.of(context);
  final effectiveValue = valueText;
  final decoration = InputDecoration(
    labelText: label,
    hintText: hintText,
    helperText: helperText,
    prefixIcon: prefixIcon,
    errorText: state.errorText,
    suffixIcon: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.clear != null)
          IconButton(
            key: const ValueKey<String>('dropify.anchor.clear'),
            tooltip: 'Clear',
            icon: Icon(theme.clearIcon ?? Icons.clear),
            onPressed: state.clear,
          ),
        Icon(theme.trailingIcon ?? Icons.arrow_drop_down),
      ],
    ),
    border: const OutlineInputBorder(),
  );
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      InputDecorator(
        decoration: decoration,
        isEmpty: effectiveValue == null || effectiveValue.isEmpty,
        child: Text(
          effectiveValue ?? hintText ?? '',
          style: effectiveValue == null
              ? theme.anchorHintTextStyle
              : theme.anchorValueTextStyle,
        ),
      ),
      if (state.errorText != null && errorTextBuilder != null)
        KeyedSubtree(
          key: const ValueKey<String>('dropify.validation.error'),
          child: errorTextBuilder(context, state.errorText!),
        ),
    ],
  );
}
