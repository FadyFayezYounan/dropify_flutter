import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'dropify_entry.dart';
import 'dropify_state.dart';

/// Explains why a multi-selection toggle was rejected.
enum DropifySelectionRejectionReason {
  /// Removing the value would violate the minimum selection count.
  minSelectionViolated,

  /// Adding the value would violate the maximum selection count.
  maxSelectionViolated,

  /// The entry is disabled and cannot be selected.
  entryDisabled,
}

/// Controls a Dropify widget's open state, query, entries, and selection.
abstract class DropifyController<T> extends ChangeNotifier {
  DropifyController._();

  /// Creates a single-selection controller.
  factory DropifyController.single({T? initialValue}) =
      _DropifyController<T>.single;

  /// Creates a multi-selection controller.
  factory DropifyController.multi({
    List<T> initialValues,
    int? minSelection,
    int? maxSelection,
  }) = _DropifyController<T>.multi;

  /// Whether this controller manages multiple selected values.
  bool get isMulti;

  /// Whether the dropdown is currently open.
  bool get isOpen;

  /// Current search query. Whitespace is preserved.
  String get query;

  /// Current data loading status.
  DropifyStatus get status;

  /// Current error object, when [status] is [DropifyStatus.error].
  Object? get error;

  /// Current entries visible to the widget.
  List<DropifyEntry<T>> get entries;

  /// The selected single value.
  T? get singleValue;

  /// Updates the selected single value.
  set singleValue(T? value);

  /// The selected multi values.
  List<T> get multiValues;

  /// The last rejected selection reason, if any.
  DropifySelectionRejectionReason? get lastRejectionReason;

  /// Opens the dropdown.
  void open({Offset? position});

  /// Closes the dropdown.
  void close();

  /// Updates [query].
  void setQuery(String value);

  /// Selects or toggles [value] depending on the controller mode.
  bool toggle(T value);

  /// Selects or toggles [entry], honoring [DropifyEntry.enabled].
  bool toggleEntry(DropifyEntry<T> entry);

  /// Refreshes async or paginated data.
  void refresh();

  /// Loads the next page for paginated data.
  void loadMore();

  /// Retries the latest failed async or paginated request.
  void retry();

  /// Configures data-source actions supplied by the attached widget.
  @internal
  void setDataActions({
    VoidCallback? refresh,
    VoidCallback? retry,
    VoidCallback? loadMore,
  });

  /// Updates the visible entries and status.
  @internal
  void setEntries(
    List<DropifyEntry<T>> entries, {
    required DropifyStatus status,
    Object? error,
  });

  /// Attaches this controller to one widget owner.
  void attach(Object owner);

  /// Detaches this controller from a widget owner.
  void detach(Object owner);

  /// Returns the nearest Dropify controller, if one exists.
  static DropifyController<T>? maybeOf<T>(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<DropifyControllerScope<T>>()
        ?.controller;
  }
}

class _DropifyController<T> extends DropifyController<T> {
  _DropifyController.single({T? initialValue})
    : _isMulti = false,
      _singleValue = initialValue,
      _multiValues = <T>[],
      _minSelection = null,
      _maxSelection = null,
      super._();

  _DropifyController.multi({
    List<T> initialValues = const <Never>[],
    int? minSelection,
    int? maxSelection,
  }) : assert(
         minSelection == null || minSelection >= 0,
         'minSelection must be null or non-negative.',
       ),
       assert(
         maxSelection == null || maxSelection >= 0,
         'maxSelection must be null or non-negative.',
       ),
       assert(
         minSelection == null ||
             maxSelection == null ||
             minSelection <= maxSelection,
         'minSelection must be less than or equal to maxSelection.',
       ),
       _isMulti = true,
       _singleValue = null,
       _multiValues = List<T>.of(initialValues),
       _minSelection = minSelection,
       _maxSelection = maxSelection,
       super._();

  final bool _isMulti;
  final int? _minSelection;
  final int? _maxSelection;
  bool _isOpen = false;
  String _query = '';
  DropifyStatus _status = DropifyStatus.idle;
  Object? _error;
  List<DropifyEntry<T>> _entries = List<DropifyEntry<T>>.empty();
  T? _singleValue;
  List<T> _multiValues;
  DropifySelectionRejectionReason? _lastRejectionReason;
  VoidCallback? _refresh;
  VoidCallback? _retry;
  VoidCallback? _loadMore;
  Object? _owner;

  @override
  bool get isMulti => _isMulti;

  @override
  bool get isOpen => _isOpen;

  @override
  String get query => _query;

  @override
  DropifyStatus get status => _status;

