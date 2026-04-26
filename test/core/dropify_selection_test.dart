import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DropifyEntry', () {
    test('creates with required value', () {
      const entry = DropifyEntry<int>(value: 42);
      expect(entry.value, 42);
      expect(entry.label, isNull);
      expect(entry.leading, isNull);
      expect(entry.trailing, isNull);
      expect(entry.enabled, isTrue);
      expect(entry.searchableText, isNull);
    });

    test('creates with all optional fields', () {
      const entry = DropifyEntry<int>(
        value: 1,
        label: 'One',
        leading: Text('L'),
        trailing: Text('T'),
        enabled: false,
        searchableText: 'uno',
      );
      expect(entry.value, 1);
      expect(entry.label, 'One');
      expect(entry.leading, isNotNull);
      expect(entry.trailing, isNotNull);
      expect(entry.enabled, isFalse);
      expect(entry.searchableText, 'uno');
    });

    test('equality based on value and optional fields', () {
      const a = DropifyEntry<int>(value: 1, label: 'One');
      const b = DropifyEntry<int>(value: 1, label: 'One');
      const c = DropifyEntry<int>(value: 2, label: 'One');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode consistent with equality', () {
      const a = DropifyEntry<int>(value: 1, label: 'One');
      const b = DropifyEntry<int>(value: 1, label: 'One');

      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('DropifySelectionMode', () {
    test('single and multi are distinct', () {
      expect(
        DropifySelectionMode.single,
        isNot(equals(DropifySelectionMode.multi)),
      );
    });

    test('values list contains two entries', () {
      expect(DropifySelectionMode.values, hasLength(2));
      expect(
        DropifySelectionMode.values,
        contains(DropifySelectionMode.single),
      );
      expect(DropifySelectionMode.values, contains(DropifySelectionMode.multi));
    });
  });

  group('DropifyValue', () {
    test('DropifySingleValue holds single value', () {
      const v = DropifySingleValue<String>('hello');
      expect(v.value, 'hello');
      expect(v, isA<DropifyValue<String>>());
    });

    test('DropifySingleValue with null', () {
      const v = DropifySingleValue<int?>(null);
      expect(v.value, isNull);
    });

    test('DropifyMultiValue holds values set', () {
      final v = DropifyMultiValue<String>({'a', 'b'});
      expect(v.values, containsAll(['a', 'b']));
      expect(v, isA<DropifyValue<String>>());
    });

    test('DropifyMultiValue empty set', () {
      final v = DropifyMultiValue<int>(<int>{});
      expect(v.values, isEmpty);
    });

    test('DropifyValue is sealed', () {
      // Verify sealed hierarchy
      expect(const DropifySingleValue<int>(1), isA<DropifyValue<int>>());
      expect(DropifyMultiValue<int>({1}), isA<DropifyValue<int>>());
    });
  });
}
