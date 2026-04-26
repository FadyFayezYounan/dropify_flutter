import 'dart:async';

import 'package:dropify_flutter/dropify_flutter.dart';

class Country {
  const Country(this.code, this.name);

  final String code;
  final String name;
}

const countries = <Country>[
  Country('eg', 'Egypt'),
  Country('us', 'United States'),
  Country('gb', 'United Kingdom'),
  Country('fr', 'France'),
  Country('de', 'Germany'),
  Country('jp', 'Japan'),
  Country('br', 'Brazil'),
  Country('ca', 'Canada'),
  Country('au', 'Australia'),
  Country('in', 'India'),
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
