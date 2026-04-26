import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('static dropdown opens and selects an item', (tester) async {
    String? value;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropifyDropdown<String>(
            entries: const [
              DropifyEntry(value: 'apple', label: 'Apple'),
              DropifyEntry(value: 'banana', label: 'Banana'),
            ],
            label: 'Fruit',
            onChanged: (next) => value = next,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Fruit'));
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();

    expect(value, 'apple');
  });
}
