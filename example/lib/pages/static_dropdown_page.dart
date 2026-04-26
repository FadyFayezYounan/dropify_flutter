import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

class StaticDropdownPage extends StatefulWidget {
  const StaticDropdownPage({super.key});

  @override
  State<StaticDropdownPage> createState() => _StaticDropdownPageState();
}

class _StaticDropdownPageState extends State<StaticDropdownPage> {
  String? _fruit;

  static const _entries = <DropifyEntry<String>>[
    DropifyEntry(value: 'apple', label: 'Apple'),
    DropifyEntry(value: 'banana', label: 'Banana'),
    DropifyEntry(value: 'cherry', label: 'Cherry'),
    DropifyEntry(value: 'disabled', label: 'Disabled fruit', enabled: false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropifyDropdown<String>(
          entries: _entries,
          label: 'Fruit',
          hintText: 'Choose a fruit',
          searchable: true,
          showClearButton: true,
          initialValue: _fruit,
          onChanged: (value) => setState(() => _fruit = value),
        ),
        const SizedBox(height: 16),
        Text('Selected: ${_fruit ?? 'none'}'),
      ],
    );
  }
}
