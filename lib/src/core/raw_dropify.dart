import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../internal/_dropify_panel.dart';
import '../theme/dropify_theme.dart';
import 'dropify_controller.dart';
import 'dropify_selection.dart';
import 'dropify_value.dart';

/// Builds the closed Dropify anchor.
typedef AnchorBuilder<T> =
    Widget Function(BuildContext context, DropifyAnchorState<T> state);

/// Builds the open Dropify panel body.
typedef PanelBuilder<T> =
    Widget Function(BuildContext context, DropifyPanelState<T> state);

/// State passed to [AnchorBuilder].
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

  /// The active selection mode.
  final DropifySelectionMode mode;

  /// The selected single value.
  final T? value;

  /// The selected multi values.
  final Set<T> values;

  /// Whether the panel is open.
  final bool isOpen;

  /// Whether the anchor is enabled.
  final bool enabled;

  /// Current form validation error text, if any.
  final String? errorText;

  /// Opens the panel.
  final VoidCallback open;

  /// Closes the panel.
  final VoidCallback close;

  /// Clears selection, or null when clearing is unavailable.
  final VoidCallback? clear;
}

/// State passed to [PanelBuilder].
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

  /// The active selection mode.
  final DropifySelectionMode mode;

  /// The selected single value.
  final T? value;

  /// The selected multi values.
  final Set<T> values;

  /// The current search query.
  final String searchQuery;

  /// Whether an item is selected.
  final bool Function(T item) isSelected;

  /// Toggles a multi item.
  final void Function(T item) toggle;

  /// Selects a single item.
  final void Function(T item) select;

  /// Closes the panel.
  final VoidCallback close;

  /// The focus node associated with panel traversal.
  final FocusNode focusScope;
}

/// The unstyled Dropify dropdown core.
class RawDropify<T> extends StatefulWidget {
  /// Creates a single-selection Dropify core.
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

  /// Creates a multi-selection Dropify core.
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

  /// Called when single selection changes.
  final ValueChanged<T?>? onChanged;

  /// Called when multi selection changes.
  final ValueChanged<Set<T>>? onChangedMulti;

  /// Builds the panel body.
  final PanelBuilder<T> panelBuilder;

  /// Builds the anchor.
  final AnchorBuilder<T> anchorBuilder;

  /// Optional search text controller.
  final TextEditingController? searchController;

  /// Whether search is shown.
  final bool searchable;

  /// Search hint text.
  final String? searchHintText;

  /// Debounce duration advertised to specialized widgets.
  final Duration searchDebounce;

  /// Whether the clear affordance is exposed.
  final bool showClearButton;

  /// Whether the panel width matches the anchor width.
  final bool matchAnchorWidth;

  /// Panel constraints.
  final BoxConstraints? panelConstraints;

  /// Panel alignment offset.
  final Offset alignmentOffset;

  /// Whether to use the root overlay.
  final bool useRootOverlay;

  /// Whether outside taps are consumed.
  final bool consumeOutsideTaps;

  /// Whether interactions are enabled.
  final bool enabled;

  /// Whether the anchor autofocuses.
  final bool autofocus;

  /// Optional anchor focus node.
  final FocusNode? focusNode;

  /// Called when the panel opens.
  final VoidCallback? onOpen;

  /// Called when the panel closes.
  final VoidCallback? onClose;

  /// Form validator.
  final FormFieldValidator<DropifyValue<T>>? validator;

  /// Autovalidation mode.
  final AutovalidateMode? autovalidateMode;

  /// Optional validation error builder.
  final Widget Function(BuildContext, String error)? errorTextBuilder;

  /// Stable identity callback.
  final Object Function(T item)? keyOf;

  /// Custom equality callback.
  final bool Function(T a, T b)? equals;

  /// Whether multi-select stages changes until Apply.
  final bool confirmable;

  /// Apply button label.
  final String? confirmLabel;

  /// Cancel button label.
  final String? cancelLabel;

  /// Called whenever raw search text changes.
  final ValueChanged<String>? onSearchChanged;

  @override
  State<RawDropify<T>> createState() => _RawDropifyState<T>();
}

class _RawDropifyState<T> extends State<RawDropify<T>> {
  final MenuController _menuController = MenuController();
  final FocusNode _panelFocusNode = FocusNode(debugLabel: 'Dropify panel');
  late final bool _ownsController;
  late DropifyController<T> _controller;
  late final bool _ownsSearchController;
  late TextEditingController _searchController;
  Set<T>? _stagedValues;

