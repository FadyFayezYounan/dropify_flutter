import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/dropify_theme.dart';
import '../theme/dropify_theme_data.dart';

class DropifyMenuItemButton extends StatefulWidget {
  const DropifyMenuItemButton({
    super.key,
    this.itemKey,
    this.onPressed,
    this.onHover,
    this.requestFocusOnHover = true,
    this.onFocusChange,
    this.focusNode,
    this.autofocus = false,
    this.semanticsLabel,
    this.style,
    this.statesController,
    this.clipBehavior = Clip.none,
    this.leadingIcon,
    this.trailingIcon,
    this.selected = false,
    this.overflowAxis = Axis.horizontal,
    this.child,
  });

  final Key? itemKey;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onHover;
  final bool requestFocusOnHover;
  final ValueChanged<bool>? onFocusChange;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticsLabel;
  final ButtonStyle? style;
  final WidgetStatesController? statesController;
  final Clip clipBehavior;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool selected;
  final Axis overflowAxis;
  final Widget? child;

  bool get enabled => onPressed != null;

  @override
  State<DropifyMenuItemButton> createState() => _DropifyMenuItemButtonState();

  ButtonStyle defaultStyleOf(BuildContext context) {
    return _DropifyMenuButtonDefaults(context, selected: selected);
  }

  ButtonStyle? themeStyleOf(BuildContext context) {
    final theme = DropifyTheme.of(context);
    return ButtonStyle(
      padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(
        theme.entryPadding,
      ),
      textStyle: ButtonStyleButton.allOrNull<TextStyle?>(theme.entryTextStyle),
    );
  }

  static ButtonStyle styleFrom({
    Color? foregroundColor,
    Color? backgroundColor,
    Color? disabledForegroundColor,
    Color? disabledBackgroundColor,
    Color? shadowColor,
    Color? surfaceTintColor,
    Color? iconColor,
    double? iconSize,
    Color? disabledIconColor,
    TextStyle? textStyle,
    Color? overlayColor,
    double? elevation,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    Size? fixedSize,
    Size? maximumSize,
    MouseCursor? enabledMouseCursor,
    MouseCursor? disabledMouseCursor,
    BorderSide? side,
    OutlinedBorder? shape,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
  }) {
    return TextButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledForegroundColor: disabledForegroundColor,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      iconColor: iconColor,
      iconSize: iconSize,
      disabledIconColor: disabledIconColor,
      textStyle: textStyle,
      overlayColor: overlayColor,
      elevation: elevation,
      padding: padding,
      minimumSize: minimumSize,
      fixedSize: fixedSize,
      maximumSize: maximumSize,
      enabledMouseCursor: enabledMouseCursor,
      disabledMouseCursor: disabledMouseCursor,
      side: side,
      shape: shape,
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      FlagProperty('enabled', value: onPressed != null, ifFalse: 'DISABLED'),
    );
    properties.add(
      FlagProperty('selected', value: selected, ifTrue: 'selected'),
    );
    properties.add(DiagnosticsProperty<Key?>('itemKey', itemKey));
    properties.add(StringProperty('semanticsLabel', semanticsLabel));
    properties.add(DiagnosticsProperty<ButtonStyle?>('style', style));
    properties.add(DiagnosticsProperty<FocusNode?>('focusNode', focusNode));
    properties.add(
      EnumProperty<Clip>('clipBehavior', clipBehavior, defaultValue: Clip.none),
    );
    properties.add(
      DiagnosticsProperty<WidgetStatesController?>(
        'statesController',
        statesController,
      ),
    );
  }
}

