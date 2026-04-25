import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_entry.dart';
import '../theme/dropify_theme_data.dart';
import 'dropify_keys.dart';

class DropifyAnchor<T> extends StatelessWidget {
  const DropifyAnchor({
    super.key,
    required this.controller,
    required this.entries,
    required this.theme,
    required this.enabled,
    this.label,
    this.hintText,
    this.errorText,
    this.focusNode,
    this.chipBuilder,
  });

  final DropifyController<T> controller;
  final List<DropifyEntry<T>> entries;
  final DropifyThemeData theme;
  final bool enabled;
  final String? label;
  final String? hintText;
  final String? errorText;
  final FocusNode? focusNode;
  final Widget Function(BuildContext, DropifyEntry<T>, VoidCallback?)?
  chipBuilder;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      FlagProperty('enabled', value: enabled, ifFalse: 'disabled'),
    );
    properties.add(StringProperty('label', label, defaultValue: null));
    properties.add(StringProperty('hintText', hintText, defaultValue: null));
    properties.add(StringProperty('errorText', errorText, defaultValue: null));
    properties.add(DiagnosticsProperty<FocusNode?>('focusNode', focusNode));
  }

  @override
  Widget build(BuildContext context) {
    final List<DropifyEntry<T>> selectedEntries = _selectedEntries();
    return Focus(
      focusNode: focusNode,
      child: Opacity(
        opacity: enabled ? 1 : theme.disabledOpacity,
        child: GestureDetector(
          key: DropifyKeys.anchor,
          behavior: HitTestBehavior.opaque,
          onTap: enabled
              ? (controller.isOpen ? controller.close : controller.open)
              : null,
          child: DecoratedBox(
            decoration: theme.anchorDecoration,
            child: Padding(
              padding: theme.anchorPadding,
              child: Row(
                textDirection: Directionality.of(context),
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: <Widget>[
                        if (label != null)
                          Text(label!, style: theme.labelTextStyle),
                        if (controller.isMulti)
                          _ChipWrap<T>(
                            controller: controller,
                            selectedEntries: selectedEntries,
                            hintText: hintText,
                            theme: theme,
                            chipBuilder: chipBuilder,
                          )
                        else
                          Text(
                            selectedEntries.isEmpty
                                ? (hintText ?? theme.hintText)
                                : selectedEntries.first.label,
                            overflow: TextOverflow.ellipsis,
                            style: selectedEntries.isEmpty
                                ? theme.hintTextStyle
                                : theme.textStyle,
                          ),
                        if (errorText != null)
                          Text(errorText!, style: theme.errorTextStyle),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: controller.isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(theme.chevronIcon, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DropifyEntry<T>> _selectedEntries() {
    if (controller.isMulti) {
      final List<T> values = controller.multiValues;
      return entries
          .where((DropifyEntry<T> entry) => values.contains(entry.value))
          .toList(growable: false);
    }
    final T? value = controller.singleValue;
    return entries
        .where((DropifyEntry<T> entry) => entry.value == value)
        .take(1)
        .toList(growable: false);
  }
}

class _ChipWrap<T> extends StatelessWidget {
  const _ChipWrap({
    required this.controller,
    required this.selectedEntries,
    required this.theme,
    this.hintText,
    this.chipBuilder,
  });

  final DropifyController<T> controller;
  final List<DropifyEntry<T>> selectedEntries;
  final DropifyThemeData theme;
  final String? hintText;
  final Widget Function(BuildContext, DropifyEntry<T>, VoidCallback?)?
  chipBuilder;

  @override
  Widget build(BuildContext context) {
    if (selectedEntries.isEmpty) {
      return Text(
        hintText ?? theme.hintText,
        overflow: TextOverflow.ellipsis,
        style: theme.hintTextStyle,
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: <Widget>[
        for (final DropifyEntry<T> entry in selectedEntries)
          chipBuilder?.call(
                context,
                entry,
                () => controller.toggle(entry.value),
              ) ??
              _DefaultChip<T>(
                entry: entry,
                controller: controller,
                theme: theme,
              ),
      ],
    );
  }
}

class _DefaultChip<T> extends StatelessWidget {
  const _DefaultChip({
    required this.entry,
    required this.controller,
    required this.theme,
  });

  final DropifyEntry<T> entry;
  final DropifyController<T> controller;
  final DropifyThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: DropifyKeys.chip(entry.value),
      onTap: () => controller.toggle(entry.value),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.chipBackground,
          borderRadius: const BorderRadius.all(Radius.circular(999)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Text(
                  entry.label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.chipTextStyle,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.close, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
