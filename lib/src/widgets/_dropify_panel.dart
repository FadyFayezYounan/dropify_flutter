import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/dropify_entry.dart';
import '../core/dropify_state.dart';
import '../theme/dropify_theme_data.dart';
import '_dropify_search_field.dart';
import 'dropify_keys.dart';

class DropifyPanel<T> extends StatefulWidget {
  const DropifyPanel({
    super.key,
    required this.state,
    required this.theme,
    required this.searchEnabled,
    this.searchHint,
    this.panelDecoration,
    this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.newPageProgressBuilder,
    this.newPageErrorBuilder,
    this.noMoreItemsBuilder,
  });

  final DropifyState<T> state;
  final DropifyThemeData theme;
  final bool searchEnabled;
  final String? searchHint;
  final Decoration? panelDecoration;
  final Widget Function(BuildContext, DropifyEntry<T>, bool, VoidCallback?)?
  itemBuilder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)? errorBuilder;
  final Widget Function(BuildContext, String)? emptyBuilder;
  final WidgetBuilder? newPageProgressBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)?
  newPageErrorBuilder;
  final WidgetBuilder? noMoreItemsBuilder;

  @override
  State<DropifyPanel<T>> createState() => _DropifyPanelState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      FlagProperty('searchEnabled', value: searchEnabled, ifFalse: 'no search'),
    );
    properties.add(
      StringProperty('searchHint', searchHint, defaultValue: null),
    );
  }
}

class _DropifyPanelState<T> extends State<DropifyPanel<T>> {
  late int _focusedIndex = _firstEnabledIndex();

