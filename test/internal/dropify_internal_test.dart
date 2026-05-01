import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:dropify_flutter/src/internal/_debouncer.dart';
import 'package:dropify_flutter/src/internal/_default_matcher.dart';
import 'package:dropify_flutter/src/internal/_dropify_menu_item_button.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default matcher is trimmed case-insensitive contains', () {
    const entry = DropifyEntry(value: 'eg', label: 'Egypt');

    expect(defaultDropifyMatcher(entry, '  GY  '), isTrue);
    expect(defaultDropifyMatcher(entry, 'zz'), isFalse);
  });

  test('debouncer coalesces actions', () {
    fakeAsync((async) {
      var calls = 0;
      final debouncer = DropifyDebouncer(const Duration(milliseconds: 100));

      debouncer(() => calls++);
      debouncer(() => calls++);
      async.elapse(const Duration(milliseconds: 99));
      expect(calls, 0);
      async.elapse(const Duration(milliseconds: 1));
      expect(calls, 1);
      debouncer.dispose();
    });
  });

  testWidgets('menu item button delays activation until post frame', (
    tester,
  ) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyMenuItemButton(
            itemKey: dropifyMenuItemKey('action', 'fallback'),
            semanticsLabel: 'Action',
            onPressed: () => pressed = true,
            child: const Text('Action'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Action'));

    expect(pressed, isFalse);

    await tester.pump();

    expect(pressed, isTrue);
    expect(
      find.byKey(const ValueKey<String>('dropify.item.action')),
      findsOneWidget,
    );
  });
}
