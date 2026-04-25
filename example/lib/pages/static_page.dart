import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

const List<DropifyEntry<String>> _fruitEntries = <DropifyEntry<String>>[
  DropifyEntry<String>(value: 'apple', label: 'Apple'),
  DropifyEntry<String>(value: 'banana', label: 'Banana'),
  DropifyEntry<String>(value: 'coconut', label: 'Coconut'),
  DropifyEntry<String>(value: 'disabled', label: 'Disabled', enabled: false),
];

/// Demonstrates the default static Dropify widgets.
class StaticPage extends StatefulWidget {
  /// Creates the static dropdown demo page.
  const StaticPage({super.key});

  @override
  State<StaticPage> createState() => _StaticPageState();
}

class _StaticPageState extends State<StaticPage> {
  String? _singleValue;
  List<String> _multiValues = <String>['apple'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Static dropdowns')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          const Text('Single-select'),
          const SizedBox(height: 8),
          DropifyDropdown<String>(
            entries: _fruitEntries,
            label: 'Fruit',
            hintText: 'Choose a fruit',
            searchHint: 'Search fruit',
            initialValue: _singleValue,
            onChanged: (String? value) {
              setState(() {
                _singleValue = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Text('Selected: ${_singleValue ?? 'none'}'),
          const SizedBox(height: 32),
          const Text('Multi-select with custom chips'),
          const SizedBox(height: 8),
          DropifyDropdown<String>.multi(
            entries: _fruitEntries,
            initialValues: _multiValues,
            minSelection: 1,
            maxSelection: 3,
            label: 'Fruits',
            hintText: 'Choose fruits',
            chipBuilder:
                (
                  BuildContext context,
                  DropifyEntry<String> entry,
                  VoidCallback? onDeleted,
                ) {
                  return ActionChip(
                    key: DropifyKeys.chip(entry.value),
                    label: Text(entry.label),
                    onPressed: onDeleted,
                  );
                },
            onChanged: (List<String> values) {
              setState(() {
                _multiValues = values;
              });
            },
          ),
          const SizedBox(height: 12),
          Text('Selected: ${_multiValues.join(', ')}'),
          const SizedBox(height: 32),
          const Text('Custom item builder'),
          const SizedBox(height: 8),
          DropifyDropdown<String>(
            entries: _fruitEntries,
            label: 'Custom row',
            hintText: 'Choose a row',
            itemBuilder:
                (
                  BuildContext context,
                  DropifyEntry<String> entry,
                  bool selected,
                  VoidCallback? onSelect,
                ) {
                  return ListTile(
                    key: DropifyKeys.row(entry.value),
                    enabled: entry.enabled,
                    title: Text(entry.label),
                    subtitle: Text(entry.enabled ? 'Available' : 'Disabled'),
                    trailing: selected ? const Icon(Icons.check) : null,
                    onTap: onSelect,
                  );
                },
          ),
        ],
      ),
    );
  }
}
