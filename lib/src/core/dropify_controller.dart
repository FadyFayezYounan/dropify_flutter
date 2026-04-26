import 'package:flutter/foundation.dart';

import 'dropify_selection.dart';

/// Controls Dropify selection and open state.
class DropifyController<T> extends ChangeNotifier {
  /// Creates a single-selection controller.
  DropifyController.single({T? initialValue})
    : _mode = DropifySelectionMode.single,
      _value = initialValue,
      _values = <T>{};

  /// Creates a multi-selection controller.
  DropifyController.multi({Set<T>? initialValues})
    : _mode = DropifySelectionMode.multi,
      _value = null,
      _values = {...?initialValues};

  final DropifySelectionMode _mode;
  T? _value;
  Set<T> _values;
  bool _isOpen = false;
  Object Function(T item)? _keyOf;
  bool Function(T a, T b)? _equals;
  VoidCallback? _openHandler;
  VoidCallback? _closeHandler;

  /// The selection mode for this controller.
  DropifySelectionMode get mode => _mode;

  /// The single selected value.
  T? get value => _value;

  /// The multi selected values.
  Set<T> get values => Set.unmodifiable(_values);

  /// Whether the dropdown panel is open.
  bool get isOpen => _isOpen;

  /// Attaches widget-owned behavior to this controller.
  void attach({
    Object Function(T item)? keyOf,
    bool Function(T a, T b)? equals,
    VoidCallback? openHandler,
    VoidCallback? closeHandler,
  }) {
    _keyOf = keyOf;
    _equals = equals;
    _openHandler = openHandler;
    _closeHandler = closeHandler;
  }

  /// Detaches widget-owned behavior.
  void detach() {
    _openHandler = null;
    _closeHandler = null;
  }

  /// Updates the open flag without requesting the menu to open or close.
  void setOpenState(bool isOpen) {
    if (_isOpen == isOpen) {
      return;
    }
    _isOpen = isOpen;
    notifyListeners();
  }

  /// Sets the single selected value.
  void setValue(T? value) {
    if (_mode != DropifySelectionMode.single) {
      throw StateError(
        'setValue is only valid for single-selection controllers.',
      );
    }
    if (_value == value) {
      return;
    }
    _value = value;
    notifyListeners();
  }

  /// Sets the multi selected values.
  void setValues(Set<T> values) {
    if (_mode != DropifySelectionMode.multi) {
      throw StateError(
        'setValues is only valid for multi-selection controllers.',
      );
    }
    _values = {...values};
    notifyListeners();
  }

  /// Toggles [item] in multi-selection mode.
  void toggle(T item) {
    setValues(dropifyToggledSet(_values, item, keyOf: _keyOf, equals: _equals));
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
  void open() {
    _openHandler?.call();
  }

  /// Closes the dropdown panel.
  void close() {
    _closeHandler?.call();
  }

  /// Whether [item] is selected.
  bool isSelected(T item) {
    if (_mode == DropifySelectionMode.single) {
      final current = _value;
      return current != null &&
          dropifyItemsEqual(current, item, keyOf: _keyOf, equals: _equals);
    }
    return dropifyContains(_values, item, keyOf: _keyOf, equals: _equals);
  }
}
