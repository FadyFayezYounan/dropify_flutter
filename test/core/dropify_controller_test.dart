import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('single controller updates and clears value', () {
    final controller = DropifyController<String>.single(initialValue: 'a');

    expect(controller.value, 'a');
    controller.setValue('b');
    expect(controller.value, 'b');
    controller.clear();
    expect(controller.value, isNull);
  });

  test('multi controller toggles values', () {
    final controller = DropifyController<String>.multi(initialValues: {'a'});

    controller.toggle('b');
    expect(controller.values, {'a', 'b'});
    controller.toggle('a');
    expect(controller.values, {'b'});
  });
}
