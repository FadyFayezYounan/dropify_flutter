import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cancel token is idempotent and exposes cancellation', () async {
    final token = DropifyCancelToken();

    expect(token.isCancelled, isFalse);
    token.cancel();
    token.cancel();

    expect(token.isCancelled, isTrue);
    await expectLater(token.whenCancelled, completes);
    expect(token.throwIfCancelled, throwsA(isA<DropifyCancelledException>()));
  });

  test('controller toggles multi values', () {
    final controller = DropifyController<String>.multi(initialValues: {'a'});

    controller.toggle('b');
    controller.toggle('a');

    expect(controller.values, {'b'});
  });

  test('paging state reset preserves search and creates a new token', () {
    final token = DropifyCancelToken();
    final state = DropifyPagingState<int, String>(
      pages: const [
        <String>['a'],
      ],
      keys: const [1],
      search: 'a',
      cancelToken: token,
      isLoading: true,
    );

    final reset = state.reset();

    expect(reset.pages, isNull);
    expect(reset.keys, isNull);
    expect(reset.search, 'a');
    expect(reset.isLoading, isFalse);
    expect(reset.hasNextPage, isTrue);
    expect(identical(reset.cancelToken, token), isFalse);
  });
}
