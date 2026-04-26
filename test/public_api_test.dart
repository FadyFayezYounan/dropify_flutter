import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public package exports key v0.1.0 symbols', () {
    expect(DropifyEntry<String>, isNotNull);
    expect(DropifyController<String>.single, isNotNull);
    expect(DropifyCancelToken, isNotNull);
    expect(DropifyPagingState<int, String>, isNotNull);
    expect(RawDropify<String>, isNotNull);
    expect(RawStaticDropify<String>, isNotNull);
    expect(RawAsyncDropify<String>, isNotNull);
    expect(RawPaginatedDropify<int, String>, isNotNull);
    expect(DropifyDropdown<String>, isNotNull);
    expect(DropifyAsyncDropdown<String>, isNotNull);
    expect(DropifyPaginatedDropdown<int, String>, isNotNull);
  });
}
