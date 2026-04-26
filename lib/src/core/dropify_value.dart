/// The value passed to Dropify validators.
sealed class DropifyValue<T> {
  /// Creates a validator value.
  const DropifyValue();
}

/// Validator value for single-selection dropdowns.
final class DropifySingleValue<T> extends DropifyValue<T> {
  /// Creates a single-selection validator value.
  const DropifySingleValue(this.value);

  /// The selected value, or null when no value is selected.
  final T? value;
}

/// Validator value for multi-selection dropdowns.
final class DropifyMultiValue<T> extends DropifyValue<T> {
  /// Creates a multi-selection validator value.
  const DropifyMultiValue(this.values);

  /// The selected values.
  final Set<T> values;
}
