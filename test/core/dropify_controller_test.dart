import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('single controller selects values and rejects multi getters', () {
    final DropifyController<String> controller =
        DropifyController<String>.single(initialValue: 'a');
    int notifications = 0;
    controller.addListener(() => notifications++);

    expect(controller.singleValue, 'a');
    expect(() => controller.multiValues, throwsStateError);

    controller.singleValue = 'b';

    expect(controller.singleValue, 'b');
    expect(notifications, 1);
  });

  test('multi controller toggles values and enforces bounds', () {
    final DropifyController<String> controller =
        DropifyController<String>.multi(
          initialValues: <String>['a'],
          minSelection: 1,
          maxSelection: 2,
        );

    expect(controller.multiValues, <String>['a']);
    expect(() => controller.singleValue, throwsStateError);

    expect(controller.toggle('b'), isTrue);
    expect(controller.multiValues, <String>['a', 'b']);

    expect(controller.toggle('c'), isFalse);
    expect(
      controller.lastRejectionReason,
      DropifySelectionRejectionReason.maxSelectionViolated,
    );

    expect(controller.toggle('b'), isTrue);
    expect(controller.toggle('a'), isFalse);
    expect(
      controller.lastRejectionReason,
      DropifySelectionRejectionReason.minSelectionViolated,
    );
  });

  test('open close query unsupported operations and attach conflict work', () {
    final DropifyController<int> controller = DropifyController<int>.single();
    final Object firstOwner = Object();
    final Object secondOwner = Object();

    controller.open();
    expect(controller.isOpen, isTrue);

    controller.close();
    expect(controller.isOpen, isFalse);

    controller.setQuery('  A');
    expect(controller.query, '  A');

    expect(controller.refresh, throwsUnsupportedError);
    expect(controller.loadMore, throwsUnsupportedError);
    expect(controller.retry, throwsUnsupportedError);

    controller.attach(firstOwner);
    expect(() => controller.attach(secondOwner), throwsFlutterError);
    controller.detach(firstOwner);
    controller.attach(secondOwner);
  });
}
