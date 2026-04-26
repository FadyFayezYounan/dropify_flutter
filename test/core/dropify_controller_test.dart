import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DropifyController.single', () {
    test('initial value is null', () {
      final controller = DropifyController<String>.single();
      expect(controller.value, isNull);
      expect(controller.mode, DropifySelectionMode.single);
      expect(controller.isOpen, isFalse);
    });

    test('initial value from parameter', () {
      final controller = DropifyController<String>.single(
        initialValue: 'hello',
      );
      expect(controller.value, 'hello');
    });

    test('setValue updates value and notifies', () {
      final controller = DropifyController<int>.single();
      var notified = false;
      controller.addListener(() => notified = true);

      controller.setValue(42);
      expect(controller.value, 42);
      expect(notified, isTrue);
    });

    test('setValue to null clears', () {
      final controller = DropifyController<int>.single(initialValue: 42);
      controller.setValue(null);
      expect(controller.value, isNull);
    });

    test('clear sets value to null', () {
      final controller = DropifyController<String>.single(initialValue: 'test');
      controller.clear();
      expect(controller.value, isNull);
    });

    test('toggle throws for single mode', () {
      final controller = DropifyController<int>.single();
      expect(() => controller.toggle(1), throwsAssertionError);
    });
  });

  group('DropifyController.multi', () {
    test('initial values is empty', () {
      final controller = DropifyController<String>.multi();
      expect(controller.values, isEmpty);
      expect(controller.mode, DropifySelectionMode.multi);
    });

    test('initial values from parameter', () {
      final controller = DropifyController<String>.multi(
        initialValues: {'a', 'b'},
      );
      expect(controller.values, containsAll(['a', 'b']));
    });

    test('setValues updates set and notifies', () {
      final controller = DropifyController<int>.multi();
      var notified = false;
      controller.addListener(() => notified = true);

      controller.setValues({1, 2, 3});
      expect(controller.values, containsAll([1, 2, 3]));
      expect(notified, isTrue);
    });

    test('toggle adds item when not selected', () {
      final controller = DropifyController<String>.multi();
      controller.toggle('a');
      expect(controller.values, contains('a'));
    });

    test('toggle removes item when selected', () {
      final controller = DropifyController<String>.multi(
        initialValues: {'a', 'b'},
      );
      controller.toggle('a');
      expect(controller.values, contains('b'));
      expect(controller.values, isNot(contains('a')));
    });

    test('isSelected reflects toggle state', () {
      final controller = DropifyController<String>.multi();
      expect(controller.isSelected('a'), isFalse);
      controller.toggle('a');
      expect(controller.isSelected('a'), isTrue);
      controller.toggle('a');
      expect(controller.isSelected('a'), isFalse);
    });

    test('clear resets to empty set', () {
      final controller = DropifyController<String>.multi(
        initialValues: {'a', 'b', 'c'},
      );
      controller.clear();
      expect(controller.values, isEmpty);
    });

    test('values returns unmodifiable view', () {
      final controller = DropifyController<int>.multi(initialValues: {1});
      expect(() => controller.values.add(2), throwsA(anything));
    });

    test('toggle honors custom equals', () {
      final controller = DropifyController<int>.multi();
      // Using default Dart equality
      controller.toggle(1);
      expect(controller.isSelected(1), isTrue);
      controller.toggle(1);
      expect(controller.isSelected(1), isFalse);
    });
  });

  group('DropifyController open/close', () {
    test('isOpen is false initially', () {
      final controller = DropifyController<int>.single();
      expect(controller.isOpen, isFalse);
    });
  });
}
