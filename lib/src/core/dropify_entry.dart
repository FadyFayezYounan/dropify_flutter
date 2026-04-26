import 'package:flutter/widgets.dart';

/// Represents one selectable option in a static dropdown.
///
/// [value] is the consumer-facing value emitted on selection.
/// [searchableText] overrides the default search target, which resolves as
/// `searchableText ?? label ?? value.toString()`.
@immutable
class DropifyEntry<T> {
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

  /// Optional visible label.
  final String? label;

  /// Optional leading widget.
  final Widget? leading;

  /// Optional trailing widget.
  final Widget? trailing;

  /// Whether this entry can be selected and focused.
  final bool enabled;

  /// Text used for search matching. When null, [label] or [value.toString()]
  /// is used instead.
  final String? searchableText;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is DropifyEntry<T> &&
        other.runtimeType == runtimeType &&
        other.value == value &&
        other.label == label &&
        other.enabled == enabled &&
        other.searchableText == searchableText;
  }

  @override
  int get hashCode => Object.hash(value, label, enabled, searchableText);
}
