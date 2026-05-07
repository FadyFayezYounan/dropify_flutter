import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cancel is idempotent and completes whenCancelled', () async {
    final token = DropifyCancelToken();

    expect(token.isCancelled, isFalse);
    token.cancel();
    token.cancel();

    expect(token.isCancelled, isTrue);
    await expectLater(token.whenCancelled, completes);
    expect(token.throwIfCancelled, throwsA(isA<DropifyCancelledException>()));
  });
}
