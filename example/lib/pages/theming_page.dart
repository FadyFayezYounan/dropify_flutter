import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

import '../theme_demo_keys.dart';

const List<DropifyEntry<String>> _fruitEntries = <DropifyEntry<String>>[
  DropifyEntry<String>(value: 'apple', label: 'Apple'),
  DropifyEntry<String>(value: 'banana', label: 'Banana'),
  DropifyEntry<String>(value: 'coconut', label: 'Coconut'),
  DropifyEntry<String>(value: 'date', label: 'Date'),
];

/// Demonstrates inherited and per-widget Dropify theming.
class ThemingPage extends StatefulWidget {
  /// Creates the theming demo page.
  const ThemingPage({super.key});

  @override
  State<ThemingPage> createState() => _ThemingPageState();
}

class _ThemingPageState extends State<ThemingPage> {
  _ThemeChoice _choice = _ThemeChoice.light;
  String? _staticValue;
  String? _asyncValue;
  String? _paginatedValue;
  List<String> _multiValues = <String>['apple'];

  DropifyThemeData get _theme {
    return switch (_choice) {
      _ThemeChoice.light => DropifyThemeData.light(),
      _ThemeChoice.dark => DropifyThemeData.dark(),
      _ThemeChoice.custom => DropifyThemeData.light().copyWith(
        anchorDecoration: BoxDecoration(
          color: const Color(0xfffffbeb),
          border: Border.all(color: const Color(0xfff59e0b), width: 1.5),
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        ),
        panelDecoration: BoxDecoration(
          color: const Color(0xfffffbeb),
          border: Border.all(color: const Color(0xffd97706)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        ),
        chipBackground: const Color(0xfffde68a),
        focusedItemColor: const Color(0xffffedd5),
        selectedItemTextStyle: const TextStyle(
          color: Color(0xff92400e),
          fontWeight: FontWeight.w700,
        ),
        searchDecoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          prefixIcon: Icon(Icons.tune),
          isDense: true,
        ),
      ),
    };
  }

  Future<List<DropifyEntry<String>>> _fetch(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _filterEntries(query);
  }

  Future<DropifyPage<String>> _fetchPage(int pageKey, String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return DropifyPage<String>(entries: _filterEntries(query));
  }

  List<DropifyEntry<String>> _filterEntries(String query) {
    final String normalized = query.toLowerCase();
    if (normalized.isEmpty) {
      return _fruitEntries;
    }
    return _fruitEntries.where((DropifyEntry<String> entry) {
      return entry.label.toLowerCase().contains(normalized);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return DropifyTheme(
      data: _theme,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Theming')),
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                SegmentedButton<_ThemeChoice>(
                  segments: const <ButtonSegment<_ThemeChoice>>[
                    ButtonSegment<_ThemeChoice>(
                      value: _ThemeChoice.light,
                      label: Text('Light'),
                    ),
                    ButtonSegment<_ThemeChoice>(
                      value: _ThemeChoice.dark,
                      label: Text('Dark'),
                    ),
                    ButtonSegment<_ThemeChoice>(
                      value: _ThemeChoice.custom,
                      label: Text('Custom'),
                    ),
                  ],
                  selected: <_ThemeChoice>{_choice},
                  onSelectionChanged: (Set<_ThemeChoice> value) {
                    setState(() {
                      _choice = value.single;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    OutlinedButton(
                      key: ThemeDemoKeys.lightButton,
                      onPressed: () => _setTheme(_ThemeChoice.light),
                      child: const Text('Light'),
                    ),
                    OutlinedButton(
                      key: ThemeDemoKeys.darkButton,
                      onPressed: () => _setTheme(_ThemeChoice.dark),
                      child: const Text('Dark'),
                    ),
                    OutlinedButton(
                      key: ThemeDemoKeys.customButton,
                      onPressed: () => _setTheme(_ThemeChoice.custom),
                      child: const Text('Custom'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                DropifyDropdown<String>(
                  entries: _fruitEntries,
                  label: 'Static themed fruit',
                  hintText: 'Choose fruit',
                  initialValue: _staticValue,
                  onChanged: (String? value) {
                    setState(() {
                      _staticValue = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropifyAsyncDropdown<String>(
                  fetch: _fetch,
                  queryDebounce: Duration.zero,
                  label: 'Async themed fruit',
                  hintText: 'Search fruit',
                  initialValue: _asyncValue,
                  onChanged: (String? value) {
                    setState(() {
                      _asyncValue = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropifyPaginatedDropdown<String>(
                  fetchPage: _fetchPage,
                  firstPageKey: 1,
                  pageSize: _fruitEntries.length,
                  queryDebounce: Duration.zero,
                  label: 'Paginated themed fruit',
                  hintText: 'Search paged fruit',
                  initialValue: _paginatedValue,
                  onChanged: (String? value) {
                    setState(() {
                      _paginatedValue = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropifyDropdown<String>.multi(
                  entries: _fruitEntries,
                  label: 'Multi themed fruit',
                  hintText: 'Choose fruits',
                  initialValues: _multiValues,
                  onChanged: (List<String> value) {
                    setState(() {
                      _multiValues = value;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _setTheme(_ThemeChoice choice) {
    setState(() {
      _choice = choice;
    });
  }
}

enum _ThemeChoice { light, dark, custom }
