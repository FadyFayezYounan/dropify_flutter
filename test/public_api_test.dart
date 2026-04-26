import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Public API exports', () {
    test('DropifyCancelToken is exported', () {
      expect(DropifyCancelToken, isA<Type>());
    });

    test('DropifyCancelledException is exported', () {
      expect(const DropifyCancelledException(), isA<Exception>());
    });

    test('DropifyEntry is exported', () {
      expect(const DropifyEntry<int>(value: 42), isA<DropifyEntry<int>>());
    });

    test('DropifySelectionMode is exported', () {
      expect(DropifySelectionMode.single, isA<DropifySelectionMode>());
    });

    test('DropifyValue subclasses exported', () {
      expect(const DropifySingleValue<int>(1), isA<DropifyValue<int>>());
      expect(const DropifyMultiValue<int>({1}), isA<DropifyValue<int>>());
    });

    test('DropifyController exported', () {
      expect(DropifyController<int>.single(), isA<DropifyController<int>>());
    });

    test('DropifyPagingState exported', () {
      expect(
        DropifyPagingState<int, String>(),
        isA<DropifyPagingState<int, String>>(),
      );
    });

    test('PagingState re-exported', () {
      // Verify PagingState is accessible through dropify_flutter
      final pagingState = PagingState<int, String>();
      expect(pagingState, isA<PagingState<int, String>>());
    });

    test('PagingStateBase re-exported', () {
      expect(PagingStateBase, isA<Type>());
    });
  });
}
