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
    final page = current.keys?.length ?? 0;
    final token = DropifyCancelToken();
    setState(() {
      _state = current.copyWith(
        isLoading: true,
        error: null,
        cancelToken: token,
      );
    });
    try {
      final items = await searchCountries(
        _state.search ?? '',
        page: page,
        cancel: token,
      );
      if (token.isCancelled) {
        return;
      }
      setState(() {
        _state = _state.copyWith(
          isLoading: false,
          hasNextPage: items.isNotEmpty,
          pages: [...?_state.pages, items],
          keys: [...?_state.keys, page],
          cancelToken: null,
        );
      });
    } catch (error) {
      if (!token.isCancelled) {
        setState(() {
          _state = _state.copyWith(
            isLoading: false,
            error: error,
            cancelToken: null,
          );
        });
      }
    }
  }

  void _search(String query) {
    _state.cancelToken?.cancel();
    setState(() {
      _state = _state.reset().copyWith(search: query);
    });
    _fetchNextPage();
  }

  @override
  void dispose() {
    _state.cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropifyPaginatedDropdown<int, Country>(
          state: _state,
          fetchNextPage: _fetchNextPage,
          onSearchChanged: _search,
          itemLabelBuilder: (country) => country.name,
          label: 'Paged country',
          hintText: 'Search countries',
          showClearButton: true,
          onChanged: (value) => setState(() => _country = value),
        ),
        const SizedBox(height: 16),
        Text('Selected: ${_country?.name ?? 'none'}'),
      ],
    );
  }
}
