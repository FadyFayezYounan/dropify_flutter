import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public import exposes Phase 1 APIs', () {
    const DropifyEntry<int> entry = DropifyEntry<int>(value: 1, label: 'One');
    final DropifyController<int> controller = DropifyController<int>.single();

    expect(entry.value, 1);
    expect(controller.singleValue, isNull);
    expect(DropifyStatus.values, contains(DropifyStatus.data));
    expect(DropifyThemeData.light(), isA<DropifyThemeData>());
  });
}
