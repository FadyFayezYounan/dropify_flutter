import 'package:flutter/material.dart';

import '../core/dropify_entry.dart';
import '../core/dropify_selection.dart';
import '../core/raw_dropify.dart';
import '../internal/_dropify_anchor.dart';
import '../theme/dropify_theme.dart';

typedef DropifyItemLabelBuilder<T> = String Function(T item);

AnchorBuilder<T> themedAnchorBuilder<T>({
  required String? label,
  required String? hintText,
  required String? helperText,
  required Widget? prefixIcon,
  required DropifyItemLabelBuilder<T>? itemLabelBuilder,
}) {
  return (context, state) {
    final valueText = switch (state.mode) {
      DropifySelectionMode.single =>
        state.value == null
            ? null
            : (itemLabelBuilder?.call(state.value as T) ??
                  state.value.toString()),
      DropifySelectionMode.multi =>
        state.values.isEmpty
            ? null
            : state.values
                  .map(
                    (item) => itemLabelBuilder?.call(item) ?? item.toString(),
                  )
                  .join(', '),
    };
    return DropifyDefaultAnchor<T>(
      state: state,
      label: label,
      hintText: hintText,
      helperText: helperText,
      valueText: valueText,
      prefixIcon: prefixIcon,
    );
  };
}

Widget themedItem<T>(
  BuildContext context,
  T item,
  bool selected,
  VoidCallback? onTap,
  DropifyItemLabelBuilder<T> labelBuilder,
) {
  final theme = DropifyTheme.of(context);
  return InkWell(
    onTap: onTap,
    child: Container(
      key: ValueKey<String>('dropify.item.${item.hashCode}'),
      padding: theme.entryPadding,
      decoration: selected ? theme.entrySelectedDecoration : null,
      child: Row(
        spacing: theme.entrySpacing ?? 8,
        children: [
          Expanded(
            child: Text(labelBuilder(item), style: theme.entryTextStyle),
          ),
          if (selected)
            Icon(
              key: const ValueKey<String>('dropify.item.selectedIcon'),
              theme.entrySelectedIcon,
              size: 18,
            ),
        ],
      ),
    ),
  );
}

List<DropifyEntry<T>> entriesWithLabels<T>(
  List<DropifyEntry<T>> entries,
  DropifyItemLabelBuilder<T>? itemLabelBuilder,
) {
  if (itemLabelBuilder == null) {
    return entries;
  }
  return [
    for (final entry in entries)
      DropifyEntry<T>(
        value: entry.value,
        label: entry.label ?? itemLabelBuilder(entry.value),
        leading: entry.leading,
        trailing: entry.trailing,
        enabled: entry.enabled,
        searchableText: entry.searchableText,
      ),
  ];
}
