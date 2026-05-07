import 'package:flutter/widgets.dart';

/// A selectable option used by static Dropify widgets.
///
/// Entries provide the value emitted by selection and the default presentation
/// data used by static row builders and local search.
@immutable
class DropifyEntry<T> {
  /// Creates a Dropify option entry.
  ///
  /// The [value] argument is required. The [enabled] argument defaults to true.
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
  ///
  /// If null, default builders use [value].toString().
  final String? label;

  /// Optional leading widget rendered by default entry builders.
  final Widget? leading;

  /// Optional trailing widget rendered by default entry builders.
  final Widget? trailing;

  /// Whether this entry can be selected.
  ///
  /// Defaults to true. Disabled entries remain visible but cannot be selected.
  final bool enabled;

  /// Optional search text override.
  ///
  /// If null, the default matcher uses [label] or [value].toString().
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
