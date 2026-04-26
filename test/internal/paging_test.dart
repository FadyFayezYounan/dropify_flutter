import 'package:dropify_flutter/dropify_flutter.dart';
import 'package:dropify_flutter/src/internal/paging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adapter refreshes loads pages and dedupes values', () async {
    final DropifyController<String> controller =
        DropifyController<String>.single();
    final DropifyPagingAdapter<String> adapter = DropifyPagingAdapter<String>(
      controller: controller,
      dataSource: PaginatedDropifyDataSource<String>(
        firstPageKey: 1,
        fetchPage: (int pageKey, String query) async {
          if (pageKey == 1) {
            return const DropifyPage<String>(
              entries: <DropifyEntry<String>>[
                DropifyEntry<String>(value: 'a', label: 'A'),
                DropifyEntry<String>(value: 'b', label: 'B'),
              ],
              nextPageKey: 2,
            );
          }
          return const DropifyPage<String>(
            entries: <DropifyEntry<String>>[
              DropifyEntry<String>(value: 'b', label: 'Duplicate B'),
              DropifyEntry<String>(value: 'c', label: 'C'),
            ],
          );
        },
      ),
    );

    adapter.refresh();
    await pumpEventQueue();

    expect(
      controller.entries.map((DropifyEntry<String> entry) => entry.value),
      ['a', 'b'],
    );
    expect(controller.hasMore, isTrue);

    adapter.loadMore();
    await pumpEventQueue();

    expect(
      controller.entries.map((DropifyEntry<String> entry) => entry.value),
      ['a', 'b', 'c'],
    );
    expect(controller.hasMore, isFalse);

    adapter.dispose();
    controller.dispose();
  });

  test('adapter keeps loaded entries on later-page errors', () async {
    final DropifyController<String> controller =
        DropifyController<String>.single();
    int pageTwoCalls = 0;
    final DropifyPagingAdapter<String> adapter = DropifyPagingAdapter<String>(
      controller: controller,
      dataSource: PaginatedDropifyDataSource<String>(
        firstPageKey: 1,
        fetchPage: (int pageKey, String query) async {
          if (pageKey == 1) {
            return const DropifyPage<String>(
              entries: <DropifyEntry<String>>[
                DropifyEntry<String>(value: 'a', label: 'A'),
              ],
              nextPageKey: 2,
            );
          }
          pageTwoCalls += 1;
          if (pageTwoCalls == 1) {
            throw Exception('page failed');
          }
          return const DropifyPage<String>(
            entries: <DropifyEntry<String>>[
              DropifyEntry<String>(value: 'b', label: 'B'),
            ],
          );
        },
      ),
    );

    adapter.refresh();
    await pumpEventQueue();
    adapter.loadMore();
    await pumpEventQueue();

    expect(controller.status, DropifyStatus.data);
    expect(controller.entries.single.value, 'a');
    expect(controller.pageError, isException);

    adapter.retry();
    await pumpEventQueue();

    expect(controller.pageError, isNull);
    expect(
      controller.entries.map((DropifyEntry<String> entry) => entry.value),
      ['a', 'b'],
    );

    adapter.dispose();
    controller.dispose();
  });
}
