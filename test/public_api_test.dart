import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exports core public API types', () {
    expect(DropifyEntry(value: 'x').value, 'x');
    expect(DropifySelectionMode.single, isA<DropifySelectionMode>());
    expect(DropifySingleValue<String>('x').value, 'x');
    expect(DropifyMultiValue<String>({'x'}).values, {'x'});
    expect(DropifyPagingState<int, String>(), isA<PagingState<int, String>>());
  });
}