  @override
  Object? get error => _error;

  @override
  List<DropifyEntry<T>> get entries =>
      List<DropifyEntry<T>>.unmodifiable(_entries);

  @override
  T? get singleValue {
    _debugAssertSingle();
    return _singleValue;
  }

  @override
  set singleValue(T? value) {
    _debugAssertSingle();
    if (_singleValue == value && _lastRejectionReason == null) {
      return;
    }
    _singleValue = value;
    _lastRejectionReason = null;
    notifyListeners();
  }

  @override
  List<T> get multiValues {
    _debugAssertMulti();
    return List<T>.unmodifiable(_multiValues);
  }

  @override
  DropifySelectionRejectionReason? get lastRejectionReason =>
      _lastRejectionReason;

  @override
  void open({Offset? position}) {
    if (_isOpen) {
      return;
    }
    _isOpen = true;
    notifyListeners();
  }

  @override
  void close() {
    if (!_isOpen) {
      return;
    }
    _isOpen = false;
    notifyListeners();
  }

  @override
  void setQuery(String value) {
    if (_query == value) {
      return;
    }
    _query = value;
    notifyListeners();
  }

  @override
  bool toggle(T value) {
    if (_isMulti) {
      return _toggleMulti(value);
    }
    singleValue = value;
    return true;
  }

  @override
  bool toggleEntry(DropifyEntry<T> entry) {
    if (!entry.enabled) {
      _lastRejectionReason = DropifySelectionRejectionReason.entryDisabled;
      notifyListeners();
      return false;
    }
    return toggle(entry.value);
  }

  @override
  void refresh() {
    final VoidCallback? refresh = _refresh;
    if (refresh == null) {
      throw UnsupportedError(
        'refresh is wired for async and paginated sources.',
      );
    }
    refresh();
  }

  @override
  void loadMore() {
    final VoidCallback? loadMore = _loadMore;
    if (loadMore == null) {
      throw UnsupportedError(
        'loadMore is only supported for paginated sources.',
      );
    }
    loadMore();
  }

  @override
  void retry() {
    final VoidCallback? retry = _retry;
    if (retry == null) {
      throw UnsupportedError('retry is wired for async and paginated sources.');
    }
    retry();
  }

  @override
  void setDataActions({
    VoidCallback? refresh,
    VoidCallback? retry,
    VoidCallback? loadMore,
  }) {
    _refresh = refresh;
    _retry = retry;
    _loadMore = loadMore;
  }

  @override
  void setEntries(
    List<DropifyEntry<T>> entries, {
    required DropifyStatus status,
    Object? error,
  }) {
    _entries = List<DropifyEntry<T>>.unmodifiable(entries);
    _status = status;
    _error = error;
    notifyListeners();
  }

  @override
  void attach(Object owner) {
    if (_owner != null && !identical(_owner, owner)) {
      throw FlutterError(
        'A DropifyController can only be attached to one RawDropify at a time.',
      );
    }
    _owner = owner;
  }

  @override
  void detach(Object owner) {
    if (identical(_owner, owner)) {
      _owner = null;
    }
  }

  bool _toggleMulti(T value) {
    _debugAssertMulti();
    final List<T> nextValues = List<T>.of(_multiValues);
    if (nextValues.contains(value)) {
      if (_minSelection != null && nextValues.length <= _minSelection) {
        _lastRejectionReason =
            DropifySelectionRejectionReason.minSelectionViolated;
        notifyListeners();
        return false;
      }
      nextValues.remove(value);
    } else {
      if (_maxSelection != null && nextValues.length >= _maxSelection) {
        _lastRejectionReason =
            DropifySelectionRejectionReason.maxSelectionViolated;
        notifyListeners();
        return false;
      }
      nextValues.add(value);
    }
    _multiValues = nextValues;
    _lastRejectionReason = null;
    notifyListeners();
    return true;
  }

  void _debugAssertSingle() {
    if (_isMulti) {
      throw StateError(
        'singleValue is unavailable on a multi-select controller.',
      );
    }
  }

  void _debugAssertMulti() {
    if (!_isMulti) {
      throw StateError(
        'multiValues is unavailable on a single-select controller.',
      );
    }
  }
}

/// Exposes a Dropify controller to descendants.
@internal
class DropifyControllerScope<T> extends InheritedWidget {
  /// Creates a controller scope.
  const DropifyControllerScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The scoped controller.
  final DropifyController<T> controller;

  @override
  bool updateShouldNotify(DropifyControllerScope<T> oldWidget) {
    return controller != oldWidget.controller;
  }
}
