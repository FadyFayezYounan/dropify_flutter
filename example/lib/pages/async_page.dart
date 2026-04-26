import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

const List<DropifyEntry<String>> _fruitEntries = <DropifyEntry<String>>[
  DropifyEntry<String>(value: 'apple', label: 'Apple'),
  DropifyEntry<String>(value: 'apricot', label: 'Apricot'),
  DropifyEntry<String>(value: 'banana', label: 'Banana'),
  DropifyEntry<String>(value: 'blackberry', label: 'Blackberry'),
  DropifyEntry<String>(value: 'blueberry', label: 'Blueberry'),
  DropifyEntry<String>(value: 'coconut', label: 'Coconut'),
  DropifyEntry<String>(value: 'date', label: 'Date'),
  DropifyEntry<String>(value: 'dragonfruit', label: 'Dragonfruit'),
  DropifyEntry<String>(value: 'grape', label: 'Grape'),
  DropifyEntry<String>(value: 'kiwi', label: 'Kiwi'),
  DropifyEntry<String>(value: 'lemon', label: 'Lemon'),
  DropifyEntry<String>(value: 'lime', label: 'Lime'),
  DropifyEntry<String>(value: 'mango', label: 'Mango'),
  DropifyEntry<String>(value: 'melon', label: 'Melon'),
  DropifyEntry<String>(value: 'orange', label: 'Orange'),
  DropifyEntry<String>(value: 'papaya', label: 'Papaya'),
  DropifyEntry<String>(value: 'peach', label: 'Peach'),
  DropifyEntry<String>(value: 'pear', label: 'Pear'),
  DropifyEntry<String>(value: 'plum', label: 'Plum'),
  DropifyEntry<String>(value: 'strawberry', label: 'Strawberry'),
];

/// Demonstrates the default async Dropify widgets.
class AsyncPage extends StatefulWidget {
  /// Creates the async dropdown demo page.
  const AsyncPage({super.key});

  @override
  State<AsyncPage> createState() => _AsyncPageState();
}

class _AsyncPageState extends State<AsyncPage> {
  String? _singleValue;
  List<String> _multiValues = <String>[];
  int _requestToken = 0;

  Future<List<DropifyEntry<String>>> _fetch(String query) async {
    final int token = _requestToken + 1;
    _requestToken = token;
    debugPrint('Async Dropify request #$token for "$query"');
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (query == 'err') {
      throw StateError('Example async failure');
    }
    if (query == 'empty') {
      return List<DropifyEntry<String>>.empty();
    }
    final String normalized = query.toLowerCase();
    if (normalized.isEmpty) {
      return _fruitEntries;
    }
    return _fruitEntries
        .where((DropifyEntry<String> entry) {
          return entry.label.toLowerCase().contains(normalized);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Async dropdowns')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          const Text('Single-select async'),
          const SizedBox(height: 8),
          DropifyAsyncDropdown<String>(
            fetch: _fetch,
            label: 'Fruit',
            hintText: 'Search remote fruit',
            searchHint: 'Type err or empty',
            initialValue: _singleValue,
            loadingBuilder: (BuildContext context) {
              return const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Fetching fruit...'),
                ],
              );
            },
            errorBuilder:
                (BuildContext context, Object error, VoidCallback retry) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('$error'),
                      TextButton(
                        key: DropifyKeys.retryButton,
                        onPressed: retry,
                        child: const Text('Retry async request'),
                      ),
                    ],
                  );
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
          const Text('Multi-select async'),
          const SizedBox(height: 8),
          DropifyAsyncDropdown<String>.multi(
            fetch: _fetch,
            label: 'Fruits',
            hintText: 'Search remote fruits',
            initialValues: _multiValues,
            maxSelection: 3,
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
