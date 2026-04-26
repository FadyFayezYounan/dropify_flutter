import 'package:flutter/widgets.dart';

import 'dropify_controller.dart';
import 'dropify_entry.dart';

/// Describes the current data state of a Dropify widget.
enum DropifyStatus {
  /// No request has started and no data has been loaded.
  idle,

  /// Data is currently loading.
  loading,

  /// Data is available.
  data,

  /// The current query produced no entries.
  empty,

  /// Loading failed.
  error,
}

/// Immutable state passed to raw Dropify body builders.
class DropifyState<T> {
  /// Creates a Dropify state snapshot.
  const DropifyState({
    required this.controller,
    required this.entries,
    required this.status,
    this.error,
    this.pageError,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.overlayInfo,
  });

  /// The controller backing this state.
  final DropifyController<T> controller;

  /// Entries visible for the current query.
  final List<DropifyEntry<T>> entries;

  /// Current data status.
  final DropifyStatus status;

  /// Current error, when [status] is [DropifyStatus.error].
  final Object? error;

  /// Page-level error for paginated sources after some entries loaded.
  final Object? pageError;

  /// Whether a paginated source is loading another page.
  final bool isLoadingMore;

  /// Whether a paginated source has another page.
  final bool hasMore;

  /// Raw menu overlay information for custom body positioning.
  final RawMenuOverlayInfo? overlayInfo;

  /// Whether [value] is selected.
  bool isSelected(T value) {
    if (controller.isMulti) {
      return controller.multiValues.contains(value);
    }
    return controller.singleValue == value;
  }

  /// Toggles [value] according to the controller mode.
  bool toggle(T value) {
    for (final DropifyEntry<T> entry in entries) {
      if (entry.value == value) {
        return controller.toggleEntry(entry);
      }
    }
    return controller.toggle(value);
  }
}
