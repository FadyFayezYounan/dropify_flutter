import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

import '../fake_api.dart';

class PaginatedDropdownPage extends StatefulWidget {
  const PaginatedDropdownPage({super.key});

  @override
  State<PaginatedDropdownPage> createState() => _PaginatedDropdownPageState();
}

class _PaginatedDropdownPageState extends State<PaginatedDropdownPage> {
  DropifyPagingState<int, Country> _state = DropifyPagingState<int, Country>();
  Country? _country;

  Future<void> _fetchNextPage() async {
    final current = _state;
    if (current.isLoading || !current.hasNextPage) {
      return;
    }
    final keys = current.keys;
    final page = (keys == null || keys.isEmpty ? 0 : keys.last) + 1;
    current.cancelToken?.cancel();
    final token = DropifyCancelToken();
    setState(
      () => _state = current.copyWith(
        isLoading: true,
        error: null,
        cancelToken: token,
      ),
    );
    try {
      final items = await searchCountries(
        current.search ?? '',
        page: page,
        pageSize: 3,
        cancel: token,
      );
      if (!mounted || token.isCancelled) {
        return;
      }
      setState(() {
        _state = _state.copyWith(
          pages: <List<Country>>[...?_state.pages, items],
          keys: <int>[...?_state.keys, page],
          hasNextPage: items.isNotEmpty,
          isLoading: false,
          error: null,
          cancelToken: null,
        );
      });
    } catch (error) {
      if (!mounted || token.isCancelled) {
        return;
      }
      setState(
        () => _state = _state.copyWith(
          isLoading: false,
          error: error,
          cancelToken: null,
        ),
      );
    }
  }

  void _search(String query) {
    _state.cancelToken?.cancel();
    setState(() => _state = _state.reset().copyWith(search: query));
    _fetchNextPage();
  }

  @override
  void dispose() {
    _state.cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropifyPaginatedDropdown<int, Country>(
            state: _state,
            fetchNextPage: _fetchNextPage,
            onSearchChanged: _search,
            itemLabelBuilder: (country) => country.name,
            label: 'Paged country',
            hintText: 'Search countries',
            showClearButton: true,
            onChanged: (country) => setState(() => _country = country),
          ),
          const SizedBox(height: 24),
          Text('Selected: ${_country?.name ?? 'none'}'),
        ],
      ),
    );
  }
}
