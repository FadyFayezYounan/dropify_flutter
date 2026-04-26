import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';

// Internal imports are fine for testing
import 'package:dropify_flutter/src/internal/_debouncer.dart';
import 'package:dropify_flutter/src/internal/_default_matcher.dart'
    show defaultMatcher;

import 'package:dropify_flutter/dropify_flutter.dart';

void main() {
  group('Debouncer', () {
    test('calls action after duration', () {
      fakeAsync((async) {
        var called = false;
        final debouncer = Debouncer(
          duration: const Duration(milliseconds: 300),
        );
        debouncer.run(() {
          called = true;
        });

        expect(called, isFalse);
        async.elapse(const Duration(milliseconds: 299));
        expect(called, isFalse);
        async.elapse(const Duration(milliseconds: 1));
        expect(called, isTrue);
      });
    });

    test('coalesces multiple calls within duration', () {
      fakeAsync((async) {
        var callCount = 0;
        final debouncer = Debouncer(
          duration: const Duration(milliseconds: 300),
        );
        debouncer.run(() => callCount++);
        debouncer.run(() => callCount++);
        debouncer.run(() => callCount++);

        expect(callCount, 0);
        async.elapse(const Duration(milliseconds: 300));
        expect(callCount, 1);
      });
    });

    test('cancel prevents pending action', () {
      fakeAsync((async) {
        var called = false;
        final debouncer = Debouncer(
          duration: const Duration(milliseconds: 300),
        );
        debouncer.run(() => called = true);
        debouncer.cancel();

        async.elapse(const Duration(milliseconds: 300));
        expect(called, isFalse);
      });
    });

    test('works with zero duration', () {
      fakeAsync((async) {
        var called = false;
        final debouncer = Debouncer(duration: const Duration(milliseconds: 0));
        debouncer.run(() => called = true);

        async.elapse(const Duration(milliseconds: 1));
        expect(called, isTrue);
      });
    });

    test('cancel after dispose does nothing', () {
      fakeAsync((async) {
        var called = false;
        final debouncer = Debouncer(
          duration: const Duration(milliseconds: 300),
        );
        debouncer.run(() => called = true);
        debouncer.dispose();

        async.elapse(const Duration(milliseconds: 300));
        expect(called, isFalse);
      });
    });
  });

  group('defaultMatcher', () {
    test('returns true for empty query', () {
      final entry = DropifyEntry<int>(value: 42, label: 'Answer');
      expect(defaultMatcher(entry, ''), isTrue);
    });

    test('case-insensitive contains match on label', () {
      final entry = DropifyEntry<int>(value: 1, label: 'Apple');
      expect(defaultMatcher(entry, 'app'), isTrue);
      expect(defaultMatcher(entry, 'APP'), isTrue);
      expect(defaultMatcher(entry, 'ple'), isTrue);
    });

    test('no match for non-matching query', () {
      final entry = DropifyEntry<int>(value: 1, label: 'Apple');
      expect(defaultMatcher(entry, 'banana'), isFalse);
    });

    test('uses searchableText when provided', () {
      final entry = DropifyEntry<int>(
        value: 1,
        label: 'Apple',
        searchableText: 'fruit',
      );
      expect(defaultMatcher(entry, 'fruit'), isTrue);
      expect(defaultMatcher(entry, 'app'), isFalse);
    });

    test('falls back to value.toString when no label', () {
      final entry = DropifyEntry<int>(value: 42);
      expect(defaultMatcher(entry, '42'), isTrue);
    });

    test('trims whitespace from query', () {
      final entry = DropifyEntry<int>(value: 1, label: 'Apple');
      expect(defaultMatcher(entry, '  app  '), isTrue);
    });

    test('priority: searchableText > label > value.toString', () {
      final entryWithSearchable = DropifyEntry<int>(
        value: 42,
        label: 'Green',
        searchableText: 'fruit',
      );
      expect(defaultMatcher(entryWithSearchable, 'fruit'), isTrue);
      expect(defaultMatcher(entryWithSearchable, 'green'), isFalse);
      expect(defaultMatcher(entryWithSearchable, '42'), isFalse);

      final entryWithLabel = DropifyEntry<int>(value: 42, label: 'Green');
      expect(defaultMatcher(entryWithLabel, '42'), isFalse);
      expect(defaultMatcher(entryWithLabel, 'green'), isTrue);
    });
  });
}
