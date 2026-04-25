import 'package:dropify_flutter/src/internal/default_matcher.dart';
import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'matches empty query and case-insensitive contains without trimming',
    () {
      const DropifyEntry<int> entry = DropifyEntry<int>(
        value: 1,
        label: 'Apple',
      );

      expect(defaultDropifyMatcher(entry, ''), isTrue);
      expect(defaultDropifyMatcher(entry, 'APP'), isTrue);
      expect(defaultDropifyMatcher(entry, ' app'), isFalse);
    },
  );
}
