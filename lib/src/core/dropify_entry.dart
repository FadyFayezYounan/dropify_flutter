import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A selectable entry used by static Dropify widgets.
@immutable
class DropifyEntry<T> {
  /// Creates a static dropdown entry.
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

  /// The default visible label for this entry.
  final String? label;

  /// An optional leading widget.
  final Widget? leading;

  /// An optional trailing widget.
  final Widget? trailing;

  /// Whether this entry can be selected.
  final bool enabled;

  /// Search text that overrides [label] and [value].
  final String? searchableText;

  /// The effective text used by the built-in matcher.
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
  int get hashCode =>
      Object.hash(value, label, leading, trailing, enabled, searchableText);
}
