import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Package-specific styling and state-slot defaults for Dropify widgets.
@immutable
class DropifyThemeData extends ThemeExtension<DropifyThemeData>
    with Diagnosticable {
  /// Creates Dropify theme data.
  const DropifyThemeData({
    this.anchorDecorationTheme,
    this.trailingIcon,
    this.clearIcon,
    this.anchorValueTextStyle,
    this.anchorHintTextStyle,
    this.anchorErrorTextStyle,
    this.anchorPadding,
    this.panelDecoration,
    this.panelPadding,
    this.panelMaxHeight,
    this.panelElevation,
    this.panelColor,
    this.panelShadowColor,
    this.panelSurfaceTintColor,
    this.panelShape,
    this.panelSide,
    this.panelClipBehavior,
    this.animationDuration,
    this.animationCurve,
    this.searchInputDecoration,
    this.searchFieldPadding,
    this.searchTextStyle,
    this.searchIcon,
    this.searchClearIcon,
    this.entryTextStyle,
    this.entryDisabledTextStyle,
    this.entrySelectedDecoration,
    this.entryHoverDecoration,
    this.entryFocusDecoration,
    this.entryPadding,
    this.entrySelectedIcon,
    this.entrySpacing,
    this.entryDivider,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.noResultsBuilder,
    this.firstPageProgressBuilder,
    this.newPageProgressBuilder,
    this.firstPageErrorBuilder,
    this.newPageErrorBuilder,
    this.noMoreItemsBuilder,
    this.confirmButtonStyle,
    this.cancelButtonStyle,
    this.footerPadding,
  });

  /// Creates Material 3-oriented defaults from [theme].
  factory DropifyThemeData.fromMaterial(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return DropifyThemeData(
      anchorDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      trailingIcon: Icons.keyboard_arrow_down,
      clearIcon: Icons.close,
      anchorValueTextStyle: textTheme.bodyLarge,
      anchorHintTextStyle: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      anchorErrorTextStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.error,
      ),
      anchorPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      panelDecoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      panelPadding: const EdgeInsets.symmetric(vertical: 4),
      panelMaxHeight: 320,
      panelElevation: 3,
      panelColor: colorScheme.surface,
      panelShadowColor: colorScheme.shadow,
      panelSurfaceTintColor: colorScheme.surfaceTint,
      panelShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      panelSide: BorderSide(color: colorScheme.outlineVariant),
      panelClipBehavior: Clip.none,
      animationDuration: const Duration(milliseconds: 120),
      animationCurve: Curves.easeOut,
      searchInputDecoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        hintText: 'Search',
      ),
      searchFieldPadding: const EdgeInsets.all(8),
      searchTextStyle: textTheme.bodyMedium,
      searchIcon: Icons.search,
      searchClearIcon: Icons.close,
      entryTextStyle: textTheme.bodyMedium,
      entryDisabledTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      entrySelectedDecoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      entryPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      entrySelectedIcon: Icons.check,
      entrySpacing: 8,
      loadingBuilder: (context) => const _DropifyStateMessage(
        key: ValueKey<String>('dropify.async.loading'),
        message: 'Loading...',
        showProgress: true,
      ),
      emptyBuilder: (context, hasQuery) => _DropifyStateMessage(
        key: const ValueKey<String>('dropify.async.empty'),
        message: hasQuery ? 'No results found' : 'No data available',
      ),
      noResultsBuilder: (context) => const _DropifyStateMessage(
        key: ValueKey<String>('dropify.paging.noItems'),
        message: 'No results found',
      ),
      errorBuilder: (context, error, retry) => _DropifyErrorMessage(
        key: const ValueKey<String>('dropify.async.error'),
        message: 'Something went wrong',
        onRetry: retry,
      ),
      firstPageProgressBuilder: (context) => const _DropifyStateMessage(
        key: ValueKey<String>('dropify.paging.firstPageProgress'),
        message: 'Loading...',
        showProgress: true,
      ),
      newPageProgressBuilder: (context) => const _DropifyStateMessage(
        key: ValueKey<String>('dropify.paging.newPageProgress'),
        message: 'Loading more...',
        showProgress: true,
      ),
      firstPageErrorBuilder: (context, error, retry) => _DropifyErrorMessage(
        key: const ValueKey<String>('dropify.paging.firstPageError'),
        message: 'Could not load results',
        onRetry: retry,
      ),
      newPageErrorBuilder: (context, error, retry) => _DropifyErrorMessage(
        key: const ValueKey<String>('dropify.paging.newPageError'),
        message: 'Could not load more',
        onRetry: retry,
      ),
      noMoreItemsBuilder: (context) => const _DropifyStateMessage(
        key: ValueKey<String>('dropify.paging.noMoreItems'),
        message: 'No more items',
      ),
      footerPadding: const EdgeInsets.all(8),
    );
  }

  final InputDecorationTheme? anchorDecorationTheme;
  final IconData? trailingIcon;
  final IconData? clearIcon;
  final TextStyle? anchorValueTextStyle;
  final TextStyle? anchorHintTextStyle;
  final TextStyle? anchorErrorTextStyle;
  final EdgeInsetsGeometry? anchorPadding;
  final BoxDecoration? panelDecoration;
  final EdgeInsetsGeometry? panelPadding;
  final double? panelMaxHeight;
  final double? panelElevation;

  /// Explicit Material color for the dropdown panel surface.
  final Color? panelColor;

  /// Explicit Material shadow color for the dropdown panel surface.
  final Color? panelShadowColor;

  /// Explicit Material surface tint color for the dropdown panel surface.
  final Color? panelSurfaceTintColor;

  /// Explicit Material shape for the dropdown panel surface.
  final OutlinedBorder? panelShape;

  /// Explicit Material border side applied to [panelShape].
  final BorderSide? panelSide;

  /// Explicit clipping behavior for the dropdown panel surface.
  final Clip? panelClipBehavior;

  final Duration? animationDuration;
  final Curve? animationCurve;
  final InputDecoration? searchInputDecoration;
  final EdgeInsetsGeometry? searchFieldPadding;
  final TextStyle? searchTextStyle;
  final IconData? searchIcon;
  final IconData? searchClearIcon;
  final TextStyle? entryTextStyle;
  final TextStyle? entryDisabledTextStyle;
  final BoxDecoration? entrySelectedDecoration;
  final BoxDecoration? entryHoverDecoration;
  final BoxDecoration? entryFocusDecoration;
  final EdgeInsetsGeometry? entryPadding;
  final IconData? entrySelectedIcon;
  final double? entrySpacing;
  final Divider? entryDivider;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext, Object error, VoidCallback retry)?
  errorBuilder;
  final Widget Function(BuildContext, bool hasQuery)? emptyBuilder;
  final WidgetBuilder? noResultsBuilder;
  final WidgetBuilder? firstPageProgressBuilder;
  final WidgetBuilder? newPageProgressBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)?
  firstPageErrorBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)?
  newPageErrorBuilder;
  final WidgetBuilder? noMoreItemsBuilder;
  final ButtonStyle? confirmButtonStyle;
  final ButtonStyle? cancelButtonStyle;
  final EdgeInsetsGeometry? footerPadding;

  @override
  DropifyThemeData copyWith({
    InputDecorationTheme? anchorDecorationTheme,
    IconData? trailingIcon,
    IconData? clearIcon,
    TextStyle? anchorValueTextStyle,
    TextStyle? anchorHintTextStyle,
    TextStyle? anchorErrorTextStyle,
    EdgeInsetsGeometry? anchorPadding,
    BoxDecoration? panelDecoration,
    EdgeInsetsGeometry? panelPadding,
    double? panelMaxHeight,
    double? panelElevation,
    Color? panelColor,
    Color? panelShadowColor,
    Color? panelSurfaceTintColor,
    OutlinedBorder? panelShape,
    BorderSide? panelSide,
    Clip? panelClipBehavior,
    Duration? animationDuration,
    Curve? animationCurve,
    InputDecoration? searchInputDecoration,
    EdgeInsetsGeometry? searchFieldPadding,
    TextStyle? searchTextStyle,
    IconData? searchIcon,
    IconData? searchClearIcon,
    TextStyle? entryTextStyle,
    TextStyle? entryDisabledTextStyle,
    BoxDecoration? entrySelectedDecoration,
    BoxDecoration? entryHoverDecoration,
    BoxDecoration? entryFocusDecoration,
    EdgeInsetsGeometry? entryPadding,
    IconData? entrySelectedIcon,
    double? entrySpacing,
    Divider? entryDivider,
    WidgetBuilder? loadingBuilder,
    Widget Function(BuildContext, Object, VoidCallback)? errorBuilder,
    Widget Function(BuildContext, bool)? emptyBuilder,
    WidgetBuilder? noResultsBuilder,
    WidgetBuilder? firstPageProgressBuilder,
    WidgetBuilder? newPageProgressBuilder,
    Widget Function(BuildContext, Object, VoidCallback)? firstPageErrorBuilder,
    Widget Function(BuildContext, Object, VoidCallback)? newPageErrorBuilder,
    WidgetBuilder? noMoreItemsBuilder,
    ButtonStyle? confirmButtonStyle,
    ButtonStyle? cancelButtonStyle,
    EdgeInsetsGeometry? footerPadding,
  }) {
    return DropifyThemeData(
      anchorDecorationTheme:
          anchorDecorationTheme ?? this.anchorDecorationTheme,
      trailingIcon: trailingIcon ?? this.trailingIcon,
      clearIcon: clearIcon ?? this.clearIcon,
      anchorValueTextStyle: anchorValueTextStyle ?? this.anchorValueTextStyle,
      anchorHintTextStyle: anchorHintTextStyle ?? this.anchorHintTextStyle,
      anchorErrorTextStyle: anchorErrorTextStyle ?? this.anchorErrorTextStyle,
      anchorPadding: anchorPadding ?? this.anchorPadding,
      panelDecoration: panelDecoration ?? this.panelDecoration,
      panelPadding: panelPadding ?? this.panelPadding,
      panelMaxHeight: panelMaxHeight ?? this.panelMaxHeight,
      panelElevation: panelElevation ?? this.panelElevation,
      panelColor: panelColor ?? this.panelColor,
      panelShadowColor: panelShadowColor ?? this.panelShadowColor,
      panelSurfaceTintColor:
          panelSurfaceTintColor ?? this.panelSurfaceTintColor,
      panelShape: panelShape ?? this.panelShape,
      panelSide: panelSide ?? this.panelSide,
      panelClipBehavior: panelClipBehavior ?? this.panelClipBehavior,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      searchInputDecoration:
          searchInputDecoration ?? this.searchInputDecoration,
      searchFieldPadding: searchFieldPadding ?? this.searchFieldPadding,
      searchTextStyle: searchTextStyle ?? this.searchTextStyle,
      searchIcon: searchIcon ?? this.searchIcon,
      searchClearIcon: searchClearIcon ?? this.searchClearIcon,
      entryTextStyle: entryTextStyle ?? this.entryTextStyle,
      entryDisabledTextStyle:
          entryDisabledTextStyle ?? this.entryDisabledTextStyle,
      entrySelectedDecoration:
          entrySelectedDecoration ?? this.entrySelectedDecoration,
      entryHoverDecoration: entryHoverDecoration ?? this.entryHoverDecoration,
      entryFocusDecoration: entryFocusDecoration ?? this.entryFocusDecoration,
      entryPadding: entryPadding ?? this.entryPadding,
      entrySelectedIcon: entrySelectedIcon ?? this.entrySelectedIcon,
      entrySpacing: entrySpacing ?? this.entrySpacing,
      entryDivider: entryDivider ?? this.entryDivider,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
      noResultsBuilder: noResultsBuilder ?? this.noResultsBuilder,
      firstPageProgressBuilder:
          firstPageProgressBuilder ?? this.firstPageProgressBuilder,
      newPageProgressBuilder:
          newPageProgressBuilder ?? this.newPageProgressBuilder,
      firstPageErrorBuilder:
          firstPageErrorBuilder ?? this.firstPageErrorBuilder,
      newPageErrorBuilder: newPageErrorBuilder ?? this.newPageErrorBuilder,
      noMoreItemsBuilder: noMoreItemsBuilder ?? this.noMoreItemsBuilder,
      confirmButtonStyle: confirmButtonStyle ?? this.confirmButtonStyle,
      cancelButtonStyle: cancelButtonStyle ?? this.cancelButtonStyle,
      footerPadding: footerPadding ?? this.footerPadding,
    );
  }

  /// Overlays non-null fields from [child] over [parent].
  static DropifyThemeData merge(
    DropifyThemeData parent,
    DropifyThemeData? child,
  ) {
    if (child == null) {
      return parent;
    }
    return parent.copyWith(
      anchorDecorationTheme: child.anchorDecorationTheme,
      trailingIcon: child.trailingIcon,
      clearIcon: child.clearIcon,
      anchorValueTextStyle: child.anchorValueTextStyle,
      anchorHintTextStyle: child.anchorHintTextStyle,
      anchorErrorTextStyle: child.anchorErrorTextStyle,
      anchorPadding: child.anchorPadding,
      panelDecoration: child.panelDecoration,
      panelPadding: child.panelPadding,
      panelMaxHeight: child.panelMaxHeight,
      panelElevation: child.panelElevation,
      panelColor: child.panelColor,
      panelShadowColor: child.panelShadowColor,
      panelSurfaceTintColor: child.panelSurfaceTintColor,
      panelShape: child.panelShape,
      panelSide: child.panelSide,
      panelClipBehavior: child.panelClipBehavior,
      animationDuration: child.animationDuration,
      animationCurve: child.animationCurve,
      searchInputDecoration: child.searchInputDecoration,
      searchFieldPadding: child.searchFieldPadding,
      searchTextStyle: child.searchTextStyle,
      searchIcon: child.searchIcon,
      searchClearIcon: child.searchClearIcon,
      entryTextStyle: child.entryTextStyle,
      entryDisabledTextStyle: child.entryDisabledTextStyle,
      entrySelectedDecoration: child.entrySelectedDecoration,
      entryHoverDecoration: child.entryHoverDecoration,
      entryFocusDecoration: child.entryFocusDecoration,
      entryPadding: child.entryPadding,
      entrySelectedIcon: child.entrySelectedIcon,
      entrySpacing: child.entrySpacing,
      entryDivider: child.entryDivider,
      loadingBuilder: child.loadingBuilder,
      errorBuilder: child.errorBuilder,
      emptyBuilder: child.emptyBuilder,
      noResultsBuilder: child.noResultsBuilder,
      firstPageProgressBuilder: child.firstPageProgressBuilder,
      newPageProgressBuilder: child.newPageProgressBuilder,
      firstPageErrorBuilder: child.firstPageErrorBuilder,
      newPageErrorBuilder: child.newPageErrorBuilder,
      noMoreItemsBuilder: child.noMoreItemsBuilder,
      confirmButtonStyle: child.confirmButtonStyle,
      cancelButtonStyle: child.cancelButtonStyle,
      footerPadding: child.footerPadding,
    );
  }

  @override
  DropifyThemeData lerp(ThemeExtension<DropifyThemeData>? other, double t) {
    if (other is! DropifyThemeData) {
      return this;
    }
    return DropifyThemeData(
      anchorValueTextStyle: TextStyle.lerp(
        anchorValueTextStyle,
        other.anchorValueTextStyle,
        t,
      ),
      anchorHintTextStyle: TextStyle.lerp(
        anchorHintTextStyle,
        other.anchorHintTextStyle,
        t,
      ),
      anchorErrorTextStyle: TextStyle.lerp(
        anchorErrorTextStyle,
        other.anchorErrorTextStyle,
        t,
      ),
      anchorPadding: EdgeInsetsGeometry.lerp(
        anchorPadding,
        other.anchorPadding,
        t,
      ),
      panelDecoration: BoxDecoration.lerp(
        panelDecoration,
        other.panelDecoration,
        t,
      ),
      panelPadding: EdgeInsetsGeometry.lerp(
        panelPadding,
        other.panelPadding,
        t,
      ),
      panelMaxHeight: ui.lerpDouble(panelMaxHeight, other.panelMaxHeight, t),
      panelElevation: ui.lerpDouble(panelElevation, other.panelElevation, t),
      panelColor: Color.lerp(panelColor, other.panelColor, t),
      panelShadowColor: Color.lerp(panelShadowColor, other.panelShadowColor, t),
      panelSurfaceTintColor: Color.lerp(
        panelSurfaceTintColor,
        other.panelSurfaceTintColor,
        t,
      ),
      panelShape: _lerpOutlinedBorder(panelShape, other.panelShape, t),
      panelSide: panelSide == null && other.panelSide == null
          ? null
          : BorderSide.lerp(
              panelSide ?? BorderSide.none,
              other.panelSide ?? BorderSide.none,
              t,
            ),
      panelClipBehavior: t < 0.5 ? panelClipBehavior : other.panelClipBehavior,
      searchTextStyle: TextStyle.lerp(
        searchTextStyle,
        other.searchTextStyle,
        t,
      ),
      searchFieldPadding: EdgeInsetsGeometry.lerp(
        searchFieldPadding,
        other.searchFieldPadding,
        t,
      ),
      entryTextStyle: TextStyle.lerp(entryTextStyle, other.entryTextStyle, t),
      entryDisabledTextStyle: TextStyle.lerp(
        entryDisabledTextStyle,
        other.entryDisabledTextStyle,
        t,
      ),
      entrySelectedDecoration: BoxDecoration.lerp(
        entrySelectedDecoration,
        other.entrySelectedDecoration,
        t,
      ),
      entryPadding: EdgeInsetsGeometry.lerp(
        entryPadding,
        other.entryPadding,
        t,
      ),
      entrySpacing: ui.lerpDouble(entrySpacing, other.entrySpacing, t),
    );
  }
}

class _DropifyStateMessage extends StatelessWidget {
  const _DropifyStateMessage({
    super.key,
    required this.message,
    this.showProgress = false,
  });

  final String message;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            if (showProgress)
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            Flexible(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

OutlinedBorder? _lerpOutlinedBorder(
  OutlinedBorder? a,
  OutlinedBorder? b,
  double t,
) {
  final shape = ShapeBorder.lerp(a, b, t);
  return shape is OutlinedBorder ? shape : null;
}

class _DropifyErrorMessage extends StatelessWidget {
  const _DropifyErrorMessage({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(message),
            TextButton(
              key: const ValueKey<String>('dropify.async.retry'),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
