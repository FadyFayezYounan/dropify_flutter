import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses value equality and defaults to enabled', () {
    const DropifyEntry<int> first = DropifyEntry<int>(value: 1, label: 'One');
    const DropifyEntry<int> second = DropifyEntry<int>(value: 1, label: 'Uno');

    expect(first, second);
    expect(first.enabled, isTrue);
  });
}
