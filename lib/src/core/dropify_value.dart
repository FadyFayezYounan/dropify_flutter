import 'package:flutter/foundation.dart';

/// The value passed to Dropify form validators.
@immutable
sealed class DropifyValue<T> {
  /// Creates a validation value.
  const DropifyValue();
}

/// A single-selection validation value.
final class DropifySingleValue<T> extends DropifyValue<T> {
  /// Creates a single-selection validation value.
  const DropifySingleValue(this.value);

  /// The selected value, or null when nothing is selected.
  final T? value;

  @override
  bool operator ==(Object other) {
    return other is DropifySingleValue<T> && other.value == value;
  }

  @override
  int get hashCode => Object.hash(DropifySingleValue<T>, value);
}

/// A multi-selection validation value.
final class DropifyMultiValue<T> extends DropifyValue<T> {
  /// Creates a multi-selection validation value.
  const DropifyMultiValue(this.values);

  /// The selected values.
  final Set<T> values;

  @override
  bool operator ==(Object other) {
    return other is DropifyMultiValue<T> && setEquals(other.values, values);
  }

  @override
  int get hashCode => Object.hashAllUnordered(values);
}