class _DropifyMenuItemButtonState extends State<DropifyMenuItemButton> {
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _createInternalFocusNodeIfNeeded();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant DropifyMenuItemButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)?.removeListener(
        _handleFocusChange,
      );
      if (widget.focusNode != null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      _createInternalFocusNodeIfNeeded();
      _focusNode.addListener(_handleFocusChange);
      _isFocused = _focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    _internalFocusNode = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DropifyTheme.of(context);
    ButtonStyle mergedStyle =
        widget.themeStyleOf(context)?.merge(widget.defaultStyleOf(context)) ??
        widget.defaultStyleOf(context);
    if (widget.style != null) {
      mergedStyle = widget.style!.merge(mergedStyle);
    }

    Widget child = TextButton(
      onPressed: widget.enabled ? _handleSelect : null,
      onFocusChange: widget.enabled ? widget.onFocusChange : null,
      focusNode: _focusNode,
      style: mergedStyle,
      autofocus: widget.enabled && widget.autofocus,
      statesController: widget.statesController,
      clipBehavior: widget.clipBehavior,
      isSemanticButton: null,
      child: _DropifyMenuItemLabel(
        leadingIcon: widget.leadingIcon,
        trailingIcon: widget.trailingIcon,
        selectedIcon: theme.entrySelectedIcon == null
            ? null
            : Icon(
                key: const ValueKey<String>('dropify.item.selectedIcon'),
                theme.entrySelectedIcon,
                size: 18,
              ),
        selected: widget.selected,
        semanticsLabel: widget.semanticsLabel,
        overflowAxis: widget.overflowAxis,
        child: widget.child,
      ),
    );

    final decoration = _decoration(theme);
    if (decoration != null) {
      child = DecoratedBox(decoration: decoration, child: child);
    }

    if (widget.onHover != null || widget.requestFocusOnHover) {
      child = MouseRegion(
        onHover: widget.enabled ? _handlePointerHover : null,
        onExit: widget.enabled ? _handlePointerExit : null,
        child: child,
      );
    }

    return MergeSemantics(
      child: Semantics(
        key: widget.itemKey,
        button: true,
        selected: widget.selected,
        enabled: widget.enabled,
        label: widget.semanticsLabel,
        child: child,
      ),
    );
  }

  Decoration? _decoration(DropifyThemeData theme) {
    if (_isFocused && theme.entryFocusDecoration != null) {
      return theme.entryFocusDecoration;
    }
    if (_isHovered && theme.entryHoverDecoration != null) {
      return theme.entryHoverDecoration;
    }
    if (widget.selected) {
      return theme.entrySelectedDecoration;
    }
    return null;
  }

  void _handleFocusChange() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  void _handlePointerExit(PointerExitEvent event) {
    if (_isHovered) {
      widget.onHover?.call(false);
      setState(() => _isHovered = false);
    }
  }

  void _handlePointerHover(PointerHoverEvent event) {
    if (!_isHovered) {
      widget.onHover?.call(true);
      setState(() => _isHovered = true);
      if (widget.requestFocusOnHover) {
        _focusNode.requestFocus();
        FocusTraversalGroup.of(
          context,
        ).invalidateScopeData(FocusScope.of(context));
      }
    }
  }

  void _handleSelect() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.applyFocusChangesIfNeeded();
      widget.onPressed?.call();
    }, debugLabel: 'DropifyMenuItemButton.onPressed');
  }

  void _createInternalFocusNodeIfNeeded() {
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
      assert(() {
        _internalFocusNode?.debugLabel =
            '$DropifyMenuItemButton(${widget.child})';
        return true;
      }());
    }
  }
}

class _DropifyMenuItemLabel extends StatelessWidget {
  const _DropifyMenuItemLabel({
    required this.selected,
    this.leadingIcon,
    this.trailingIcon,
    this.selectedIcon,
    this.semanticsLabel,
    this.overflowAxis = Axis.horizontal,
    this.child,
  });

  final bool selected;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Widget? selectedIcon;
  final String? semanticsLabel;
  final Axis overflowAxis;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final density = Theme.of(context).visualDensity;
    final spacing = DropifyTheme.of(context).entrySpacing ?? 8;
    final horizontalPadding = math.max(4.0, spacing + density.horizontal * 2);
    Widget leading;
    if (overflowAxis == Axis.vertical) {
      leading = Expanded(
        child: ClipRect(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ?leadingIcon,
              if (child != null)
                Expanded(
                  child: ClipRect(
                    child: Padding(
                      padding: leadingIcon != null
                          ? EdgeInsetsDirectional.only(start: horizontalPadding)
                          : EdgeInsets.zero,
                      child: child,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      leading = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?leadingIcon,
          if (child != null)
            Padding(
              padding: leadingIcon != null
                  ? EdgeInsetsDirectional.only(start: horizontalPadding)
                  : EdgeInsets.zero,
              child: child,
            ),
        ],
      );
    }

    Widget result = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        leading,
        if (trailingIcon != null)
          Padding(
            padding: EdgeInsetsDirectional.only(start: horizontalPadding),
            child: trailingIcon,
          ),
        if (selected && selectedIcon != null)
          Padding(
            padding: EdgeInsetsDirectional.only(start: horizontalPadding),
            child: selectedIcon,
          ),
      ],
    );
    if (semanticsLabel != null) {
      result = Semantics(
        label: semanticsLabel,
        excludeSemantics: true,
        child: result,
      );
    }
    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      FlagProperty('selected', value: selected, ifTrue: 'selected'),
    );
    properties.add(StringProperty('semanticsLabel', semanticsLabel));
    properties.add(EnumProperty<Axis>('overflowAxis', overflowAxis));
  }
}

