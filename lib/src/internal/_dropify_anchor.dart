import 'package:flutter/material.dart';

import '../core/raw_dropify.dart';
import '../theme/dropify_theme.dart';

class DropifyAnchor<T> extends StatelessWidget {
  const DropifyAnchor({super.key, required this.state, required this.child});

  final DropifyAnchorState<T> state;
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
    final decorationTheme = theme.anchorDecorationTheme;
    final textTheme = Theme.of(context).textTheme;
    final suffixIcon = _DropifyAnchorSuffix(
      clear: state.clear,
      clearIcon: theme.clearIcon,
      trailingIcon: theme.trailingIcon,
    );
    final decoration = InputDecoration(
      enabled: state.enabled,
      labelText: label,
      hintText: hintText,
      helperText: errorText == null ? helperText : null,
      error: errorText == null
          ? null
          : Text(
              key: const ValueKey<String>('dropify.validation.error'),
              errorText,
              style: theme.anchorErrorTextStyle,
            ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintStyle: theme.anchorHintTextStyle,
      errorStyle: theme.anchorErrorTextStyle,
      contentPadding: decorationTheme?.contentPadding ?? theme.anchorPadding,
    ).applyDefaults(decorationTheme ?? const InputDecorationTheme());

    return DropifyAnchor<T>(
      state: state,
      child: InkWell(
        canRequestFocus: state.enabled,
        onTap: state.enabled ? state.open : null,
        child: InputDecorator(
          isEmpty: !hasValue,
          isFocused: state.isOpen,
          decoration: decoration,
          child: Text(
            hasValue ? valueText! : '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: hasValue
                ? theme.anchorValueTextStyle
                : theme.anchorHintTextStyle ?? textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

class _DropifyAnchorSuffix extends StatelessWidget {
  const _DropifyAnchorSuffix({
    required this.clear,
    required this.clearIcon,
    required this.trailingIcon,
  });

  final VoidCallback? clear;
  final IconData? clearIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (clear != null)
          IconButton(
            key: const ValueKey<String>('dropify.anchor.clear'),
            tooltip: 'Clear',
            onPressed: clear,
            icon: Icon(clearIcon),
          ),
        Icon(trailingIcon),
        const SizedBox(width: 12),
      ],
    );
  }
}
