import 'package:flutter/material.dart';

import '../core/raw_dropify.dart';
import '../theme/dropify_theme.dart';

class DropifyAnchor extends StatelessWidget {
  const DropifyAnchor({super.key, required this.state, required this.child});

  final DropifyAnchorState<Object?> state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey<String>('dropify.anchor'),
      button: true,
      enabled: state.enabled,
      expanded: state.isOpen,
      hint: state.enabled ? 'Double tap to open dropdown' : null,
      child: child,
    );
  }
}

class DropifyDefaultAnchor<T> extends StatelessWidget {
  const DropifyDefaultAnchor({
    super.key,
    required this.state,
    required this.label,
    required this.hintText,
    required this.valueText,
    this.helperText,
    this.prefixIcon,
  });

  final DropifyAnchorState<T> state;
  final String? label;
  final String? hintText;
  final String? valueText;
  final String? helperText;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = DropifyTheme.of(context);
    final hasValue = valueText != null && valueText!.isNotEmpty;
    final errorText = state.errorText;
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = errorText == null
        ? colorScheme.outline
        : colorScheme.error;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        InkWell(
          onTap: state.enabled ? state.open : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            key: const ValueKey<String>('dropify.anchor'),
            padding: theme.anchorPadding,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
              color: state.enabled ? null : colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              spacing: 8,
              children: [
                ?prefixIcon,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2,
                    children: [
                      if (label != null)
                        Text(
                          label!,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      Text(
                        hasValue ? valueText! : hintText ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: hasValue
                            ? theme.anchorValueTextStyle
                            : theme.anchorHintTextStyle,
                      ),
                    ],
                  ),
                ),
                if (state.clear != null)
                  IconButton(
                    key: const ValueKey<String>('dropify.anchor.clear'),
                    tooltip: 'Clear',
                    onPressed: state.clear,
                    icon: Icon(theme.clearIcon),
                  ),
                Icon(theme.trailingIcon),
              ],
            ),
          ),
        ),
        if (helperText != null && errorText == null)
          Text(helperText!, style: Theme.of(context).textTheme.bodySmall),
        if (errorText != null)
          Text(
            key: const ValueKey<String>('dropify.validation.error'),
            errorText,
            style: theme.anchorErrorTextStyle,
          ),
      ],
    );
  }
}
