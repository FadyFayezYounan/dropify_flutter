import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sealed data source switch is exhaustive', () {
    const DropifyDataSource<int> source = StaticDropifyDataSource<int>(
      entries: <DropifyEntry<int>>[],
    );

    final String label = switch (source) {
      StaticDropifyDataSource<int>() => 'static',
      AsyncDropifyDataSource<int>() => 'async',
      PaginatedDropifyDataSource<int>() => 'paginated',
    };

    expect(label, 'static');
  });
}
