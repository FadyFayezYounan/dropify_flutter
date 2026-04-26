import 'package:flutter/foundation.dart';

import 'dropify_selection.dart';

/// A [ChangeNotifier] that exposes open/close and selection mutations for
/// both single and multi mode dropdowns.
///
/// Consumers can create a controller and pass it to the [RawDropify.controller]
/// parameter to programmatically read and write dropdown state.
///
/// When no controller is provided, [RawDropify] creates an internal one and
/// disposes it on widget dispose.
class DropifyController<T> extends ChangeNotifier {
  DropifyController._({
    required this.mode,
    T? initialValue,
    Set<T>? initialValues,
  }) : _value = initialValue,
       _values = Set<T>.from(initialValues ?? <T>{});

  /// Creates a controller for a single-selection dropdown.
  factory DropifyController.single({T? initialValue}) {
    return DropifyController<T>._(
      mode: DropifySelectionMode.single,
      initialValue: initialValue,
    );
  }

  /// Creates a controller for a multi-selection dropdown.
  factory DropifyController.multi({Set<T>? initialValues}) {
    return DropifyController<T>._(
      mode: DropifySelectionMode.multi,
      initialValues: initialValues,
    );
  }

  /// The selection mode.
  final DropifySelectionMode mode;

  T? _value;
  Set<T> _values;

  /// Whether the panel is currently open.
  bool isOpen = false;

  /// The single mode selected value.
  T? get value {
    assert(
      mode == DropifySelectionMode.single,
      'value is only for single mode',
    );
    return _value;
  }

  /// The multi mode selected values (unmodifiable view).
  Set<T> get values {
    assert(mode == DropifySelectionMode.multi, 'values is only for multi mode');
    return Set<T>.unmodifiable(_values);
  }

  /// Resolved identity function, set during attach by [RawDropify].
  Object Function(T item)? _keyOf;
  bool Function(T a, T b)? _equals;

  /// Called by [RawDropify] during [State.initState] to wire identity helpers.
  void attachToWidget({
    Object Function(T item)? keyOf,
    bool Function(T a, T b)? equals,
  }) {
    _keyOf = keyOf;
    _equals = equals;
  }

  /// Called by [RawDropify] during [State.dispose] to clear identity helpers.
  void detachFromWidget() {
    _keyOf = null;
    _equals = null;
  }

  /// Sets the single mode value and notifies listeners.
  void setValue(T? value) {
    assert(
      mode == DropifySelectionMode.single,
      'setValue is only for single mode',
    );
    if (_value != value) {
      _value = value;
      notifyListeners();
    }
  }

  /// Sets the multi mode values and notifies listeners.
  void setValues(Set<T> values) {
    assert(
      mode == DropifySelectionMode.multi,
      'setValues is only for multi mode',
    );
    if (!_setsEqual(_values, values)) {
      _values = Set<T>.from(values);
      notifyListeners();
    }
  }

  /// Toggles [item] in or out of the multi selection set.
  void toggle(T item) {
    assert(mode == DropifySelectionMode.multi, 'toggle is only for multi mode');
    if (isSelected(item)) {
      _removeItem(item);
    } else {
      _values.add(item);
      notifyListeners();
    }
  }

  /// Clears the current selection.
  void clear() {
    if (mode == DropifySelectionMode.single) {
      if (_value != null) {
        _value = null;
        notifyListeners();
      }
    } else {
      if (_values.isNotEmpty) {
        _values = <T>{};
        notifyListeners();
      }
    }
  }

  /// Opens the dropdown panel.
  void open() {
    if (!isOpen) {
      isOpen = true;
      notifyListeners();
    }
  }

  /// Closes the dropdown panel.
  void close() {
    if (isOpen) {
      isOpen = false;
      notifyListeners();
    }
  }

  /// Returns true if [item] is selected (multi mode only).
  bool isSelected(T item) {
    assert(
      mode == DropifySelectionMode.multi,
      'isSelected is only for multi mode',
    );
    if (_keyOf != null) {
      final key = _keyOf!(item);
      return _values.any((v) {
        final vKey = _keyOf!(v);
        return key == vKey;
      });
    }
    if (_equals != null) {
      return _values.any((v) => _equals!(v, item));
    }
    return _values.contains(item);
  }

  void _removeItem(T item) {
    if (_keyOf != null) {
      final key = _keyOf!(item);
      _values.removeWhere((v) => _keyOf!(v) == key);
    } else if (_equals != null) {
      _values.removeWhere((v) => _equals!(v, item));
    } else {
      _values.remove(item);
    }
    notifyListeners();
  }

  static bool _setsEqual<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) {
      return false;
    }
    return a.containsAll(b);
  }
}
