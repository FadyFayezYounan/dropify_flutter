import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../internal/debouncer.dart';
import '../internal/default_matcher.dart';
import 'dropify_controller.dart';
import 'dropify_data_source.dart';
import 'dropify_entry.dart';
import 'dropify_state.dart';

/// Builds the anchor for a [RawDropify].
typedef DropifyAnchorBuilder<T> =
    Widget Function(
      BuildContext context,
      DropifyController<T> controller,
      Widget? child,
    );

/// Builds the overlay body for a [RawDropify].
typedef DropifyBodyBuilder<T> =
    Widget Function(BuildContext context, DropifyState<T> state);

/// Matches a static entry against a query.
typedef DropifyStaticMatcher<T> =
    bool Function(DropifyEntry<T> entry, String query);

/// Reports the current single or multi selection.
typedef DropifySelectionChanged<T> = void Function(T? value, List<T> values);

/// A raw dropdown primitive built on Flutter's [RawMenuAnchor].
class RawDropify<T> extends StatefulWidget {
  /// Creates a single-selection raw Dropify widget.
  const RawDropify({
    super.key,
    this.controller,
    this.dataSource,
    required this.anchorBuilder,
    required this.bodyBuilder,
    this.onSelectionChanged,
    this.onOpenChanged,
    this.onQueryChanged,
    this.useRootOverlay = false,
    this.consumeOutsideTaps = false,
    this.closeOnSelect,
    this.queryDebounce = const Duration(milliseconds: 300),
    this.staticMatcher,
    this.child,
  }) : _isMulti = false;

  /// Creates a multi-selection raw Dropify widget.
  const RawDropify.multi({
    super.key,
    this.controller,
    this.dataSource,
    required this.anchorBuilder,
    required this.bodyBuilder,
    this.onSelectionChanged,
    this.onOpenChanged,
    this.onQueryChanged,
    this.useRootOverlay = false,
    this.consumeOutsideTaps = false,
    this.closeOnSelect,
    this.queryDebounce = const Duration(milliseconds: 300),
    this.staticMatcher,
    this.child,
  }) : _isMulti = true;

  /// Optional external controller.
  final DropifyController<T>? controller;

  /// Entry source. Phase 1 supports [StaticDropifyDataSource].
  final DropifyDataSource<T>? dataSource;

  /// Builds the anchor widget.
  final DropifyAnchorBuilder<T> anchorBuilder;

  /// Builds the custom overlay body.
  final DropifyBodyBuilder<T> bodyBuilder;

  /// Called after a selection changes.
  final DropifySelectionChanged<T>? onSelectionChanged;

  /// Called when the overlay opens or closes.
  final ValueChanged<bool>? onOpenChanged;

  /// Called after query changes settle for [queryDebounce].
  final ValueChanged<String>? onQueryChanged;

  /// Whether the menu uses the root overlay.
  final bool useRootOverlay;

  /// Whether outside taps are consumed after closing the menu.
  final bool consumeOutsideTaps;

  /// Whether selecting an entry closes the dropdown.
  final bool? closeOnSelect;

  /// Debounce applied to [onQueryChanged].
  final Duration queryDebounce;

  /// Optional matcher for static sources.
  final DropifyStaticMatcher<T>? staticMatcher;

  /// Optional child passed to [anchorBuilder].
  final Widget? child;

  final bool _isMulti;

  @override
  State<RawDropify<T>> createState() => _RawDropifyState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('isMulti', value: _isMulti, ifTrue: 'multi'));
    properties.add(
      FlagProperty(
        'useRootOverlay',
        value: useRootOverlay,
        ifTrue: 'use root overlay',
      ),
    );
    properties.add(
      DiagnosticsProperty<Duration>('queryDebounce', queryDebounce),
    );
  }
}

class _RawDropifyState<T> extends State<RawDropify<T>> {
  final MenuController _menuController = MenuController();
  late Debouncer _queryDebouncer;
  DropifyController<T>? _internalController;
  late DropifyController<T> _controller;
  String _lastQuery = '';
  String? _lastAsyncQuery;
  int _asyncRequestToken = 0;
  List<T> _lastMultiValues = List<T>.empty();
  T? _lastSingleValue;

