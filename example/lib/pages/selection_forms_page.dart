import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

class SelectionFormsPage extends StatefulWidget {
  const SelectionFormsPage({super.key});

  @override
  State<SelectionFormsPage> createState() => _SelectionFormsPageState();
}

class _SelectionFormsPageState extends State<SelectionFormsPage> {
  final _formKey = GlobalKey<FormState>();
  Set<String> _selected = <String>{};

  static const _entries = <DropifyEntry<String>>[
    DropifyEntry(value: 'red', label: 'Red'),
    DropifyEntry(value: 'green', label: 'Green'),
    DropifyEntry(value: 'blue', label: 'Blue'),
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropifyDropdown<String>.multi(
            entries: _entries,
            label: 'Colors',
            hintText: 'Pick at least two',
            showClearButton: true,
            confirmable: true,
            onChanged: (values) => setState(() => _selected = values),
            validator: (value) {
              final selected = switch (value) {
                DropifyMultiValue<String>(:final values) => values,
                _ => <String>{},
              };
              return selected.length < 2 ? 'Choose at least two colors' : null;
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _formKey.currentState?.validate(),
            child: const Text('Validate'),
          ),
          const SizedBox(height: 16),
          Text('Selected: ${_selected.join(', ')}'),
        ],
      ),
    );
  }
}
