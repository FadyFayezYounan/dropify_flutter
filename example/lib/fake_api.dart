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
  Country('fr', 'France'),
  Country('de', 'Germany'),
  Country('jp', 'Japan'),
  Country('br', 'Brazil'),
];

Future<List<Country>> searchCountries(
  String query, {
  int page = 1,
  int pageSize = 20,
  DropifyCancelToken? cancel,
}) async {
  await Future<void>.delayed(const Duration(milliseconds: 300));
  cancel?.throwIfCancelled();
  final normalized = query.toLowerCase().trim();
  final filtered = countries
      .where((country) => country.name.toLowerCase().contains(normalized))
      .toList(growable: false);
  final start = (page - 1) * pageSize;
  if (start >= filtered.length) {
    return const <Country>[];
  }
  return filtered.skip(start).take(pageSize).toList(growable: false);
}
