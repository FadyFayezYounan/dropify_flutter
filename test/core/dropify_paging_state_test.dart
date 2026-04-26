import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DropifyPagingState defaults', () {
    test('default constructor matches PagingState defaults', () {
      final state = DropifyPagingState<int, String>();
      expect(state.pages, isNull);
      expect(state.keys, isNull);
      expect(state.error, isNull);
      expect(state.hasNextPage, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.search, isNull);
      expect(state.cancelToken, isNull);
    });

    test('is a PagingStateBase', () {
      final state = DropifyPagingState<int, String>();
      expect(state, isA<PagingStateBase<int, String>>());
    });
  });

  group('DropifyPagingState copyWith', () {
    test('preserves fields when not specified', () {
      final state = DropifyPagingState<int, String>(
        pages: [
          ['a', 'b'],
        ],
        keys: [1],
        search: 'query',
        isLoading: true,
      );

      final copy = state.copyWith(hasNextPage: false);

      expect(copy.pages, equals(state.pages));
      expect(copy.keys, equals(state.keys));
      expect(copy.search, equals(state.search));
      expect(copy.isLoading, isTrue);
      expect(copy.hasNextPage, isFalse);
    });

    test('can set to null via Omit', () {
      final state = DropifyPagingState<int, String>(search: 'q');
      final copy = state.copyWith(search: null);

      expect(copy.search, isNull);
    });

    test('error and isLoading can be updated', () {
      final state = DropifyPagingState<int, String>();
      final copy = state.copyWith(isLoading: true, error: 'fail');

      expect(copy.isLoading, isTrue);
      expect(copy.error, 'fail');
    });

    test('copyWith with cancelToken', () {
      final state = DropifyPagingState<int, String>();
      final token = DropifyCancelToken();
      final copy = state.copyWith(cancelToken: token);

      expect(copy.cancelToken, same(token));
    });

    test('Omit semantics for pages', () {
      final state = DropifyPagingState<int, String>(
        pages: [
          ['a'],
          ['b'],
        ],
        keys: [1, 2],
      );
      final copy = state.copyWith();

      expect(copy.pages, equals(state.pages));
      expect(copy.keys, equals(state.keys));
    });
  });

  group('DropifyPagingState reset', () {
    test('clears pages, keys, error, isLoading but preserves search', () {
      final state = DropifyPagingState<int, String>(
        pages: [
          ['a', 'b'],
        ],
        keys: [1],
        error: 'fail',
        hasNextPage: false,
        isLoading: true,
        search: 'needle',
      );

      final reset = state.reset();

      expect(reset.pages, isNull);
      expect(reset.keys, isNull);
      expect(reset.error, isNull);
      expect(reset.isLoading, isFalse);
      expect(reset.hasNextPage, isTrue);
      expect(reset.search, equals('needle'));
    });

    test('mints a fresh cancelToken', () {
      final state = DropifyPagingState<int, String>(
        cancelToken: DropifyCancelToken(),
      );

      final reset = state.reset();

      expect(reset.cancelToken, isNotNull);
      expect(reset.cancelToken, isNot(same(state.cancelToken)));
    });

    test('reset preserves null search', () {
      final state = DropifyPagingState<int, String>(search: null);
      final reset = state.reset();

      expect(reset.search, isNull);
    });
  });

  group('DropifyPagingState equality', () {
    test('equal when all fields match', () {
      final a = DropifyPagingState<int, String>(
        pages: [
          ['x'],
        ],
        keys: [1],
        search: 'q',
      );
      final b = DropifyPagingState<int, String>(
        pages: [
          ['x'],
        ],
        keys: [1],
        search: 'q',
      );
      expect(a, equals(b));
    });

    test('not equal when search differs', () {
      final a = DropifyPagingState<int, String>(search: 'a');
      final b = DropifyPagingState<int, String>(search: 'b');
      expect(a, isNot(equals(b)));
    });

    test('not equal when cancelToken differs', () {
      final tokenA = DropifyCancelToken();
      final tokenB = DropifyCancelToken();
      tokenA.cancel();
      final a = DropifyPagingState<int, String>(cancelToken: tokenA);
      final b = DropifyPagingState<int, String>(cancelToken: tokenB);
      expect(a, isNot(equals(b)));
    });

    test('hashCode consistent with equality', () {
      final a = DropifyPagingState<int, String>(search: 'q');
      final b = DropifyPagingState<int, String>(search: 'q');
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
