import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

class StaticDropdownPage extends StatefulWidget {
  const StaticDropdownPage({super.key});

  @override
  State<StaticDropdownPage> createState() => _StaticDropdownPageState();
}

class _StaticDropdownPageState extends State<StaticDropdownPage> {
  String? _fruit;

  static final _entries = List<DropifyEntry<String>>.generate(
    100,
    (index) => DropifyEntry(
      value: 'item_$index',
      label: 'Item $index',
      enabled: index != 3,
    ),
  );

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
