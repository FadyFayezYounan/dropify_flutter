import 'package:dropify_flutter/src/internal/debouncer.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runs only the latest scheduled action after the delay', () {
    fakeAsync((FakeAsync async) {
      final Debouncer debouncer = Debouncer(const Duration(milliseconds: 300));
      final List<String> calls = <String>[];

      debouncer.run(() => calls.add('first'));
      async.elapse(const Duration(milliseconds: 299));
      debouncer.run(() => calls.add('second'));
      async.elapse(const Duration(milliseconds: 299));

      expect(calls, isEmpty);

      async.elapse(const Duration(milliseconds: 1));

      expect(calls, <String>['second']);

      debouncer.dispose();
    });
  });
}
