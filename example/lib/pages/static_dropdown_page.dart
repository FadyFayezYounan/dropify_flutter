import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

class StaticDropdownPage extends StatefulWidget {
  const StaticDropdownPage({super.key});

  @override
  State<StaticDropdownPage> createState() => _StaticDropdownPageState();
}

class _StaticDropdownPageState extends State<StaticDropdownPage> {
  String? _value;
  Set<String> _values = <String>{};

  static const _entries = <DropifyEntry<String>>[
    DropifyEntry(value: 'apple', label: 'Apple'),
    DropifyEntry(value: 'banana', label: 'Banana'),
    DropifyEntry(value: 'cherry', label: 'Cherry'),
    DropifyEntry(value: 'durian', label: 'Durian', enabled: false),
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
          initialValue: _value,
          onChanged: (value) => setState(() => _value = value),
        ),
        const SizedBox(height: 24),
        Text('Selected: ${_value ?? 'none'}'),
        const SizedBox(height: 32),
        DropifyDropdown<String>.multi(
          entries: _entries,
          label: 'Fruits',
          hintText: 'Choose fruits',
          searchable: true,
          showClearButton: true,
          confirmable: true,
          initialValues: _values,
          onChanged: (values) => setState(() => _values = values),
        ),
        const SizedBox(height: 24),
        Text('Selected: ${_values.join(', ')}'),
      ],
    );
  }
}
