import 'package:flutter/material.dart';

import '../theme/dropify_theme.dart';
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
    final panelConstraints =
        constraints ??
        BoxConstraints(
          maxHeight: theme.panelMaxHeight ?? 320,
          minWidth: matchAnchorWidth ? anchorWidth : 0,
          maxWidth: matchAnchorWidth ? anchorWidth : double.infinity,
        );
    return Material(
      color: _panelColor(context, decoration),
      elevation: theme.panelElevation ?? 0,
      shadowColor: Theme.of(context).colorScheme.shadow,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      shape: _panelShape(decoration),
      clipBehavior: Clip.none,
      type: MaterialType.canvas,
      child: ConstrainedBox(
        key: const ValueKey<String>('dropify.panel'),
        constraints: panelConstraints,
        child: Padding(
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
        ),
      ),
    );
  }
}

Color? _panelColor(BuildContext context, BoxDecoration? decoration) {
  return decoration?.color ?? Theme.of(context).colorScheme.surface;
}

OutlinedBorder _panelShape(BoxDecoration? decoration) {
  final borderRadius = decoration?.borderRadius;
  return RoundedRectangleBorder(
    borderRadius: borderRadius is BorderRadius
        ? borderRadius
        : BorderRadius.zero,
    side: _panelSide(decoration?.border) ?? BorderSide.none,
  );
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
