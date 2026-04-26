import 'package:flutter/widgets.dart';

import '../core/dropify_selection.dart';

/// State object passed to [AnchorBuilder] callbacks.
class DropifyAnchorState<T> {
  const DropifyAnchorState({
    required this.mode,
    this.value,
    required this.values,
    required this.isOpen,
    required this.enabled,
    this.errorText,
    required this.open,
    required this.close,
    this.clear,
  });

  final DropifySelectionMode mode;
  final T? value;
  final Set<T> values;
  final bool isOpen;
  final bool enabled;
  final String? errorText;
  final VoidCallback open;
  final VoidCallback close;
  final VoidCallback? clear;
}

/// Builder signature for dropdown anchors.
typedef AnchorBuilder<T> =
    Widget Function(BuildContext context, DropifyAnchorState<T> state);
