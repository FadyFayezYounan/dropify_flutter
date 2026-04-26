import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

/// Demonstrates paginated Dropify widgets with deterministic fake pages.
class PaginatedPage extends StatefulWidget {
  /// Creates the paginated dropdown demo page.
  const PaginatedPage({super.key});

  @override
  State<PaginatedPage> createState() => _PaginatedPageState();
}

class _PaginatedPageState extends State<PaginatedPage> {
  static const int _pageSize = 20;
  static const int _totalItems = 200;

  String? _singleValue;
  List<String> _multiValues = <String>[];
  bool _pageThreeFailed = false;

  Future<DropifyPage<String>> _fetchPage(int pageKey, String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (query == 'empty') {
      return const DropifyPage<String>(entries: <DropifyEntry<String>>[]);
    }
    if (pageKey == 3 && !_pageThreeFailed) {
      _pageThreeFailed = true;
      throw Exception('Example page 3 failure');
    }
    final String normalized = query.toLowerCase();
    final List<DropifyEntry<String>> allEntries =
        List<DropifyEntry<String>>.generate(_totalItems, (int index) {
          final int number = index + 1;
          return DropifyEntry<String>(
            value: 'item-$number',
            label: 'Item $number',
          );
        }, growable: false);
    final List<DropifyEntry<String>> filtered = normalized.isEmpty
        ? allEntries
        : allEntries
              .where((DropifyEntry<String> entry) {
                return entry.label.toLowerCase().contains(normalized);
              })
              .toList(growable: false);
    final int start = (pageKey - 1) * _pageSize;
    if (start >= filtered.length) {
      return const DropifyPage<String>(entries: <DropifyEntry<String>>[]);
    }
    final int end = (start + _pageSize).clamp(0, filtered.length);
    return DropifyPage<String>(
      entries: filtered.sublist(start, end),
      nextPageKey: end < filtered.length ? pageKey + 1 : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paginated dropdowns')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          const Text('Single-select paginated'),
          const SizedBox(height: 8),
          DropifyPaginatedDropdown<String>(
            fetchPage: _fetchPage,
            firstPageKey: 1,
            pageSize: _pageSize,
            label: 'Item',
            hintText: 'Search paged items',
            searchHint: 'Type empty for no results',
            initialValue: _singleValue,
            newPageErrorBuilder:
                (BuildContext context, Object error, VoidCallback retry) {
                  return TextButton(
                    key: DropifyKeys.pageRetryButton,
                    onPressed: retry,
                    child: Text('Retry page: $error'),
                  );
                },
            noMoreItemsBuilder: (BuildContext context) {
              return const Text('Loaded all available items');
            },
            onChanged: (String? value) {
              setState(() {
                _singleValue = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Text('Selected: ${_singleValue ?? 'none'}'),
          const SizedBox(height: 32),
          const Text('Multi-select paginated'),
          const SizedBox(height: 8),
          DropifyPaginatedDropdown<String>.multi(
            fetchPage: _fetchPage,
            firstPageKey: 1,
            pageSize: _pageSize,
            label: 'Items',
            hintText: 'Search paged items',
            initialValues: _multiValues,
            maxSelection: 4,
            onChanged: (List<String> values) {
              setState(() {
                _multiValues = values;
              });
            },
          ),
          const SizedBox(height: 12),
          Text(
            _multiValues.isEmpty
                ? 'Selected: none'
                : 'Selected: ${_multiValues.join(', ')}',
          ),
        ],
      ),
    );
  }
}
