import 'package:flutter/material.dart';

import '../core/dropify_selection.dart';

/// Wraps [child] in a `Semantics` node so that accessibility services
/// can correctly advertise the anchor as a dropdown button.
Widget wrapAnchorSemantics({
  required Widget child,
  required DropifySelectionMode mode,
  required String? label,
  required String? value,
  required String? errorText,
  required bool enabled,
}) {
  return Semantics(
    key: const Key('dropify.anchor'),
    button: true,
    enabled: enabled,
    label: label ?? 'Dropdown',
    value: value ?? 'No selection',
    hint: 'Double tap to open dropdown',
    child: ExcludeSemantics(excluding: false, child: child),
  );
}

/// Builds the clear-button affordance shown when the dropdown has a value
/// and [showClearButton] is true.
Widget buildClearButton({
  required VoidCallback onClear,
  required bool hasSelection,
  required bool showClearButton,
  IconData? icon,
}) {
  if (!showClearButton || !hasSelection) {
    return const SizedBox.shrink();
  }
  return Semantics(
    key: const Key('dropify.anchor.clear'),
    button: true,
    label: 'Clear selection',
    child: IconButton(
      icon: Icon(icon ?? Icons.close),
      onPressed: onClear,
      tooltip: 'Clear selection',
      visualDensity: VisualDensity.compact,
    ),
  );
}
