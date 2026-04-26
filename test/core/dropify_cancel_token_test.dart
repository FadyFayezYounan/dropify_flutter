import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DropifyCancelToken', () {
    test('isCancelled is false by default', () {
      final token = DropifyCancelToken();
      expect(token.isCancelled, isFalse);
    });

    test('cancel sets isCancelled to true', () {
      final token = DropifyCancelToken();
      token.cancel();
      expect(token.isCancelled, isTrue);
    });

    test('cancel is idempotent', () {
      final token = DropifyCancelToken();
      token.cancel();
      token.cancel();
      expect(token.isCancelled, isTrue);
    });

    test('whenCancelled completes once on cancel', () async {
      final token = DropifyCancelToken();
      expectLater(token.whenCancelled, completes);
      token.cancel();
    });

    test('throwIfCancelled throws DropifyCancelledException after cancel', () {
      final token = DropifyCancelToken();
      token.cancel();
      expect(
        () => token.throwIfCancelled(),
        throwsA(isA<DropifyCancelledException>()),
      );
    });

    test('throwIfCancelled does not throw before cancel', () {
      final token = DropifyCancelToken();
      expect(() => token.throwIfCancelled(), returnsNormally);
    });
  });

  group('DropifyCancelledException', () {
    test('is const and implements Exception', () {
      const exc = DropifyCancelledException();
      expect(exc, isA<Exception>());
      expect(exc.toString(), contains('cancelled'));
    });
  });
}
