import 'package:dropify_flutter/dropify_flutter.dart';

const fruitEntries = <DropifyEntry<String>>[
  DropifyEntry(value: 'apple', label: 'Apple'),
  DropifyEntry(value: 'banana', label: 'Banana'),
  DropifyEntry(value: 'disabled', label: 'Disabled', enabled: false),
];

Future<List<String>> fakeStringFetcher(
  String query, {
  required DropifyCancelToken cancel,
}) async {
  cancel.throwIfCancelled();
  return fruitEntries
      .map((entry) => entry.value)
      .where((value) => value.contains(query))
      .toList(growable: false);
}
