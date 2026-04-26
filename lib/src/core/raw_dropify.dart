import 'package:flutter/material.dart';

import 'dropify_controller.dart';
import 'dropify_selection.dart';
import 'dropify_value.dart';
import '../internal/dropify_anchor_state.dart';
import '../internal/dropify_panel_state.dart';
import '../internal/_dropify_panel.dart';
import '../internal/_dropify_focus_scope.dart';
import '../internal/_debouncer.dart';

/// The unstyled core dropdown widget.
///
/// [RawDropify] handles anchor rendering, overlay panel layout, selection
/// state, search, focus, validation, and controller attachment. It does
/// **not** know how to render list items — that is delegated to
/// [panelBuilder].
class RawDropify<T> extends StatefulWidget {
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
  }) : selectionMode = DropifySelectionMode.single,
       onChangedMulti = null,
       initialValues = null,
       confirmable = false,
       confirmLabel = null,
       cancelLabel = null;

  const RawDropify.multi({
    super.key,
    required this.panelBuilder,
    required this.anchorBuilder,
    this.controller,
    this.onChangedMulti,
    this.initialValues,
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
  }) : selectionMode = DropifySelectionMode.multi,
       initialValue = null,
       onChanged = null;

  final DropifySelectionMode selectionMode;
  final DropifyController<T>? controller;
  final T? initialValue;
  final Set<T>? initialValues;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<Set<T>>? onChangedMulti;
  final PanelBuilder<T> panelBuilder;
  final AnchorBuilder<T> anchorBuilder;

  final TextEditingController? searchController;
  final bool searchable;
  final String? searchHintText;
  final Duration searchDebounce;

  final bool showClearButton;
  final bool matchAnchorWidth;
  final BoxConstraints? panelConstraints;
  final Offset alignmentOffset;
  final bool useRootOverlay;
  final bool consumeOutsideTaps;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;

  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  final FormFieldValidator<DropifyValue<T>>? validator;
  final AutovalidateMode? autovalidateMode;
  final Widget Function(BuildContext, String error)? errorTextBuilder;

  final Object Function(T item)? keyOf;
  final bool Function(T a, T b)? equals;

  final bool confirmable;
  final String? confirmLabel;
  final String? cancelLabel;

  @override
  State<RawDropify<T>> createState() => _RawDropifyState<T>();
}

class _RawDropifyState<T> extends State<RawDropify<T>> {
  late DropifyController<T> _controller;
  bool _ownsController = true;
  final FocusNode _anchorFocusNode = FocusNode();
  final GlobalKey _anchorKey = GlobalKey();
  TextEditingController? _internalSearchController;
  final DropifyFocusScope _focusScope = DropifyFocusScope();
  late Debouncer _searchDebouncer;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey<FormFieldState<DropifyValue<T>>> _formFieldKey =
      GlobalKey<FormFieldState<DropifyValue<T>>>();

  Set<T>? _stagedValues;

  DropifyController<T> get _effectiveController => _controller;

  @override
  void initState() {
    super.initState();
    _searchDebouncer = Debouncer(duration: widget.searchDebounce);

    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      if (widget.selectionMode == DropifySelectionMode.single) {
        _controller = DropifyController<T>.single(
          initialValue: widget.initialValue,
        );
      } else {
        _controller = DropifyController<T>.multi(
          initialValues: widget.initialValues,
        );
      }
    }

    _controller.attachToWidget(keyOf: widget.keyOf, equals: widget.equals);

