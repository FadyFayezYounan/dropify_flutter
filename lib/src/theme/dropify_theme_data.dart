import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Package styling tokens for Dropify dropdowns.
///
/// All fields are nullable; non-null values overlay parent values when
/// used with [DropifyThemeData] resolution or `copyWith`.
@immutable
class DropifyThemeData with Diagnosticable {
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
  });

  // --- Anchor tokens ---
  final dynamic anchorDecorationTheme;
  final IconData? trailingIcon;
  final IconData? clearIcon;
  final TextStyle? anchorValueTextStyle;
  final TextStyle? anchorHintTextStyle;
  final TextStyle? anchorErrorTextStyle;
  final EdgeInsetsGeometry? anchorPadding;

  // --- Panel tokens ---
  final BoxDecoration? panelDecoration;
  final EdgeInsetsGeometry? panelPadding;
  final double? panelMaxHeight;
  final double? panelElevation;
  final Duration? animationDuration;
  final Curve? animationCurve;

  // --- Search field tokens ---
  final InputDecoration? searchInputDecoration;
  final EdgeInsetsGeometry? searchFieldPadding;
  final TextStyle? searchTextStyle;
  final IconData? searchIcon;
  final IconData? searchClearIcon;

  // --- Entry tokens ---
  final TextStyle? entryTextStyle;
  final TextStyle? entryDisabledTextStyle;
  final BoxDecoration? entrySelectedDecoration;
  final BoxDecoration? entryHoverDecoration;
  final BoxDecoration? entryFocusDecoration;
  final EdgeInsetsGeometry? entryPadding;
  final IconData? entrySelectedIcon;
  final double? entrySpacing;
  final Divider? entryDivider;

  // --- State slots ---
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

  // --- Multi-select footer ---
  final ButtonStyle? confirmButtonStyle;
  final ButtonStyle? cancelButtonStyle;
  final EdgeInsetsGeometry? footerPadding;

  /// Creates default values from the given Material 3 [ThemeData].
  factory DropifyThemeData.fromMaterial(ThemeData theme) {
    return DropifyThemeData(
      anchorDecorationTheme: theme.inputDecorationTheme,
      trailingIcon: Icons.arrow_drop_down,
      clearIcon: Icons.close,
      anchorValueTextStyle: theme.textTheme.bodyLarge,
      anchorHintTextStyle: theme.textTheme.bodyLarge?.copyWith(
        color: theme.hintColor,
      ),
      anchorErrorTextStyle: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.error,
      ),
      panelMaxHeight: 320,
      panelElevation: 8,
      animationDuration: const Duration(milliseconds: 200),
      animationCurve: Curves.easeInOut,
      searchIcon: Icons.search,
      searchClearIcon: Icons.clear,
      entryTextStyle: theme.textTheme.bodyLarge,
      entrySelectedIcon: Icons.check,
      entrySpacing: 0,
      noResultsBuilder: (_) => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No results')),
      ),
      loadingBuilder: (_) => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      noMoreItemsBuilder: (_) => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No more items')),
      ),
    );
  }

  /// Creates a copy with the specified fields replaced.
  DropifyThemeData copyWith({
    dynamic anchorDecorationTheme,
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
    );
  }

  /// Linearly interpolates between two [DropifyThemeData] values.
  static DropifyThemeData lerp(
    DropifyThemeData? a,
    DropifyThemeData? b,
    double t,
  ) {
    if (a == null && b == null) {
      return const DropifyThemeData();
    }
    if (a == null) {
      return b!;
    }
    if (b == null) {
      return a;
    }
    return DropifyThemeData(
      anchorValueTextStyle: TextStyle.lerp(
        a.anchorValueTextStyle,
        b.anchorValueTextStyle,
        t,
      ),
      anchorHintTextStyle: TextStyle.lerp(
        a.anchorHintTextStyle,
        b.anchorHintTextStyle,
        t,
      ),
      anchorErrorTextStyle: TextStyle.lerp(
        a.anchorErrorTextStyle,
        b.anchorErrorTextStyle,
        t,
      ),
      anchorPadding: EdgeInsetsGeometry.lerp(
        a.anchorPadding,
        b.anchorPadding,
        t,
      ),
      panelPadding: EdgeInsetsGeometry.lerp(a.panelPadding, b.panelPadding, t),
      panelMaxHeight: _lerpDouble(a.panelMaxHeight, b.panelMaxHeight, t),
      panelElevation: _lerpDouble(a.panelElevation, b.panelElevation, t),
      entryTextStyle: TextStyle.lerp(a.entryTextStyle, b.entryTextStyle, t),
      entryPadding: EdgeInsetsGeometry.lerp(a.entryPadding, b.entryPadding, t),
      entrySpacing: _lerpDouble(a.entrySpacing, b.entrySpacing, t),
      footerPadding: EdgeInsetsGeometry.lerp(
        a.footerPadding,
        b.footerPadding,
        t,
      ),
    );
  }

  static double? _lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) {
      return null;
    }
    if (a == null) {
      return b! * t;
    }
    if (b == null) {
      return a * (1.0 - t);
    }
    return a + (b - a) * t;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! DropifyThemeData) {
      return false;
    }
    return other.anchorDecorationTheme == anchorDecorationTheme &&
        other.trailingIcon == trailingIcon &&
        other.clearIcon == clearIcon &&
        other.anchorValueTextStyle == anchorValueTextStyle &&
        other.anchorHintTextStyle == anchorHintTextStyle &&
        other.anchorErrorTextStyle == anchorErrorTextStyle &&
        other.anchorPadding == anchorPadding &&
        other.panelMaxHeight == panelMaxHeight &&
        other.panelElevation == panelElevation &&
        other.entryTextStyle == entryTextStyle &&
        other.entryPadding == entryPadding &&
        other.entrySpacing == entrySpacing;
  }

  @override
  int get hashCode => Object.hashAll([
    anchorDecorationTheme,
    trailingIcon,
    clearIcon,
    anchorValueTextStyle,
    anchorHintTextStyle,
    anchorErrorTextStyle,
    anchorPadding,
    panelMaxHeight,
    panelElevation,
    entryTextStyle,
    entryPadding,
    entrySpacing,
  ]);
}
