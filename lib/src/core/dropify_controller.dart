import 'package:flutter/foundation.dart';

import 'dropify_selection.dart';

/// Controls Dropify selection and open state.
///
/// A controller can open, close, clear, and replace selection from outside a
/// Dropify widget. When a controller is passed to a widget, the caller owns its
/// disposal.
class DropifyController<T> extends ChangeNotifier {
  /// Creates a single-selection controller.
  ///
  /// The optional [initialValue] is used until the selection is replaced or
  /// cleared.
  DropifyController.single({T? initialValue})
    : _mode = DropifySelectionMode.single,
      _value = initialValue,
      _values = <T>{};

  /// Creates a multi-selection controller.
  ///
  /// The optional [initialValues] are copied into the controller.
  DropifyController.multi({Set<T>? initialValues})
    : _mode = DropifySelectionMode.multi,
      _values = {...?initialValues};

  final DropifySelectionMode _mode;
  T? _value;
  Set<T> _values;
  bool _isOpen = false;
  DropifySelectionIdentity<T> _identity = DropifySelectionIdentity<T>();
  VoidCallback? _openRequest;
  VoidCallback? _closeRequest;

  /// The controller selection mode.
  DropifySelectionMode get mode => _mode;

  /// The selected single value.
  T? get value => _value;

  /// The selected multi values.
  Set<T> get values => Set.unmodifiable(_values);

  /// Whether the dropdown panel is open.
  bool get isOpen => _isOpen;

  /// Attaches widget callbacks to this controller.
  @internal
  void attach({
    required VoidCallback open,
    required VoidCallback close,
    Object Function(T item)? keyOf,
    bool Function(T a, T b)? equals,
  }) {
    _openRequest = open;
    _closeRequest = close;
    _identity = DropifySelectionIdentity<T>(keyOf: keyOf, equals: equals);
  }

  /// Detaches widget callbacks from this controller.
  @internal
  void detach() {
    _openRequest = null;
    _closeRequest = null;
  }

  /// Updates open state from the owning widget.
  @internal
  void setOpenState(bool value) {
    if (_isOpen == value) {
      return;
    }
    _isOpen = value;
    notifyListeners();
  }

  /// Replaces the selected single value.
  ///
  /// This method asserts when called on a multi-selection controller.
  void setValue(T? value) {
    assert(_mode == DropifySelectionMode.single);
    if (_value == value) {
      return;
    }
    _value = value;
    notifyListeners();
  }

  /// Replaces the selected multi values.
  ///
  /// This method asserts when called on a single-selection controller.
  void setValues(Set<T> values) {
    assert(_mode == DropifySelectionMode.multi);
    if (setEquals(_values, values)) {
      return;
    }
    _values = {...values};
    notifyListeners();
  }

  /// Toggles a multi value using the active identity rules.
  ///
  /// This method asserts when called on a single-selection controller.
  void toggle(T item) {
    assert(_mode == DropifySelectionMode.multi);
    setValues(_identity.toggled(_values, item));
  }

  /// Clears the current selection.
  void clear() {
    if (_mode == DropifySelectionMode.single) {
      setValue(null);
    } else {
      setValues(<T>{});
    }
  }

  /// Opens the dropdown panel.
  ///
  /// Calling this before the controller is attached to a widget is a no-op.
  void open() {
    _openRequest?.call();
  }

  /// Closes the dropdown panel.
  ///
  /// Calling this before the controller is attached to a widget is a no-op.
  void close() {
    _closeRequest?.call();
  }

  /// Whether [item] is selected.
  bool isSelected(T item) {
    if (_mode == DropifySelectionMode.single) {
      final value = _value;
      return value != null && _identity.same(value, item);
    }
    return _identity.contains(_values, item);
  }
}
