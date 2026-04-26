import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

import '../fake_api.dart';

class AsyncDropdownPage extends StatefulWidget {
  const AsyncDropdownPage({super.key});

  @override
  State<AsyncDropdownPage> createState() => _AsyncDropdownPageState();
}

class _AsyncDropdownPageState extends State<AsyncDropdownPage> {
  Country? _country;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropifyAsyncDropdown<Country>(
            fetcher: (query, {required cancel}) {
              return searchCountries(query, cancel: cancel);
            },
            itemLabelBuilder: (country) => country.name,
            label: 'Country',
            hintText: 'Search countries',
            showClearButton: true,
            onChanged: (country) => setState(() => _country = country),
          ),
          const SizedBox(height: 24),
          Text('Selected: ${_country?.name ?? 'none'}'),
        ],
      ),
    );
  }
}
