import 'package:flutter/foundation.dart';

/// Describes how a Dropify widget commits selections.
enum DropifySelectionMode {
  /// Exactly one value can be selected.
  single,

  /// Multiple values can be selected.
  multi,
}

@immutable
class DropifySelectionIdentity<T> {
  const DropifySelectionIdentity({this.keyOf, this.equals});

  final Object Function(T item)? keyOf;

  final bool Function(T a, T b)? equals;

  bool same(T a, T b) {
    final keyOf = this.keyOf;
    if (keyOf != null) {
      return keyOf(a) == keyOf(b);
    }
    final equals = this.equals;
    if (equals != null) {
      return equals(a, b);
    }
    return a == b;
  }

  bool contains(Iterable<T> values, T item) {
    for (final value in values) {
      if (same(value, item)) {
        return true;
      }
    }
    return false;
  }

  Set<T> toggled(Set<T> values, T item) {
    final result = <T>{};
    var removed = false;
    for (final value in values) {
      if (same(value, item)) {
        removed = true;
      } else {
        result.add(value);
      }
    }
    if (!removed) {
      result.add(item);
    }
    return result;
  }
}
