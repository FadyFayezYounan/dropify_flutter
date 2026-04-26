import 'package:flutter/material.dart';
import 'package:dropify_flutter/dropify_flutter.dart';

void main() {
  runApp(const DropifyExampleApp());
}

class DropifyExampleApp extends StatelessWidget {
  const DropifyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dropify Demo',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const DropifyHomeScreen(),
    );
  }
}

class DropifyHomeScreen extends StatelessWidget {
  const DropifyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dropify Demos')),
      body: ListView(
        children: const [
          _DemoTile(title: 'Static Dropdown', page: StaticDropdownPage()),
          _DemoTile(title: 'Async Dropdown', page: AsyncDropdownPage()),
          _DemoTile(title: 'Multi Select', page: MultiSelectPage()),
          _DemoTile(title: 'Themed', page: ThemedPage()),
          _DemoTile(title: 'Validation', page: ValidationPage()),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({required this.title, required this.page});
  final String title;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}

// --- Static Dropdown Page ---

class StaticDropdownPage extends StatefulWidget {
  const StaticDropdownPage({super.key});
  @override
  State<StaticDropdownPage> createState() => _StaticDropdownPageState();
}

class _StaticDropdownPageState extends State<StaticDropdownPage> {
  String? _selected;

  static const _entries = [
    DropifyEntry(value: 'apple', label: 'Apple'),
    DropifyEntry(value: 'banana', label: 'Banana'),
    DropifyEntry(value: 'cherry', label: 'Cherry'),
    DropifyEntry(value: 'date', label: 'Date'),
    DropifyEntry(value: 'elderberry', label: 'Elderberry'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Static Dropdown')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropifyDropdown<String>(
              entries: _entries,
              label: 'Fruit',
              searchable: true,
              onChanged: (v) => setState(() => _selected = v),
            ),
            const SizedBox(height: 16),
            Text('Selected: ${_selected ?? 'none'}'),
          ],
        ),
      ),
    );
  }
}

// --- Async Dropdown Page ---

class AsyncDropdownPage extends StatefulWidget {
  const AsyncDropdownPage({super.key});
  @override
  State<AsyncDropdownPage> createState() => _AsyncDropdownPageState();
}

class _AsyncDropdownPageState extends State<AsyncDropdownPage> {
  String? _selected;

  Future<List<Country>> _fetchCountries(
    String query, {
    required DropifyCancelToken cancel,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (cancel.isCancelled) {
      return [];
    }
    final all = [
      Country('AU', 'Australia'),
      Country('BR', 'Brazil'),
      Country('CA', 'Canada'),
      Country('EG', 'Egypt'),
      Country('FR', 'France'),
      Country('DE', 'Germany'),
      Country('IN', 'India'),
      Country('JP', 'Japan'),
      Country('MX', 'Mexico'),
      Country('US', 'United States'),
    ];
    if (query.isEmpty) {
      return all;
    }
    return all
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Async Dropdown')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropifyAsyncDropdown<Country>(
              fetcher: _fetchCountries,
              itemLabelBuilder: (c) => c.name,
              label: 'Country',
              loadingBuilder: (_) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              emptyBuilder: (_, hasQuery) =>
                  Center(child: Text(hasQuery ? 'No matches' : 'No countries')),
              onChanged: (v) => setState(() {
                _selected = v?.name;
              }),
            ),
            const SizedBox(height: 16),
            Text('Selected: ${_selected ?? 'none'}'),
          ],
        ),
      ),
    );
  }
}

class Country {
  const Country(this.code, this.name);
  final String code;
  final String name;
}

// --- Multi Select Page ---

class MultiSelectPage extends StatefulWidget {
  const MultiSelectPage({super.key});
  @override
  State<MultiSelectPage> createState() => _MultiSelectPageState();
}

class _MultiSelectPageState extends State<MultiSelectPage> {
  Set<String> _selected = {};

  static const _entries = [
    DropifyEntry(value: 'apple', label: 'Apple'),
    DropifyEntry(value: 'banana', label: 'Banana'),
    DropifyEntry(value: 'cherry', label: 'Cherry'),
    DropifyEntry(value: 'date', label: 'Date'),
    DropifyEntry(value: 'elderberry', label: 'Elderberry'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi Select')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropifyDropdown<String>.multi(
              entries: _entries,
              label: 'Fruits',
              searchable: true,
              showClearButton: true,
              onChangedMulti: (v) => setState(() => _selected = v),
              confirmable: true,
              confirmLabel: 'Done',
              cancelLabel: 'Back',
            ),
            const SizedBox(height: 16),
            Text('Selected: ${_selected.join(', ')}'),
          ],
        ),
      ),
    );
  }
}

// --- Themed Page ---

class ThemedPage extends StatelessWidget {
  const ThemedPage({super.key});

  @override
  Widget build(BuildContext context) {
    const entries = [
      DropifyEntry(value: 'apple', label: 'Apple'),
      DropifyEntry(value: 'banana', label: 'Banana'),
      DropifyEntry(value: 'cherry', label: 'Cherry'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Themed Dropdown')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: DropifyTheme(
          data: DropifyThemeData(
            panelMaxHeight: 200,
            entrySelectedIcon: Icons.star,
          ),
          child: DropifyDropdown<String>(
            entries: entries,
            label: 'Custom Theme',
            searchable: true,
          ),
        ),
      ),
    );
  }
}

// --- Validation Page ---

class ValidationPage extends StatefulWidget {
  const ValidationPage({super.key});
  @override
  State<ValidationPage> createState() => _ValidationPageState();
}

class _ValidationPageState extends State<ValidationPage> {
  final _formKey = GlobalKey<FormState>();

  static const _entries = [
    DropifyEntry(value: 'apple', label: 'Apple'),
    DropifyEntry(value: 'banana', label: 'Banana'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropifyDropdown<String>(
                entries: _entries,
                label: 'Required',
                validator: (value) {
                  final v = value as DropifySingleValue<String>;
                  if (v.value == null) {
                    return 'Please select a fruit';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState!.validate();
                },
                child: const Text('Validate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
