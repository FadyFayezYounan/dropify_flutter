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
    final panelConstraints =
        constraints ??
        BoxConstraints(
          maxHeight: theme.panelMaxHeight ?? 320,
          minWidth: matchAnchorWidth ? anchorWidth : 0,
          maxWidth: matchAnchorWidth ? anchorWidth : double.infinity,
        );
    return Material(
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: panelConstraints,
        child: DecoratedBox(
          key: const ValueKey<String>('dropify.panel'),
          decoration: theme.panelDecoration ?? const BoxDecoration(),
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
      ),
    );
  }
}