  bool get _closeOnSelect => widget.closeOnSelect ?? !widget._isMulti;

  @override
  void initState() {
    super.initState();
    _queryDebouncer = Debouncer(widget.queryDebounce);
    _bindController(initial: true);
  }

  @override
  void didUpdateWidget(RawDropify<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget._isMulti != widget._isMulti) {
      _unbindController();
      _bindController(initial: true);
    }
    if (oldWidget.queryDebounce != widget.queryDebounce) {
      _queryDebouncer.dispose();
      _queryDebouncer = Debouncer(widget.queryDebounce);
    }
    if (oldWidget.dataSource != widget.dataSource ||
        oldWidget.staticMatcher != widget.staticMatcher) {
      _initializeDataSource();
    }
  }

  @override
  void dispose() {
    _queryDebouncer.dispose();
    _unbindController();
    super.dispose();
  }

  void _bindController({required bool initial}) {
    _internalController = widget.controller == null
        ? (widget._isMulti
              ? DropifyController<T>.multi()
              : DropifyController<T>.single())
        : null;
    _controller = widget.controller ?? _internalController!;
    if (_controller.isMulti != widget._isMulti) {
      throw FlutterError(
        'RawDropify.${widget._isMulti ? 'multi' : 'new'} requires a '
        '${widget._isMulti ? 'multi' : 'single'} controller.',
      );
    }
    _controller.attach(this);
    _controller.addListener(_handleControllerChanged);
    _configureDataActions();
    _lastQuery = _controller.query;
    _lastSingleValue = _controller.isMulti ? null : _controller.singleValue;
    _lastMultiValues = _controller.isMulti
        ? _controller.multiValues
        : List<T>.empty();
    _initializeDataSource();
  }

  void _unbindController() {
    _controller.setDataActions();
    _controller.removeListener(_handleControllerChanged);
    _controller.detach(this);
    _internalController?.dispose();
    _internalController = null;
  }

  void _handleControllerChanged() {
    if (_controller.isOpen && !_menuController.isOpen) {
      _menuController.open();
    } else if (!_controller.isOpen && _menuController.isOpen) {
      _menuController.close();
    }

    if (_lastQuery != _controller.query) {
      _lastQuery = _controller.query;
      _handleQueryChanged();
    }

    final bool selectionChanged = _didSelectionChange();
    if (selectionChanged) {
      _notifySelectionChanged();
      if (_closeOnSelect) {
        _controller.close();
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  bool _didSelectionChange() {
    if (_controller.isMulti) {
      final List<T> values = _controller.multiValues;
      final bool changed = !listEquals(values, _lastMultiValues);
      _lastMultiValues = values;
      return changed;
    }
    final T? value = _controller.singleValue;
    final bool changed = value != _lastSingleValue;
    _lastSingleValue = value;
    return changed;
  }

  void _notifySelectionChanged() {
    widget.onSelectionChanged?.call(
      _controller.isMulti ? null : _controller.singleValue,
      _controller.isMulti ? _controller.multiValues : List<T>.empty(),
    );
  }

  void _configureDataActions() {
    final DropifyDataSource<T>? source = widget.dataSource;
    if (source is AsyncDropifyDataSource<T>) {
      _controller.setDataActions(
        refresh: _fetchAsyncNow,
        retry: _fetchAsyncNow,
      );
      return;
    }
    _controller.setDataActions();
  }

  void _initializeDataSource() {
    _configureDataActions();
    final DropifyDataSource<T>? source = widget.dataSource;
    switch (source) {
      case null:
        _controller.setEntries(
          List<DropifyEntry<T>>.empty(),
          status: DropifyStatus.idle,
        );
      case StaticDropifyDataSource<T>():
        _refreshStaticEntries();
      case AsyncDropifyDataSource<T>():
        _lastAsyncQuery = null;
        _controller.setEntries(
          List<DropifyEntry<T>>.empty(),
          status: DropifyStatus.idle,
        );
      case PaginatedDropifyDataSource<T>():
        throw UnimplementedError(
          'PaginatedDropifyDataSource is wired in a later phase.',
        );
    }
  }

  void _handleQueryChanged() {
    final DropifyDataSource<T>? source = widget.dataSource;
    if (source is StaticDropifyDataSource<T>) {
      _refreshStaticEntries();
      _queryDebouncer.run(() => widget.onQueryChanged?.call(_controller.query));
      return;
    }
    if (source is AsyncDropifyDataSource<T>) {
      _queryDebouncer.run(() {
        widget.onQueryChanged?.call(_controller.query);
        if (_controller.isOpen) {
          _fetchAsyncNow();
        }
      });
    }
  }

  void _refreshStaticEntries() {
    final DropifyDataSource<T>? source = widget.dataSource;
    final List<DropifyEntry<T>> entries = switch (source) {
      null => List<DropifyEntry<T>>.empty(),
      StaticDropifyDataSource<T>(
        entries: final List<DropifyEntry<T>> entries,
      ) =>
        _filter(entries),
      AsyncDropifyDataSource<T>() => _controller.entries,
      PaginatedDropifyDataSource<T>() => throw UnimplementedError(
        'PaginatedDropifyDataSource is wired in a later phase.',
      ),
    };
    _controller.setEntries(
      entries,
      status: entries.isEmpty ? DropifyStatus.empty : DropifyStatus.data,
    );
  }

  List<DropifyEntry<T>> _filter(List<DropifyEntry<T>> entries) {
    final DropifyStaticMatcher<T> matcher =
        widget.staticMatcher ?? defaultDropifyMatcher;
    return entries
        .where((DropifyEntry<T> entry) => matcher(entry, _controller.query))
        .toList(growable: false);
  }

  Future<void> _fetchAsyncNow() async {
    final DropifyDataSource<T>? source = widget.dataSource;
    if (source is! AsyncDropifyDataSource<T>) {
      return;
    }
    final int token = _asyncRequestToken + 1;
    _asyncRequestToken = token;
    final String query = _controller.query;
    _lastAsyncQuery = query;
    _controller.setEntries(_controller.entries, status: DropifyStatus.loading);
    try {
      final List<DropifyEntry<T>> entries = await source.fetch(query);
      if (!mounted || token != _asyncRequestToken) {
        return;
      }
      _controller.setEntries(
        entries,
        status: entries.isEmpty ? DropifyStatus.empty : DropifyStatus.data,
      );
    } catch (error) {
      if (!mounted || token != _asyncRequestToken) {
        return;
      }
      _controller.setEntries(
        _controller.entries,
        status: DropifyStatus.error,
        error: error,
      );
    }
  }

  void _handleOpen() {
    if (!_controller.isOpen) {
      _controller.open();
    }
    final DropifyDataSource<T>? source = widget.dataSource;
    if (source is AsyncDropifyDataSource<T> &&
        source.fetchOnOpen &&
        (_controller.entries.isEmpty || _lastAsyncQuery != _controller.query)) {
      _fetchAsyncNow();
    }
    widget.onOpenChanged?.call(true);
  }

  void _handleClose() {
    if (_controller.isOpen) {
      _controller.close();
    }
    widget.onOpenChanged?.call(false);
  }

  DropifyState<T> _stateFor(RawMenuOverlayInfo? overlayInfo) {
    return DropifyState<T>(
      controller: _controller,
      entries: _controller.entries,
      status: _controller.status,
      error: _controller.error,
      overlayInfo: overlayInfo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropifyControllerScope<T>(
      controller: _controller,
      child: RawMenuAnchor(
        controller: _menuController,
        useRootOverlay: widget.useRootOverlay,
        consumeOutsideTaps: widget.consumeOutsideTaps,
        onOpen: _handleOpen,
        onClose: _handleClose,
        overlayBuilder: (BuildContext context, RawMenuOverlayInfo info) {
          return DropifyControllerScope<T>(
            controller: _controller,
            child: TapRegion(
              groupId: info.tapRegionGroupId,
              consumeOutsideTaps: widget.consumeOutsideTaps,
              child: widget.bodyBuilder(context, _stateFor(info)),
            ),
          );
        },
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
              return widget.anchorBuilder(context, _controller, child);
            },
        child: widget.child,
      ),
    );
  }
}
