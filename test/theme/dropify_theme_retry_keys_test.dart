import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('default async and paging retry builders use distinct keys', (
    tester,
  ) async {
    final theme = DropifyThemeData.fromMaterial(ThemeData());

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Column(
              children: [
                theme.errorBuilder!(context, 'async failed', () {}),
                theme.firstPageErrorBuilder!(context, 'paging failed', () {}),
              ],
            );
          },
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('dropify.async.retry')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('dropify.paging.retry')),
      findsOneWidget,
    );
  });
}
