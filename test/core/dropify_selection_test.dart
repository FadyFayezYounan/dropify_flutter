import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('entry exposes effective search text fallback', () {
    expect(const DropifyEntry(value: 1).effectiveSearchText, '1');
    expect(
      const DropifyEntry(value: 1, label: 'One').effectiveSearchText,
      'One',
    );
    expect(
      const DropifyEntry(
        value: 1,
        label: 'One',
        searchableText: 'Uno',
      ).effectiveSearchText,
      'Uno',
    );
  });

  test('dropify values compare by contained values', () {
    expect(
      const DropifySingleValue<String>('a'),
      const DropifySingleValue<String>('a'),
    );
    expect(
      const DropifyMultiValue<String>({'a', 'b'}),
      const DropifyMultiValue<String>({'b', 'a'}),
    );
  });

  test('controller selection can use stable identity keys', () {
    final controller = DropifyController<_Record>.multi(
      initialValues: {_Record(1, 'old')},
    );

    controller.attach(open: () {}, close: () {}, keyOf: (item) => item.id);

    expect(controller.isSelected(_Record(1, 'new')), isTrue);
    controller.toggle(_Record(1, 'new'));
    expect(controller.values, isEmpty);
  });
}

class _Record {
  const _Record(this.id, this.label);

  final int id;
  final String label;
}
