import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

import '../raw_demo_keys.dart';

const List<DropifyEntry<String>> _entries = <DropifyEntry<String>>[
  DropifyEntry<String>(value: 'apple', label: 'Apple'),
  DropifyEntry<String>(value: 'banana', label: 'Banana'),
  DropifyEntry<String>(value: 'coconut', label: 'Coconut'),
  DropifyEntry<String>(value: 'disabled', label: 'Disabled', enabled: false),
];

/// Demonstrates custom UI built directly on [RawDropify].
class RawPage extends StatelessWidget {
  /// Creates the raw demo page.
  const RawPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RawDropify')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: <Widget>[
            Text('Single-select'),
            _RawDemoDropdown(key: RawDemoKeys.singleAnchor, isMulti: false),
            Text('Multi-select'),
            _RawDemoDropdown(key: RawDemoKeys.multiAnchor, isMulti: true),
          ],
        ),
      ),
    );
  }
}

class _RawDemoDropdown extends StatefulWidget {
  const _RawDemoDropdown({super.key, required this.isMulti});

  final bool isMulti;

  @override
  State<_RawDemoDropdown> createState() => _RawDemoDropdownState();
}

class _RawDemoDropdownState extends State<_RawDemoDropdown> {
  late final DropifyController<String> _controller = widget.isMulti
      ? DropifyController<String>.multi()
      : DropifyController<String>.single();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget rawDropify = widget.isMulti
        ? RawDropify<String>.multi(
            controller: _controller,
            dataSource: const StaticDropifyDataSource<String>(
              entries: _entries,
            ),
            anchorBuilder: _anchorBuilder,
            bodyBuilder: _bodyBuilder,
          )
        : RawDropify<String>(
            controller: _controller,
            dataSource: const StaticDropifyDataSource<String>(
              entries: _entries,
            ),
            anchorBuilder: _anchorBuilder,
            bodyBuilder: _bodyBuilder,
          );
    return rawDropify;
  }

  Widget _anchorBuilder(
    BuildContext context,
    DropifyController<String> controller,
    Widget? child,
  ) {
    final String label = controller.isMulti
        ? (controller.multiValues.isEmpty
              ? 'Choose fruits'
              : controller.multiValues.join(', '))
        : (controller.singleValue ?? 'Choose a fruit');
    return OutlinedButton.icon(
      onPressed: controller.isOpen ? controller.close : controller.open,
      icon: Icon(controller.isOpen ? Icons.expand_less : Icons.expand_more),
      label: Text(label),
    );
  }

  Widget _bodyBuilder(BuildContext context, DropifyState<String> state) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          key: RawDemoKeys.panel,
          width: 260,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  key: RawDemoKeys.searchField,
                  decoration: const InputDecoration(hintText: 'Search'),
                  onChanged: state.controller.setQuery,
                ),
                const SizedBox(height: 8),
                for (final DropifyEntry<String> entry in state.entries)
                  CheckboxListTile(
                    key: RawDemoKeys.row(entry.value),
                    value: state.isSelected(entry.value),
                    enabled: entry.enabled,
                    dense: true,
                    title: Text(entry.label),
                    onChanged: entry.enabled
                        ? (_) => state.toggle(entry.value)
                        : null,
                  ),
                if (state.entries.isEmpty) const Text('No matches'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
