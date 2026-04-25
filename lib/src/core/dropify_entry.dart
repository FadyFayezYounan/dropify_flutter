import 'package:flutter/material.dart';

/// A selectable value displayed by Dropify widgets.
///
/// The [value] is the identity of the entry. Entries with equal values compare
/// equal, matching Dropify's value-based selection contract.
@immutable
class DropifyEntry<T> {
  /// Creates a Dropify entry.
  const DropifyEntry({
    required this.value,
    required this.label,
    this.labelWidget,
    this.leadingIcon,
    this.trailingIcon,
    this.enabled = true,
    this.style,
  });

  /// The value used to identify this entry.
  final T value;

  /// The plain text label for this entry.
  final String label;

  /// An optional widget that replaces the default text label presentation.
  final Widget? labelWidget;

  /// An optional widget displayed before the label.
  final Widget? leadingIcon;

  /// An optional widget displayed after the label.
  final Widget? trailingIcon;

  /// Whether this entry can be selected.
  final bool enabled;

  /// Optional Material button styling for default widgets in later layers.
  final ButtonStyle? style;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DropifyEntry<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'DropifyEntry<$T>($label, $value)';
}