  DropifySelectionIdentity<T> get _identity =>
      DropifySelectionIdentity<T>(keyOf: widget.keyOf, equals: widget.equals);

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? _createController();
    _ownsSearchController = widget.searchController == null;
    _searchController = widget.searchController ?? TextEditingController();
    _controller.addListener(_handleControllerChanged);
    _attachController();
  }

  DropifyController<T> _createController() {
    return switch (widget.selectionMode) {
      DropifySelectionMode.single => DropifyController<T>.single(
        initialValue: widget.initialValue,
      ),
      DropifySelectionMode.multi => DropifyController<T>.multi(
        initialValues: widget.initialValues,
      ),
    };
  }

  @override
  void didUpdateWidget(covariant RawDropify<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller
        ..removeListener(_handleControllerChanged)
        ..detach();
      if (_ownsController) {
        _controller.dispose();
      }
      _controller = widget.controller ?? _createController();
      _controller.addListener(_handleControllerChanged);
    }
    if (oldWidget.searchController != widget.searchController) {
      if (_ownsSearchController) {
        _searchController.dispose();
      }
      _searchController = widget.searchController ?? TextEditingController();
    }
    _attachController();
  }

  void _attachController() {
    _controller.attach(
      open: _open,
      close: _close,
      keyOf: widget.keyOf,
      equals: widget.equals,
    );
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleControllerChanged)
      ..detach();
    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsSearchController) {
      _searchController.dispose();
    }
    _panelFocusNode.dispose();
    super.dispose();
  }

  DropifyValue<T> get _formValue {
    return switch (widget.selectionMode) {
      DropifySelectionMode.single => DropifySingleValue<T>(_controller.value),
      DropifySelectionMode.multi => DropifyMultiValue<T>(_controller.values),
    };
  }

  bool get _hasSelection {
    return switch (widget.selectionMode) {
      DropifySelectionMode.single => _controller.value != null,
      DropifySelectionMode.multi => _controller.values.isNotEmpty,
    };
  }

  void _open() {
    if (!widget.enabled) {
      return;
    }
    if (widget.confirmable &&
        widget.selectionMode == DropifySelectionMode.multi) {
      _stagedValues = _controller.values;
    }
    _menuController.open();
  }

  void _close() {
    _stagedValues = null;
    _menuController.close();
  }

  void _handleOpened() {
    _controller.setOpenState(true);
    widget.onOpen?.call();
  }

  void _handleClosed() {
    _stagedValues = null;
    _controller.setOpenState(false);
    widget.onClose?.call();
  }

  void _select(T item, FormFieldState<DropifyValue<T>> field) {
    _controller.setValue(item);
    field.didChange(_formValue);
    widget.onChanged?.call(item);
    _close();
  }

  void _toggle(T item, FormFieldState<DropifyValue<T>> field) {
    if (widget.confirmable) {
      setState(() {
        _stagedValues = _identity.toggled(
          _stagedValues ?? _controller.values,
          item,
        );
      });
      return;
    }
    _controller.toggle(item);
    field.didChange(_formValue);
    widget.onChangedMulti?.call(_controller.values);
  }

  void _clear(FormFieldState<DropifyValue<T>> field) {
    _controller.clear();
    _stagedValues = null;
    field.didChange(_formValue);
    if (widget.selectionMode == DropifySelectionMode.single) {
      widget.onChanged?.call(null);
    } else {
      widget.onChangedMulti?.call(_controller.values);
    }
  }

  void _apply(FormFieldState<DropifyValue<T>> field) {
    final staged = _stagedValues;
    if (staged != null) {
      _controller.setValues(staged);
      field.didChange(_formValue);
      widget.onChangedMulti?.call(_controller.values);
    }
    _close();
  }

  void _handleReset() {
    if (widget.selectionMode == DropifySelectionMode.single) {
      _controller.setValue(widget.initialValue);
    } else {
      _controller.setValues({...?widget.initialValues});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DropifyValue<T>>(
      initialValue: _formValue,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
      onReset: _handleReset,
      builder: (field) {
        final anchorState = DropifyAnchorState<T>(
          mode: widget.selectionMode,
          value: _controller.value,
          values: _controller.values,
          isOpen: _controller.isOpen,
          enabled: widget.enabled,
          errorText: field.errorText,
          open: _open,
          close: _close,
          clear: widget.enabled && widget.showClearButton && _hasSelection
              ? () => _clear(field)
              : null,
        );
        return RawMenuAnchor(
          controller: _menuController,
          childFocusNode: widget.focusNode,
          useRootOverlay: widget.useRootOverlay,
          consumeOutsideTaps: widget.consumeOutsideTaps,
          onOpen: _handleOpened,
          onClose: _handleClosed,
          overlayBuilder: (context, info) {
            final theme = DropifyTheme.of(context);
            final baseConstraints = widget.panelConstraints;
            final defaultMaxHeight = theme.panelMaxHeight ?? 320;
            final requestedMaxHeight = _finiteOr(
              baseConstraints?.maxHeight,
              defaultMaxHeight,
            );
            final belowTop = info.anchorRect.bottom + widget.alignmentOffset.dy;
            final belowSpace = math.max(
              0.0,
              info.overlaySize.height - belowTop,
            );
            final aboveSpace = math.max(
              0.0,
              info.anchorRect.top - widget.alignmentOffset.dy,
            );
            final placeAbove =
                belowSpace < requestedMaxHeight && aboveSpace > belowSpace;
            final availableHeight = placeAbove ? aboveSpace : belowSpace;
            final panelMaxHeight = math.min(
              requestedMaxHeight,
              availableHeight,
            );
            final top = placeAbove
                ? math.max(
                    0.0,
                    info.anchorRect.top -
                        widget.alignmentOffset.dy -
                        panelMaxHeight,
                  )
                : belowTop;
            final requestedMaxWidth = _finiteOr(
              baseConstraints?.maxWidth,
              widget.matchAnchorWidth
                  ? info.anchorRect.width
                  : info.overlaySize.width,
            );
            final clampWidth = math.min(
              requestedMaxWidth,
              info.overlaySize.width,
            );
            final desiredLeft =
                info.anchorRect.left + widget.alignmentOffset.dx;
            final left = desiredLeft
                .clamp(0.0, math.max(0.0, info.overlaySize.width - clampWidth))
                .toDouble();
            final availableWidth = math.max(0.0, info.overlaySize.width - left);
            final panelMaxWidth = math.min(requestedMaxWidth, availableWidth);
            final requestedMinWidth =
                baseConstraints?.minWidth ??
                (widget.matchAnchorWidth ? info.anchorRect.width : 0.0);
            final panelMinWidth = math.min(requestedMinWidth, panelMaxWidth);
            final requestedMinHeight = baseConstraints?.minHeight ?? 0.0;
            final panelConstraints = BoxConstraints(
              minWidth: panelMinWidth,
              maxWidth: panelMaxWidth,
              minHeight: math.min(requestedMinHeight, panelMaxHeight),
              maxHeight: panelMaxHeight,
            );
            final panelState = DropifyPanelState<T>(
              mode: widget.selectionMode,
              value: _controller.value,
              values: _stagedValues ?? _controller.values,
              searchQuery: _searchController.text,
              isSelected: (item) {
                if (widget.confirmable) {
                  return _identity.contains(
                    _stagedValues ?? _controller.values,
                    item,
                  );
                }
                return _controller.isSelected(item);
              },
              toggle: (item) => _toggle(item, field),
              select: (item) => _select(item, field),
              close: _close,
              focusScope: _panelFocusNode,
            );
            return Positioned(
              left: left,
              top: top,
              child: TapRegion(
                groupId: info.tapRegionGroupId,
                onTapOutside: (_) => _close(),
                child: Focus(
                  focusNode: _panelFocusNode,
                  autofocus: true,
                  child: Shortcuts(
                    shortcuts: const <ShortcutActivator, Intent>{
                      SingleActivator(LogicalKeyboardKey.escape):
                          DismissIntent(),
                    },
                    child: Actions(
                      actions: <Type, Action<Intent>>{
                        DismissIntent: CallbackAction<DismissIntent>(
                          onInvoke: (_) {
                            _close();
                            return null;
                          },
                        ),
                      },
                      child: DropifyPanel(
                        anchorWidth: info.anchorRect.width,
                        matchAnchorWidth: widget.matchAnchorWidth,
                        constraints: panelConstraints,
                        searchable: widget.searchable,
                        searchController: _searchController,
                        searchHintText: widget.searchHintText,
                        onSearchChanged: (query) {
                          setState(() {});
                          widget.onSearchChanged?.call(query);
                        },
                        confirmable:
                            widget.confirmable &&
                            widget.selectionMode == DropifySelectionMode.multi,
                        confirmLabel: widget.confirmLabel,
                        cancelLabel: widget.cancelLabel,
                        onApply: () => _apply(field),
                        onCancel: _close,
                        child: widget.panelBuilder(context, panelState),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          builder: (context, controller, child) {
            return Focus(
              autofocus: widget.autofocus,
              focusNode: widget.focusNode,
              child: widget.anchorBuilder(context, anchorState),
            );
          },
        );
      },
    );
  }
}

double _finiteOr(double? value, double fallback) {
  return value != null && value.isFinite ? value : fallback;
}
