import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Theme tokens for Dropify widgets.
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
    this.loadingText,
    this.emptyText,
    this.noResultsText,
    this.retryText,
    this.noMoreItemsText,
  });

  /// Creates Material 3 flavored Dropify defaults.
  factory DropifyThemeData.fromMaterial(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return DropifyThemeData(
      anchorDecorationTheme: theme.inputDecorationTheme,
      trailingIcon: Icons.arrow_drop_down,
      clearIcon: Icons.clear,
      anchorValueTextStyle: textTheme.bodyLarge,
      anchorHintTextStyle: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      anchorErrorTextStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.error,
      ),
      anchorPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      panelDecoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kElevationToShadow[3],
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      panelPadding: const EdgeInsets.symmetric(vertical: 4),
      panelMaxHeight: 320,
      panelElevation: 3,
      animationDuration: const Duration(milliseconds: 150),
      animationCurve: Curves.easeOutCubic,
      searchInputDecoration: const InputDecoration(
        isDense: true,
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      searchFieldPadding: const EdgeInsets.all(8),
      searchTextStyle: textTheme.bodyMedium,
      searchIcon: Icons.search,
      searchClearIcon: Icons.clear,
      entryTextStyle: textTheme.bodyMedium,
      entryDisabledTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      entrySelectedDecoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
      ),
      entryHoverDecoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.06),
      ),
      entryFocusDecoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.08),
      ),
      entryPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      entrySelectedIcon: Icons.check,
      entrySpacing: 8,
      footerPadding: const EdgeInsets.all(8),
      loadingText: 'Loading...',
      emptyText: 'No items',
      noResultsText: 'No results',
      retryText: 'Retry',
      noMoreItemsText: 'No more items',
    );
  }

  final InputDecorationThemeData? anchorDecorationTheme;
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
  final String? loadingText;
  final String? emptyText;
  final String? noResultsText;
  final String? retryText;
  final String? noMoreItemsText;

  @override
  DropifyThemeData copyWith({
    InputDecorationThemeData? anchorDecorationTheme,
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
    String? loadingText,
    String? emptyText,
    String? noResultsText,
    String? retryText,
    String? noMoreItemsText,
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
      loadingText: loadingText ?? this.loadingText,
      emptyText: emptyText ?? this.emptyText,
      noResultsText: noResultsText ?? this.noResultsText,
      retryText: retryText ?? this.retryText,
      noMoreItemsText: noMoreItemsText ?? this.noMoreItemsText,
    );
  }

  @override
  DropifyThemeData lerp(ThemeExtension<DropifyThemeData>? other, double t) {
    if (other is! DropifyThemeData) {
      return this;
    }
    return DropifyThemeData(
      anchorDecorationTheme: t < 0.5
          ? anchorDecorationTheme
          : other.anchorDecorationTheme,
      trailingIcon: t < 0.5 ? trailingIcon : other.trailingIcon,
      clearIcon: t < 0.5 ? clearIcon : other.clearIcon,
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
      panelMaxHeight: lerpDouble(panelMaxHeight, other.panelMaxHeight, t),
      panelElevation: lerpDouble(panelElevation, other.panelElevation, t),
      animationDuration: t < 0.5 ? animationDuration : other.animationDuration,
      animationCurve: t < 0.5 ? animationCurve : other.animationCurve,
      searchInputDecoration: t < 0.5
          ? searchInputDecoration
          : other.searchInputDecoration,
      searchFieldPadding: EdgeInsetsGeometry.lerp(
        searchFieldPadding,
        other.searchFieldPadding,
        t,
      ),
      searchTextStyle: TextStyle.lerp(
        searchTextStyle,
        other.searchTextStyle,
        t,
      ),
      searchIcon: t < 0.5 ? searchIcon : other.searchIcon,
      searchClearIcon: t < 0.5 ? searchClearIcon : other.searchClearIcon,
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
      entryHoverDecoration: BoxDecoration.lerp(
        entryHoverDecoration,
        other.entryHoverDecoration,
        t,
      ),
      entryFocusDecoration: BoxDecoration.lerp(
        entryFocusDecoration,
        other.entryFocusDecoration,
        t,
      ),
      entryPadding: EdgeInsetsGeometry.lerp(
        entryPadding,
        other.entryPadding,
        t,
      ),
      entrySelectedIcon: t < 0.5 ? entrySelectedIcon : other.entrySelectedIcon,
      entrySpacing: lerpDouble(entrySpacing, other.entrySpacing, t),
      entryDivider: t < 0.5 ? entryDivider : other.entryDivider,
      loadingBuilder: t < 0.5 ? loadingBuilder : other.loadingBuilder,
      errorBuilder: t < 0.5 ? errorBuilder : other.errorBuilder,
      emptyBuilder: t < 0.5 ? emptyBuilder : other.emptyBuilder,
      noResultsBuilder: t < 0.5 ? noResultsBuilder : other.noResultsBuilder,
      firstPageProgressBuilder: t < 0.5
          ? firstPageProgressBuilder
          : other.firstPageProgressBuilder,
      newPageProgressBuilder: t < 0.5
          ? newPageProgressBuilder
          : other.newPageProgressBuilder,
      firstPageErrorBuilder: t < 0.5
          ? firstPageErrorBuilder
          : other.firstPageErrorBuilder,
      newPageErrorBuilder: t < 0.5
          ? newPageErrorBuilder
          : other.newPageErrorBuilder,
      noMoreItemsBuilder: t < 0.5
          ? noMoreItemsBuilder
          : other.noMoreItemsBuilder,
      confirmButtonStyle: t < 0.5
          ? confirmButtonStyle
          : other.confirmButtonStyle,
      cancelButtonStyle: t < 0.5 ? cancelButtonStyle : other.cancelButtonStyle,
      footerPadding: EdgeInsetsGeometry.lerp(
        footerPadding,
        other.footerPadding,
        t,
      ),
      loadingText: t < 0.5 ? loadingText : other.loadingText,
      emptyText: t < 0.5 ? emptyText : other.emptyText,
      noResultsText: t < 0.5 ? noResultsText : other.noResultsText,
      retryText: t < 0.5 ? retryText : other.retryText,
      noMoreItemsText: t < 0.5 ? noMoreItemsText : other.noMoreItemsText,
    );
  }
}
