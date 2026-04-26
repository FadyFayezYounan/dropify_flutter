import 'package:flutter/widgets.dart';

/// A selectable option used by static Dropify widgets.
@immutable
class DropifyEntry<T> {
  /// Creates a Dropify option entry.
  const DropifyEntry({
    required this.value,
    this.label,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.searchableText,
  });

  /// The value emitted when this entry is selected.
  final T value;

  /// The default visible label.
  final String? label;

  /// Optional leading widget rendered by default entry builders.
  final Widget? leading;

  /// Optional trailing widget rendered by default entry builders.
  final Widget? trailing;

  /// Whether this entry can be selected.
  final bool enabled;

  /// Optional search text override.
  final String? searchableText;

  /// The text used by the default matcher.
  String get effectiveSearchText => searchableText ?? label ?? value.toString();

  @override
  bool operator ==(Object other) {
    return other is DropifyEntry<T> &&
        other.value == value &&
        other.label == label &&
        other.leading == leading &&
        other.trailing == trailing &&
        other.enabled == enabled &&
        other.searchableText == searchableText;
  }

  @override
  int get hashCode {
    return Object.hash(
      value,
      label,
      leading,
      trailing,
      enabled,
      searchableText,
    );
  }
}
