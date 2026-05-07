import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('copyWith and reset preserve dropify metadata intentionally', () {
    final token = DropifyCancelToken();
    final state = DropifyPagingState<int, String>(
      pages: const [
        ['a'],
      ],
      keys: const [0],
      search: 'a',
      cancelToken: token,
    );

    expect(state.copyWith(search: 'b').search, 'b');
    final reset = state.reset();
    expect(reset.pages, isNull);
    expect(reset.keys, isNull);
    expect(reset.search, 'a');
    expect(reset.cancelToken, isNot(same(token)));
  });
}
