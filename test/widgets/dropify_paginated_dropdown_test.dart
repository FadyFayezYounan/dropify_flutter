import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/dropify_test_app.dart';

void main() {
  testWidgets('opening paginated dropdown defers initial load outside build', (
    tester,
  ) async {
    await tester.pumpWidget(dropifyTestApp(const _PaginatedHarness()));

    await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
    await tester.pump();

    expect(tester.takeException(), isNull);
    await tester.pump();
    expect(find.text('Alpha'), findsOneWidget);
  });
}

class _PaginatedHarness extends StatefulWidget {
  const _PaginatedHarness();

  @override
  State<_PaginatedHarness> createState() => _PaginatedHarnessState();
}

class _PaginatedHarnessState extends State<_PaginatedHarness> {
  DropifyPagingState<int, String> _state = DropifyPagingState<int, String>();

  Future<void> _fetchNextPage() async {
    final current = _state;
    if (current.isLoading || !current.hasNextPage) {
      return;
    }
    setState(() {
      _state = current.copyWith(isLoading: true, error: null);
    });
    await Future<void>.value();
    if (!mounted) {
      return;
    }
    setState(() {
      _state = _state.copyWith(
        isLoading: false,
        hasNextPage: false,
        pages: const [
          <String>['Alpha'],
        ],
        keys: const [0],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropifyPaginatedDropdown<int, String>(
      state: _state,
      fetchNextPage: _fetchNextPage,
      itemLabelBuilder: (item) => item,
      hintText: 'Select item',
      searchable: false,
    );
  }
}