    if (widget.searchController != null) {
      _internalSearchController = widget.searchController;
    } else {
      _internalSearchController = TextEditingController();
      _internalSearchController!.addListener(_onSearchChanged);
    }

    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.removeListener(_onControllerChanged);
    _controller.detachFromWidget();
    if (_ownsController) {
      _controller.dispose();
    }
    _searchDebouncer.dispose();
    _focusScope.dispose();
    _anchorFocusNode.dispose();
    if (widget.searchController == null) {
      _internalSearchController?.removeListener(_onSearchChanged);
      _internalSearchController?.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _open() {
    if (!widget.enabled) {
      return;
    }
    _controller.open();
    widget.onOpen?.call();

    if (widget.confirmable &&
        widget.selectionMode == DropifySelectionMode.multi) {
      _stagedValues = Set<T>.from(_controller.values);
    }

    _showOverlay();
  }

  void _close() {
    _controller.close();
    widget.onClose?.call();

    if (widget.confirmable &&
        widget.selectionMode == DropifySelectionMode.multi) {
      _stagedValues = null;
    }
    _removeOverlay();
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return _buildOverlay(overlayContext);
      },
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.consumeOutsideTaps ? () {} : null,
          behavior: HitTestBehavior.opaque,
          child: GestureDetector(
            onTap: _close,
            child: Container(color: Colors.transparent),
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: widget.alignmentOffset,
          child: TapRegion(
            onTapOutside: (_) => _close(),
            child: DropifyPanel<T>(
              mode: widget.selectionMode,
              controller: _effectiveController,
              panelBuilder: widget.panelBuilder,
              onSelect: _select,
              onToggle: _toggle,
              onClose: _close,
              searchable: widget.searchable,
              searchController: _internalSearchController,
              searchHintText: widget.searchHintText,
              isSelectedFn: _isSelected,
              focusScopeNode: _focusScope.node,
              matchAnchorWidth: widget.matchAnchorWidth,
              panelConstraints: widget.panelConstraints,
              confirmable: widget.confirmable,
              confirmLabel: widget.confirmLabel,
              cancelLabel: widget.cancelLabel,
              onApply: _applyStaged,
              onCancel: _cancelStaged,
            ),
          ),
        ),
      ],
    );
  }

  void _select(T item) {
    if (widget.selectionMode == DropifySelectionMode.single) {
      _controller.setValue(item);
      widget.onChanged?.call(item);
      _close();
    }
  }

  void _toggle(T item) {
    if (widget.confirmable &&
        widget.selectionMode == DropifySelectionMode.multi) {
      _toggleStaged(item);
    } else if (widget.selectionMode == DropifySelectionMode.multi) {
      _controller.toggle(item);
      widget.onChangedMulti?.call(_controller.values);
    }
  }

  void _toggleStaged(T item) {
    _stagedValues ??= Set<T>.from(_controller.values);
    if (_isStagedSelected(item)) {
      _stagedValues!.remove(item);
    } else {
      _stagedValues!.add(item);
    }
    if (mounted) {
      setState(() {});
    }
  }

  bool _isStagedSelected(T item) {
    return _stagedValues?.contains(item) ?? _controller.isSelected(item);
  }

  bool _isSelected(T item) {
    if (widget.confirmable &&
        widget.selectionMode == DropifySelectionMode.multi) {
      return _isStagedSelected(item);
    }
    if (widget.selectionMode == DropifySelectionMode.single) {
      return _controller.value == item;
    }
    return _controller.isSelected(item);
  }

  void _applyStaged() {
    if (_stagedValues != null) {
      _controller.setValues(_stagedValues!);
      widget.onChangedMulti?.call(Set<T>.from(_stagedValues!));
      _stagedValues = null;
    }
  }

  void _cancelStaged() {
    _stagedValues = null;
    _close();
  }

  void _clear() {
    _controller.clear();
    if (widget.selectionMode == DropifySelectionMode.single) {
      widget.onChanged?.call(null);
    } else {
      widget.onChangedMulti?.call(<T>{});
    }
    _close();
  }

  bool get _hasSelection {
    if (widget.selectionMode == DropifySelectionMode.single) {
      return _controller.value != null;
    }
    return _controller.values.isNotEmpty;
  }

  DropifyValue<T> get _currentFormValue {
    if (widget.selectionMode == DropifySelectionMode.single) {
      return DropifySingleValue<T>(_controller.value);
    }
    return DropifyMultiValue<T>(_controller.values);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DropifyValue<T>>(
      key: _formFieldKey,
      initialValue: _currentFormValue,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
      enabled: widget.enabled,
      builder: (FormFieldState<DropifyValue<T>> field) {
        final errorText = field.errorText;
        final anchorState = DropifyAnchorState<T>(
          mode: widget.selectionMode,
          value: widget.selectionMode == DropifySelectionMode.single
              ? _controller.value
              : null,
          values: widget.selectionMode == DropifySelectionMode.multi
              ? _controller.values
              : <T>{},
          isOpen: _controller.isOpen,
          enabled: widget.enabled,
          errorText: errorText,
          open: _open,
          close: _close,
          clear: _hasSelection ? _clear : null,
        );

        return CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            key: _anchorKey,
            onTap: widget.enabled ? _open : null,
            child: widget.anchorBuilder(context, anchorState),
          ),
        );
      },
    );
  }
}
