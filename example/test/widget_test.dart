import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('gallery shows raw demo entry', (WidgetTester tester) async {
    await tester.pumpWidget(const DropifyExampleApp());

    expect(find.text('Raw static demo'), findsOneWidget);
  });
}
