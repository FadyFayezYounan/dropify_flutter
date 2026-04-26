import 'package:flutter/material.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_selection.dart';
import 'dropify_panel_state.dart';
import '_dropify_search_field.dart';

/// Internal wrapper that renders the panel chrome: optional search field,
/// the user's [panelBuilder] body, and an optional confirmable multi footer.
class DropifyPanel<T> extends StatelessWidget {
  const DropifyPanel({
    super.key,
    required this.mode,
    required this.controller,
    required this.panelBuilder,
    required this.onSelect,
    required this.onToggle,
    required this.onClose,
    required this.searchable,
    required this.searchController,
    required this.searchHintText,
    required this.isSelectedFn,
    required this.focusScopeNode,
    this.matchAnchorWidth = true,
    this.panelConstraints,
    this.confirmable = false,
    this.confirmLabel,
    this.cancelLabel,
    this.onApply,
    this.onCancel,
  });

  final DropifySelectionMode mode;
  final DropifyController<T> controller;
  final PanelBuilder<T> panelBuilder;
  final void Function(T) onSelect;
  final void Function(T) onToggle;
  final VoidCallback onClose;
  final bool searchable;
  final TextEditingController? searchController;
  final String? searchHintText;
  final bool Function(T) isSelectedFn;
  final FocusNode focusScopeNode;
  final bool matchAnchorWidth;
  final BoxConstraints? panelConstraints;
  final bool confirmable;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onApply;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final effectiveConstraints =
        panelConstraints ?? const BoxConstraints(maxHeight: 320);

    return Semantics(
      key: const Key('dropify.panel'),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: effectiveConstraints,
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (searchable)
                  DropifySearchField(
                    controller: searchController ?? TextEditingController(),
                    hintText: searchHintText,
                  ),
                Flexible(
                  child: panelBuilder(
                    context,
                    DropifyPanelState<T>(
                      mode: mode,
                      value: mode == DropifySelectionMode.single
                          ? controller.value
                          : null,
                      values: mode == DropifySelectionMode.multi
                          ? controller.values
                          : <T>{},
                      searchQuery: searchController?.text ?? '',
                      isSelected: isSelectedFn,
                      toggle: onToggle,
                      select: onSelect,
                      close: onClose,
                      focusScope: focusScopeNode,
                    ),
                  ),
                ),
                if (confirmable && mode == DropifySelectionMode.multi)
                  _ConfirmableFooter(
                    confirmLabel: confirmLabel ?? 'Apply',
                    cancelLabel: cancelLabel ?? 'Cancel',
                    onApply: onApply ?? () {},
                    onCancel: onCancel ?? () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmableFooter extends StatelessWidget {
  const _ConfirmableFooter({
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onApply,
    required this.onCancel,
  });

  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onApply;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const Key('dropify.multi.footer'),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Semantics(
              key: const Key('dropify.multi.cancel'),
              button: true,
              child: TextButton(onPressed: onCancel, child: Text(cancelLabel)),
            ),
            const SizedBox(width: 8),
            Semantics(
              key: const Key('dropify.multi.apply'),
              button: true,
              child: ElevatedButton(
                onPressed: onApply,
                child: Text(confirmLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