class _DropifyMenuButtonDefaults extends ButtonStyle {
  _DropifyMenuButtonDefaults(this.context, {required this.selected})
    : super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: AlignmentDirectional.centerStart,
      );

  final BuildContext context;
  final bool selected;

  late final DropifyThemeData _dropifyTheme = DropifyTheme.of(context);
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  WidgetStateProperty<Color?>? get backgroundColor {
    final selectedColor = _dropifyTheme.entrySelectedDecoration?.color;
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.transparent;
      }
      if (selected && selectedColor != null) {
        return selectedColor;
      }
      return Colors.transparent;
    });
  }

  @override
  WidgetStateProperty<double>? get elevation {
    return ButtonStyleButton.allOrNull<double>(0);
  }

  @override
  WidgetStateProperty<Color?>? get foregroundColor {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return _dropifyTheme.entryDisabledTextStyle?.color ??
            _colors.onSurface.withValues(alpha: 0.38);
      }
      return _dropifyTheme.entryTextStyle?.color ?? _colors.onSurface;
    });
  }

  @override
  WidgetStateProperty<Color?>? get iconColor => foregroundColor;

  @override
  WidgetStateProperty<double>? get iconSize {
    return const WidgetStatePropertyAll<double>(18);
  }

  @override
  WidgetStateProperty<Size>? get maximumSize {
    return ButtonStyleButton.allOrNull<Size>(Size.infinite);
  }

  @override
  WidgetStateProperty<Size>? get minimumSize {
    return ButtonStyleButton.allOrNull<Size>(const Size(64, 40));
  }

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return SystemMouseCursors.basic;
      }
      return SystemMouseCursors.click;
    });
  }

  @override
  WidgetStateProperty<Color?>? get overlayColor {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return _colors.onSurface.withValues(alpha: 0.1);
      }
      if (states.contains(WidgetState.hovered)) {
        return _colors.onSurface.withValues(alpha: 0.08);
      }
      if (states.contains(WidgetState.focused)) {
        return _colors.onSurface.withValues(alpha: 0.1);
      }
      return Colors.transparent;
    });
  }

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding {
    return ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(
      _dropifyTheme.entryPadding,
    );
  }

  @override
  WidgetStateProperty<OutlinedBorder>? get shape {
    final decoration = _dropifyTheme.entrySelectedDecoration;
    final borderRadius = decoration?.borderRadius;
    if (borderRadius is BorderRadius) {
      return ButtonStyleButton.allOrNull<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: borderRadius),
      );
    }
    return ButtonStyleButton.allOrNull<OutlinedBorder>(
      const RoundedRectangleBorder(),
    );
  }

  @override
  InteractiveInkFeatureFactory? get splashFactory => _theme.splashFactory;

  @override
  MaterialTapTargetSize? get tapTargetSize => _theme.materialTapTargetSize;

  @override
  WidgetStateProperty<TextStyle?> get textStyle {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return _dropifyTheme.entryDisabledTextStyle ??
            _theme.textTheme.bodyMedium;
      }
      return _dropifyTheme.entryTextStyle ?? _theme.textTheme.bodyMedium;
    });
  }

  @override
  VisualDensity? get visualDensity => _theme.visualDensity;
}

Key dropifyMenuItemKey(Object? identity, Object? fallback) {
  if (identity != null) {
    return ValueKey<String>('dropify.item.${_sanitizeIdentity(identity)}');
  }
  return ValueKey<String>('dropify.item.${_sanitizeIdentity(fallback)}');
}

String _sanitizeIdentity(Object? identity) {
  return identity?.toString().replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_') ??
      'null';
}
