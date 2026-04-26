import 'package:flutter/foundation.dart';

/// The value type passed to validators in [RawDropify].
///
/// Subclasses represent single and multi selection values respectively.
@immutable
sealed class DropifyValue<T> {
  const DropifyValue();
}

/// A single selection value.
@immutable
class DropifySingleValue<T> extends DropifyValue<T> {
  const DropifySingleValue(this.value);

  /// The selected value, or null if nothing is selected.
  final T? value;

  @override
  bool operator ==(Object other) {
    return other is DropifySingleValue<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// A multi selection value.
@immutable
class DropifyMultiValue<T> extends DropifyValue<T> {
  const DropifyMultiValue(this.values);

  /// The set of selected values.
  final Set<T> values;

  @override
  bool operator ==(Object other) {
    return other is DropifyMultiValue<T> && _setEquals(other.values, values);
  }

  @override
  int get hashCode => Object.hashAll(values);

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) {
      return false;
    }
    return a.containsAll(b);
  }
}
