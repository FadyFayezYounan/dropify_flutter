import 'package:flutter/material.dart';

import '../theme/dropify_theme.dart';
import '../theme/dropify_theme_data.dart';
import '_dropify_search_field.dart';

class DropifyPanel extends StatelessWidget {
  const DropifyPanel({
    super.key,
    required this.child,
    required this.searchable,
    required this.searchController,
    required this.onSearchChanged,
    required this.anchorWidth,
    required this.matchAnchorWidth,
    required this.confirmable,
    required this.onApply,
    required this.onCancel,
    this.searchHintText,
    this.constraints,
    this.confirmLabel,
    this.cancelLabel,
  });

  final Widget child;
  final bool searchable;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final double anchorWidth;
  final bool matchAnchorWidth;
  final BoxConstraints? constraints;
  final bool confirmable;
  final VoidCallback onApply;
  final VoidCallback onCancel;
  final String? searchHintText;
  final String? confirmLabel;
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    final theme = DropifyTheme.of(context);
    final decoration = theme.panelDecoration;
    final surface = _ResolvedPanelSurface.resolve(context, theme, decoration);
    final panelConstraints =
        constraints ??
        BoxConstraints(
          maxHeight: theme.panelMaxHeight ?? 320,
          minWidth: matchAnchorWidth ? anchorWidth : 0,
          maxWidth: matchAnchorWidth ? anchorWidth : double.infinity,
        );
    Widget panel = Padding(
      padding: theme.panelPadding ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (searchable)
            DropifySearchField(
              controller: searchController,
              onChanged: onSearchChanged,
              hintText: searchHintText,
            ),
          Flexible(child: child),
          if (confirmable)
            Padding(
              key: const ValueKey<String>('dropify.multi.footer'),
              padding: theme.footerPadding ?? EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    key: const ValueKey<String>('dropify.multi.cancel'),
                    style: theme.cancelButtonStyle,
                    onPressed: onCancel,
                    child: Text(cancelLabel ?? 'Cancel'),
                  ),
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
    );
    if (surface.usesLegacyDecoration) {
      panel = DecoratedBox(decoration: decoration!, child: panel);
    }
    return Material(
      color: surface.color,
      elevation: surface.elevation,
      shadowColor: surface.shadowColor,
      surfaceTintColor: surface.surfaceTintColor,
      shape: surface.shape,
      clipBehavior: surface.clipBehavior,
      type: surface.type,
      child: ConstrainedBox(
        key: const ValueKey<String>('dropify.panel'),
        constraints: panelConstraints,
        child: panel,
      ),
    );
  }
}

class _ResolvedPanelSurface {
  const _ResolvedPanelSurface({
    required this.type,
    required this.elevation,
    required this.clipBehavior,
    required this.usesLegacyDecoration,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.shape,
  });

  final MaterialType type;
  final Color? color;
  final double elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final ShapeBorder? shape;
  final Clip clipBehavior;
  final bool usesLegacyDecoration;

  static _ResolvedPanelSurface resolve(
    BuildContext context,
    DropifyThemeData theme,
    BoxDecoration? decoration,
  ) {
    final materialDefaults = DropifyThemeData.fromMaterial(Theme.of(context));
    final panelColor = _explicitValue(
      theme.panelColor,
      materialDefaults.panelColor,
    );
    final panelShadowColor = _explicitValue(
      theme.panelShadowColor,
      materialDefaults.panelShadowColor,
    );
    final panelSurfaceTintColor = _explicitValue(
      theme.panelSurfaceTintColor,
      materialDefaults.panelSurfaceTintColor,
    );
    final panelShape = _explicitValue(
      theme.panelShape,
      materialDefaults.panelShape,
    );
    final panelSide = _explicitValue(
      theme.panelSide,
      materialDefaults.panelSide,
    );
    final panelClipBehavior = _explicitValue(
      theme.panelClipBehavior,
      materialDefaults.panelClipBehavior,
    );
    final panelElevation =
        theme.panelElevation != null &&
            theme.panelElevation != materialDefaults.panelElevation
        ? theme.panelElevation
        : null;
    final hasExplicitPanelFields =
        panelColor != null ||
        panelShadowColor != null ||
        panelSurfaceTintColor != null ||
        panelShape != null ||
        panelSide != null ||
        panelClipBehavior != null ||
        panelElevation != null;
    if (!_isRepresentable(decoration) && !hasExplicitPanelFields) {
      return _ResolvedPanelSurface(
        type: MaterialType.transparency,
        elevation: 0,
        clipBehavior: Clip.none,
        usesLegacyDecoration: true,
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    final side = panelSide ?? _panelSide(decoration?.border);
    return _ResolvedPanelSurface(
      type: MaterialType.canvas,
      color:
          panelColor ??
          decoration?.color ??
          materialDefaults.panelColor ??
          colorScheme.surface,
      elevation: theme.panelElevation ?? materialDefaults.panelElevation ?? 0,
      shadowColor:
          panelShadowColor ??
          materialDefaults.panelShadowColor ??
          colorScheme.shadow,
      surfaceTintColor:
          panelSurfaceTintColor ??
          materialDefaults.panelSurfaceTintColor ??
          colorScheme.surfaceTint,
      shape: _panelShape(panelShape, side, decoration),
      clipBehavior:
          panelClipBehavior ?? materialDefaults.panelClipBehavior ?? Clip.none,
      usesLegacyDecoration: false,
    );
  }
}

T? _explicitValue<T>(T? value, T? defaultValue) {
  return value != null && value != defaultValue ? value : null;
}

OutlinedBorder _panelShape(
  OutlinedBorder? explicitShape,
  BorderSide? side,
  BoxDecoration? decoration,
) {
  if (explicitShape != null) {
    return explicitShape.copyWith(side: side ?? explicitShape.side);
  }
  final borderRadius = decoration?.borderRadius;
  return RoundedRectangleBorder(
    borderRadius: borderRadius is BorderRadius
        ? borderRadius
        : BorderRadius.zero,
    side: side ?? BorderSide.none,
  );
}

bool _isRepresentable(BoxDecoration? decoration) {
  if (decoration == null) {
    return true;
  }
  return decoration.gradient == null &&
      decoration.image == null &&
      decoration.backgroundBlendMode == null &&
      decoration.boxShadow == null &&
      decoration.shape == BoxShape.rectangle &&
      (decoration.borderRadius == null ||
          decoration.borderRadius is BorderRadius) &&
      (decoration.border == null || _panelSide(decoration.border) != null);
}

BorderSide? _panelSide(BoxBorder? border) {
  if (border is! Border) {
    return null;
  }
  final top = border.top;
  if (top == border.right && top == border.bottom && top == border.left) {
    return top;
  }
  return null;
}
