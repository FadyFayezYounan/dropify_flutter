import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

const List<DropifyEntry<String>> _entries = <DropifyEntry<String>>[
  DropifyEntry<String>(value: 'apple', label: 'Apple'),
  DropifyEntry<String>(value: 'banana', label: 'Banana'),
];

void main() {
  testWidgets('single form field validates changes and saves value', (
    tester,
  ) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String? saved;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: DropifyFormField<String>(
              source: const DropifyFormSource<String>.entries(
                entries: _entries,
              ),
              label: 'Fruit',
              hintText: 'Choose fruit',
              validator: (String? value) {
                return value == null ? 'Pick a fruit' : null;
              },
              onSaved: (String? value) {
                saved = value;
              },
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Pick a fruit'), findsOneWidget);

    await tester.tap(find.byKey(DropifyKeys.anchor));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(DropifyKeys.row('banana')));
    await tester.pumpAndSettle();

    expect(formKey.currentState!.validate(), isTrue);
    formKey.currentState!.save();

    expect(saved, 'banana');
  });

  testWidgets('form source routes async and paginated widgets', (tester) async {
    int asyncCalls = 0;
    int paginatedCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              DropifyFormField<String>(
                source: DropifyFormSource<String>.async(
                  fetch: (String query) async {
                    asyncCalls += 1;
                    return _entries;
                  },
                ),
              ),
              DropifyFormField<String>(
                source: DropifyFormSource<String>.paginated(
                  fetchPage: (int pageKey, String query) async {
                    paginatedCalls += 1;
                    return const DropifyPage<String>(
                      entries: _entries,
                      nextPageKey: null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(DropifyKeys.anchor).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(DropifyKeys.row('apple')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(DropifyKeys.anchor).last);
    await tester.pumpAndSettle();

    expect(asyncCalls, 1);
    expect(paginatedCalls, 1);
  });

  testWidgets('validation error appears in anchor semantics', (tester) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final SemanticsHandle semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: DropifyFormField<String>(
              source: const DropifyFormSource<String>.entries(
                entries: _entries,
              ),
              label: 'Fruit',
              validator: (String? value) {
                return value == null ? 'Pick a fruit' : null;
              },
            ),
          ),
        ),
      ),
    );

    formKey.currentState!.validate();
    await tester.pumpAndSettle();

    final SemanticsNode anchorSemantics = tester.getSemantics(
      find.byKey(DropifyKeys.anchor),
    );

    expect(find.text('Pick a fruit'), findsOneWidget);
    expect(anchorSemantics.label, 'Fruit');
    expect(anchorSemantics.hint, 'Pick a fruit');
    semantics.dispose();
  });
}
