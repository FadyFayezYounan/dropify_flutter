import 'package:flutter/widgets.dart';

import '../core/dropify_selection.dart';

/// State object passed to [PanelBuilder] callbacks.
class DropifyPanelState<T> {
  const DropifyPanelState({
    required this.mode,
    this.value,
    required this.values,
    required this.searchQuery,
    required this.isSelected,
    required this.toggle,
    required this.select,
    required this.close,
    required this.focusScope,
  });

  final DropifySelectionMode mode;
  final T? value;
  final Set<T> values;
  final String searchQuery;
  final bool Function(T item) isSelected;
  final void Function(T item) toggle;
  final void Function(T item) select;
  final VoidCallback close;
  final FocusNode focusScope;
}

/// Builder signature for dropdown panels.
typedef PanelBuilder<T> =
    Widget Function(BuildContext context, DropifyPanelState<T> state);
