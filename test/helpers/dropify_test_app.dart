import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

Widget dropifyTestApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

class DropifyPaginatedHarnessController {
  _DropifyPaginatedHarnessState? _state;

  int fetchNextPageCalls = 0;
  final searchQueries = <String>[];

  DropifyPagingState<int, String> get pagingState => _state!._pagingState;

  void _attach(_DropifyPaginatedHarnessState state) {
    _state = state;
  }

  void _detach(_DropifyPaginatedHarnessState state) {
    if (_state == state) {
      _state = null;
    }
  }
}

class DropifyPaginatedHarness extends StatefulWidget {
  const DropifyPaginatedHarness({
    super.key,
    required this.controller,
    this.searchable = true,
  });

  final DropifyPaginatedHarnessController controller;
  final bool searchable;

  @override
  State<DropifyPaginatedHarness> createState() =>
      _DropifyPaginatedHarnessState();
}

class _DropifyPaginatedHarnessState extends State<DropifyPaginatedHarness> {
  DropifyPagingState<int, String> _pagingState =
      DropifyPagingState<int, String>();

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
  }

  @override
  void didUpdateWidget(covariant DropifyPaginatedHarness oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._detach(this);
      widget.controller._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller._detach(this);
    super.dispose();
  }

  Future<void> _fetchNextPage() async {
    final current = _pagingState;
    if (current.isLoading || !current.hasNextPage) {
      return;
    }
    widget.controller.fetchNextPageCalls += 1;
    setState(() {
      _pagingState = current.copyWith(isLoading: true, error: null);
    });
    await Future<void>.value();
    if (!mounted) {
      return;
    }
    setState(() {
      final pages = _pagingState.pages;
      _pagingState = _pagingState.copyWith(
        isLoading: false,
        hasNextPage: pages == null,
        pages: pages == null
            ? const [
                <String>['Alpha', 'Beta'],
              ]
            : <List<String>>[
                ...pages,
                const ['Gamma'],
              ],
        keys: pages == null ? const [0] : const [0, 1],
      );
    });
  }

  void _handleSearch(String query) {
    widget.controller.searchQueries.add(query);
    setState(() {
      _pagingState = DropifyPagingState<int, String>(search: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropifyPaginatedDropdown<int, String>(
      state: _pagingState,
      fetchNextPage: _fetchNextPage,
      onSearchChanged: _handleSearch,
      itemLabelBuilder: (item) => item,
      hintText: 'Select item',
      searchable: widget.searchable,
    );
  }
}
