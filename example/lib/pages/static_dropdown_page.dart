import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

class StaticDropdownPage extends StatefulWidget {
  const StaticDropdownPage({super.key});

  @override
  State<StaticDropdownPage> createState() => _StaticDropdownPageState();
}

class _StaticDropdownPageState extends State<StaticDropdownPage> {
  String? _fruit = 'item_90';
  DropifyMenuBodyMode _bodyMode = DropifyMenuBodyMode.automatic;

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
        DropdownButton<DropifyMenuBodyMode>(
          value: _bodyMode,
          items: const [
            DropdownMenuItem(
              value: DropifyMenuBodyMode.automatic,
              child: Text('Automatic body mode'),
            ),
            DropdownMenuItem(
              value: DropifyMenuBodyMode.eagerColumn,
              child: Text('Eager column body mode'),
            ),
            DropdownMenuItem(
              value: DropifyMenuBodyMode.lazyIndexed,
              child: Text('Lazy indexed body mode'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _bodyMode = value);
            }
          },
        ),
        const SizedBox(height: 16),
        DropifyDropdown<String>(
          entries: _entries,
          label: 'Fruit',
          hintText: 'Choose a fruit',
          searchable: true,
          showClearButton: true,
          menuBodyMode: _bodyMode,
          initialValue: _fruit,
          onChanged: (value) => setState(() => _fruit = value),
        ),
        const SizedBox(height: 16),
        const Text('The initial value is near the end of the 100-item list.'),
        const SizedBox(height: 8),
        Text('Selected: ${_fruit ?? 'none'}'),
      ],
    );
  }
}
