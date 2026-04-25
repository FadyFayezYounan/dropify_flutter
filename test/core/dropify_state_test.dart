import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'delegates selection helpers to controller and honors disabled entries',
    () {
      final DropifyController<String> controller =
          DropifyController<String>.multi();
      const DropifyEntry<String> enabled = DropifyEntry<String>(
        value: 'a',
        label: 'A',
      );
      const DropifyEntry<String> disabled = DropifyEntry<String>(
        value: 'b',
        label: 'B',
        enabled: false,
      );
      final DropifyState<String> state = DropifyState<String>(
        controller: controller,
        entries: const <DropifyEntry<String>>[enabled, disabled],
        status: DropifyStatus.data,
      );

      expect(state.toggle('a'), isTrue);
      expect(state.isSelected('a'), isTrue);

      expect(state.toggle('b'), isFalse);
      expect(state.isSelected('b'), isFalse);
      expect(
        controller.lastRejectionReason,
        DropifySelectionRejectionReason.entryDisabled,
      );
    },
  );
}
