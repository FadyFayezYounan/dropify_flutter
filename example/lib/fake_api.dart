import 'dart:async';

import 'package:dropify_flutter/dropify_flutter.dart';

class Country {
  const Country(this.code, this.name);

  final String code;
  final String name;
}

final countries = <Country>[
  const Country('eg', 'Egypt'),
  const Country('us', 'United States'),
  const Country('gb', 'United Kingdom'),
  const Country('fr', 'France'),
  const Country('de', 'Germany'),
  const Country('jp', 'Japan'),
  const Country('br', 'Brazil'),
  const Country('ca', 'Canada'),
  const Country('au', 'Australia'),
  const Country('in', 'India'),
  ...List.generate(
    100,
    (index) => Country('dummy_$index', 'Dummy Country ${index + 1}'),
  ),
];

Future<List<Country>> searchCountries(
  String query, {
  DropifyCancelToken? cancel,
  int page = 0,
  int pageSize = 5,
}) async {
  await Future<void>.delayed(const Duration(milliseconds: 350));
  cancel?.throwIfCancelled();
  final normalized = query.toLowerCase().trim();
  final filtered = countries
      .where((country) => country.name.toLowerCase().contains(normalized))
      .toList(growable: false);
  final start = page * pageSize;
  if (start >= filtered.length) {
    return const <Country>[];
  }
  return filtered.skip(start).take(pageSize).toList(growable: false);
}
