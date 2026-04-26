/// The selection mode used by a Dropify widget.
enum DropifySelectionMode {
  /// A single value can be selected.
  single,

  /// Multiple values can be selected.
  multi,
}

/// Resolves item identity for selection comparisons.
bool dropifyItemsEqual<T>(
  T a,
  T b, {
  Object Function(T item)? keyOf,
  bool Function(T a, T b)? equals,
}) {
  if (keyOf != null) {
    return keyOf(a) == keyOf(b);
  }
  if (equals != null) {
    return equals(a, b);
  }
  return a == b;
}

/// Returns whether [items] contains [item] using Dropify identity rules.
bool dropifyContains<T>(
  Iterable<T> items,
  T item, {
  Object Function(T item)? keyOf,
  bool Function(T a, T b)? equals,
}) {
  for (final current in items) {
    if (dropifyItemsEqual(current, item, keyOf: keyOf, equals: equals)) {
      return true;
    }
  }
  return false;
}

/// Toggles [item] in [items] using Dropify identity rules.
Set<T> dropifyToggledSet<T>(
  Iterable<T> items,
  T item, {
  Object Function(T item)? keyOf,
  bool Function(T a, T b)? equals,
}) {
  final result = <T>{};
  var removed = false;
  for (final current in items) {
    if (!removed &&
        dropifyItemsEqual(current, item, keyOf: keyOf, equals: equals)) {
      removed = true;
      continue;
    }
    result.add(current);
  }
  if (!removed) {
    result.add(item);
  }
  return result;
}

/// Sanitizes an identity value for optional internal item keys.
String dropifySanitizeIdentity(Object value) {
  final text = value.toString().trim().toLowerCase();
  return text.replaceAll(RegExp(r'[^a-z0-9_-]+'), '_');
}
