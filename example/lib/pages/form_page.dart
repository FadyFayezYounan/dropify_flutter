import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

import '../form_demo_keys.dart';

const List<DropifyEntry<String>> _fruitEntries = <DropifyEntry<String>>[
  DropifyEntry<String>(value: 'apple', label: 'Apple'),
  DropifyEntry<String>(value: 'banana', label: 'Banana'),
  DropifyEntry<String>(value: 'coconut', label: 'Coconut'),
];

/// Demonstrates Dropify form fields.
class FormPage extends StatefulWidget {
  /// Creates the form dropdown demo page.
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _savedFruit;
  List<String> _savedRemoteFruits = List<String>.empty();
  String? _savedPagedItem;

  Future<List<DropifyEntry<String>>> _fetchFruit(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final String normalized = query.toLowerCase();
    return _fruitEntries
        .where((DropifyEntry<String> entry) {
          return normalized.isEmpty ||
              entry.label.toLowerCase().contains(normalized);
        })
        .toList(growable: false);
  }

  Future<DropifyPage<String>> _fetchPage(int pageKey, String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final List<DropifyEntry<String>> entries =
        List<DropifyEntry<String>>.generate(10, (int index) {
          final int value = index + 1;
          return DropifyEntry<String>(
            value: 'item-$value',
            label: 'Item $value',
          );
        }, growable: false);
    return DropifyPage<String>(entries: entries, nextPageKey: null);
  }

  void _submit() {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form dropdowns')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            DropifyFormField<String>(
              source: const DropifyFormSource<String>.entries(
                entries: _fruitEntries,
              ),
              label: 'Required fruit',
              hintText: 'Choose a fruit',
              validator: (String? value) {
                return value == null ? 'Choose a fruit before saving' : null;
              },
              onSaved: (String? value) {
                _savedFruit = value;
              },
            ),
            const SizedBox(height: 24),
            DropifyFormField<String>.multi(
              source: DropifyFormSource<String>.async(fetch: _fetchFruit),
              label: 'Async fruits',
              hintText: 'Choose remote fruits',
              onSaved: (List<String>? values) {
                _savedRemoteFruits = values ?? List<String>.empty();
              },
            ),
            const SizedBox(height: 24),
            DropifyFormField<String>(
              source: DropifyFormSource<String>.paginated(
                fetchPage: _fetchPage,
              ),
              label: 'Paginated item',
              hintText: 'Choose a paged item',
              onSaved: (String? value) {
                _savedPagedItem = value;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: FormDemoKeys.submitButton,
              onPressed: _submit,
              child: const Text('Submit form'),
            ),
            const SizedBox(height: 16),
            Text('Saved fruit: ${_savedFruit ?? 'none'}'),
            Text(
              _savedRemoteFruits.isEmpty
                  ? 'Saved async fruits: none'
                  : 'Saved async fruits: ${_savedRemoteFruits.join(', ')}',
            ),
            Text('Saved paginated item: ${_savedPagedItem ?? 'none'}'),
          ],
        ),
      ),
    );
  }
}
