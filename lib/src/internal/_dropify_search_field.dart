import 'package:flutter/material.dart';

import '../theme/dropify_theme.dart';

class DropifySearchField extends StatelessWidget {
  const DropifySearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final theme = DropifyTheme.of(context);
    final decoration = (theme.searchInputDecoration ?? const InputDecoration())
        .copyWith(
          hintText:
              hintText ?? theme.searchInputDecoration?.hintText ?? 'Search',
          prefixIcon: theme.searchIcon == null ? null : Icon(theme.searchIcon),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                key: const ValueKey<String>('dropify.search.clear'),
                tooltip: 'Clear search',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: Icon(theme.searchClearIcon),
              );
            },
          ),
        );
    return Padding(
      padding: theme.searchFieldPadding ?? EdgeInsets.zero,
      child: TextField(
        key: const ValueKey<String>('dropify.search.field'),
        controller: controller,
        style: theme.searchTextStyle,
        decoration: decoration,
        onChanged: onChanged,
      ),
    );
  }
}