  @override
  void didUpdateWidget(DropifyPanel<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusedIndex >= widget.state.entries.length ||
        _focusedIndex == -1 ||
        !widget.state.entries[_focusedIndex].enabled) {
      _focusedIndex = _firstEnabledIndex();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (widget.searchEnabled || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _moveFocus(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveFocus(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      if (_focusedIndex != -1) {
        widget.state.toggle(widget.state.entries[_focusedIndex].value);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _moveFocus(int direction) {
    final List<int> enabledIndexes = <int>[
      for (int index = 0; index < widget.state.entries.length; index += 1)
        if (widget.state.entries[index].enabled) index,
    ];
    if (enabledIndexes.isEmpty) {
      return;
    }
    final int current = enabledIndexes.indexOf(_focusedIndex);
    final int rawNext = current == -1 ? 0 : current + direction;
    final int next = rawNext < 0
        ? enabledIndexes.length - 1
        : rawNext % enabledIndexes.length;
    setState(() {
      _focusedIndex = enabledIndexes[next];
    });
  }

  int _firstEnabledIndex() {
    return widget.state.entries.indexWhere((DropifyEntry<T> entry) {
      return entry.enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double anchorWidth = widget.state.overlayInfo?.anchorRect.width ?? 0;
    final BoxConstraints constraints =
        widget.theme.panelConstraints ??
        BoxConstraints(
          minWidth: anchorWidth,
          maxWidth: anchorWidth == 0 ? double.infinity : anchorWidth,
          maxHeight: widget.theme.panelMaxHeight,
        );
    final double reservedHeight = widget.searchEnabled ? 116 : 24;
    final double listMaxHeight = math.max(
      48,
      widget.theme.panelMaxHeight - reservedHeight,
    );
    final bool usesStateContent =
        widget.state.status == DropifyStatus.loading ||
        widget.state.status == DropifyStatus.error ||
        widget.state.status == DropifyStatus.idle;
    final bool hasFooter = _hasFooter();
    final double listHeight = usesStateContent
        ? math.min(84, listMaxHeight)
        : widget.state.entries.isEmpty
        ? math.min(52, listMaxHeight)
        : math.min(
            widget.state.entries.length * 48 + (hasFooter ? 48 : 0),
            listMaxHeight,
          );
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: ConstrainedBox(
        constraints: constraints,
        child: Material(
          type: MaterialType.transparency,
          child: DecoratedBox(
            key: DropifyKeys.panel,
            decoration: widget.panelDecoration ?? widget.theme.panelDecoration,
            child: Padding(
              padding: widget.theme.panelPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: <Widget>[
                  if (widget.searchEnabled)
                    DropifySearchField<T>(
                      controller: widget.state.controller,
                      theme: widget.theme,
                      hintText: widget.searchHint,
                    ),
                  Focus(
                    autofocus: !widget.searchEnabled,
                    onKeyEvent: _handleKeyEvent,
                    child: SizedBox(
                      height: listHeight,
                      child: switch (widget.state.status) {
                        DropifyStatus.loading => _LoadingState<T>(
                          theme: widget.theme,
                          builder: widget.loadingBuilder,
                        ),
                        DropifyStatus.error => _ErrorState<T>(
                          state: widget.state,
                          theme: widget.theme,
                          builder: widget.errorBuilder,
                        ),
                        DropifyStatus.idle => const SizedBox.shrink(),
                        DropifyStatus.empty => _EmptyState<T>(
                          state: widget.state,
                          theme: widget.theme,
                          builder: widget.emptyBuilder,
                        ),
                        DropifyStatus.data =>
                          NotificationListener<ScrollNotification>(
                            onNotification: _handleScrollNotification,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount:
                                  widget.state.entries.length +
                                  (hasFooter ? 1 : 0),
                              itemBuilder: (BuildContext context, int index) {
                                if (index == widget.state.entries.length) {
                                  return _FooterState<T>(
                                    state: widget.state,
                                    progressBuilder:
                                        widget.newPageProgressBuilder,
                                    errorBuilder: widget.newPageErrorBuilder,
                                    noMoreItemsBuilder:
                                        widget.noMoreItemsBuilder,
                                  );
                                }
                                final DropifyEntry<T> entry =
                                    widget.state.entries[index];
                                final bool selected = widget.state.isSelected(
                                  entry.value,
                                );
                                final VoidCallback? onSelect = entry.enabled
                                    ? () => widget.state.toggle(entry.value)
                                    : null;
                                return widget.itemBuilder?.call(
                                      context,
                                      entry,
                                      selected,
                                      onSelect,
                                    ) ??
                                    _DefaultRow<T>(
                                      entry: entry,
                                      state: widget.state,
                                      selected: selected,
                                      focused: index == _focusedIndex,
                                      onSelect: onSelect,
                                      theme: widget.theme,
                                    );
                              },
                            ),
                          ),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.extentAfter < 80 &&
        widget.state.hasMore &&
        !widget.state.isLoadingMore &&
        widget.state.pageError == null) {
      widget.state.controller.loadMore();
    }
    return false;
  }

  bool _hasFooter() {
    if (widget.state.entries.isEmpty) {
      return false;
    }
    return widget.state.isLoadingMore ||
        widget.state.pageError != null ||
        (!widget.state.hasMore && widget.noMoreItemsBuilder != null);
  }
}

class _FooterState<T> extends StatelessWidget {
  const _FooterState({
    required this.state,
    this.progressBuilder,
    this.errorBuilder,
    this.noMoreItemsBuilder,
  });

  final DropifyState<T> state;
  final WidgetBuilder? progressBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)? errorBuilder;
  final WidgetBuilder? noMoreItemsBuilder;

  @override
  Widget build(BuildContext context) {
    final Object? error = state.pageError;
    if (error != null) {
      return Center(
        child:
            errorBuilder?.call(context, error, state.controller.retry) ??
            TextButton(
              key: DropifyKeys.pageRetryButton,
              onPressed: state.controller.retry,
              child: Text('Retry: $error'),
            ),
      );
    }
    if (state.isLoadingMore) {
      return Center(
        key: DropifyKeys.loadingMoreFooter,
        child:
            progressBuilder?.call(context) ??
            const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
      );
    }
    return Center(
      key: DropifyKeys.noMoreItemsFooter,
      child: noMoreItemsBuilder?.call(context) ?? const SizedBox.shrink(),
    );
  }
}

class _EmptyState<T> extends StatelessWidget {
  const _EmptyState({required this.state, required this.theme, this.builder});

  final DropifyState<T> state;
  final DropifyThemeData theme;
  final Widget Function(BuildContext, String)? builder;

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          builder?.call(context, state.controller.query) ??
          theme.defaultEmptyBuilder?.call(context, state.controller.query) ??
          const Text('No results'),
    );
  }
}

class _LoadingState<T> extends StatelessWidget {
  const _LoadingState({required this.theme, this.builder});

  final DropifyThemeData theme;
  final WidgetBuilder? builder;

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          builder?.call(context) ??
          theme.defaultLoadingBuilder?.call(context) ??
          const SizedBox.square(
            dimension: 32,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
    );
  }
}

class _ErrorState<T> extends StatelessWidget {
  const _ErrorState({required this.state, required this.theme, this.builder});

  final DropifyState<T> state;
  final DropifyThemeData theme;
  final Widget Function(BuildContext, Object, VoidCallback)? builder;

  @override
  Widget build(BuildContext context) {
    final Object error = state.error ?? 'Unknown error';
    return Center(
      child:
          builder?.call(context, error, state.controller.retry) ??
          theme.defaultErrorBuilder?.call(
            context,
            error,
            state.controller.retry,
          ) ??
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('$error', style: theme.errorTextStyle),
              TextButton(
                key: DropifyKeys.retryButton,
                onPressed: state.controller.retry,
                child: const Text('Retry'),
              ),
            ],
          ),
    );
  }
}

class _DefaultRow<T> extends StatelessWidget {
  const _DefaultRow({
    required this.entry,
    required this.state,
    required this.selected,
    required this.focused,
    required this.theme,
    this.onSelect,
  });

  final DropifyEntry<T> entry;
  final DropifyState<T> state;
  final bool selected;
  final bool focused;
  final DropifyThemeData theme;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      enabled: entry.enabled,
      child: Opacity(
        opacity: entry.enabled ? 1 : theme.disabledOpacity,
        child: InkWell(
          key: DropifyKeys.row(entry.value),
          onTap: onSelect,
          child: ColoredBox(
            color: focused ? theme.focusedItemColor : Colors.transparent,
            child: Padding(
              padding: theme.itemPadding,
              child: Row(
                children: <Widget>[
                  if (entry.leadingIcon != null) ...<Widget>[
                    entry.leadingIcon!,
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child:
                        entry.labelWidget ??
                        _HighlightedLabel(
                          label: entry.label,
                          query: state.controller.query,
                          style: selected
                              ? theme.selectedItemTextStyle
                              : theme.itemTextStyle,
                        ),
                  ),
                  if (entry.trailingIcon != null) ...<Widget>[
                    const SizedBox(width: 8),
                    entry.trailingIcon!,
                  ],
                  const SizedBox(width: 8),
                  if (state.controller.isMulti)
                    Icon(
                      selected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                    )
                  else if (selected)
                    const Icon(Icons.check, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HighlightedLabel extends StatelessWidget {
  const _HighlightedLabel({
    required this.label,
    required this.query,
    required this.style,
  });

  final String label;
  final String query;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(label, overflow: TextOverflow.ellipsis, style: style);
    }
    final int index = label.toLowerCase().indexOf(query.toLowerCase());
    if (index == -1) {
      return Text(label, overflow: TextOverflow.ellipsis, style: style);
    }
    final int end = index + query.length;
    return Text.rich(
      TextSpan(
        style: style,
        children: <InlineSpan>[
          TextSpan(text: label.substring(0, index)),
          TextSpan(
            text: label.substring(index, end),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: label.substring(end)),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
