import 'dart:async';

import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';

class ControlledStringFetcher {
  final requests = <ControlledStringRequest>[];

  Future<List<String>> call(
    String query, {
    required DropifyCancelToken cancel,
  }) {
    final request = ControlledStringRequest(query: query, cancel: cancel);
    requests.add(request);
    return request.future;
  }
}

class ControlledStringRequest {
  ControlledStringRequest({required this.query, required this.cancel});

  final String query;
  final DropifyCancelToken cancel;
  final _completer = Completer<List<String>>();

  Future<List<String>> get future => _completer.future;

  void complete(List<String> items) => _completer.complete(items);

  void fail(Object error) =>
      _completer.completeError(error, StackTrace.current);
}

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

Widget keyedStringItemBuilder(
  BuildContext context,
  String item,
  bool selected,
  VoidCallback onTap,
) {
  return InkWell(
    key: ValueKey<String>('dropify.test.row.$item'),
    onTap: onTap,
    child: SizedBox(height: 40, child: Text(item)),
  );
}

Widget keyedPaginatedStringItemBuilder(
  BuildContext context,
  String item,
  int index,
  bool selected,
  VoidCallback onTap,
) {
  return InkWell(
    key: ValueKey<String>('dropify.test.pageRow.$index.$item'),
    onTap: onTap,
    child: SizedBox(height: 40, child: Text(item)),
  );
}
