import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example app renders demo tabs', (tester) async {
    await tester.pumpWidget(const DropifyExampleApp());

    expect(find.text('Dropify Flutter'), findsOneWidget);
    expect(find.text('Static'), findsOneWidget);
    expect(find.text('Async'), findsOneWidget);
    expect(find.text('Paged'), findsOneWidget);
  });
}
