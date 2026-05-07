import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Package-specific styling and state-slot defaults for Dropify widgets.
///
/// The themed dropdown widgets resolve these values from the nearest
/// [DropifyTheme], then from `ThemeData.extensions`, then from
/// [DropifyThemeData.fromMaterial]. Null fields allow lower-priority theme
/// layers to provide the effective value.
@immutable
class DropifyThemeData extends ThemeExtension<DropifyThemeData>
    with Diagnosticable {
  /// Creates Dropify theme data.
  ///
  /// All fields are optional so partial themes can be layered with
  /// [DropifyTheme] and [merge].
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
  ///
  /// The returned value provides defaults for anchor, panel, search, entry,
  /// async state, paging footer, and confirmable multi-select footer styling.
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
        retryKey: const ValueKey<String>('dropify.async.retry'),
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
        retryKey: const ValueKey<String>('dropify.paging.retry'),
        onRetry: retry,
      ),
      newPageErrorBuilder: (context, error, retry) => _DropifyErrorMessage(
        key: const ValueKey<String>('dropify.paging.newPageError'),
        message: 'Could not load more',
        retryKey: const ValueKey<String>('dropify.paging.retry'),
        onRetry: retry,
      ),
      noMoreItemsBuilder: (context) => const _DropifyStateMessage(
        key: ValueKey<String>('dropify.paging.noMoreItems'),
        message: 'No more items',
      ),
      footerPadding: const EdgeInsets.all(8),
    );
  }

  /// Decoration applied to the default themed anchor.
  final InputDecorationTheme? anchorDecorationTheme;

  /// Icon shown at the trailing edge of the closed anchor.
  final IconData? trailingIcon;

  /// Icon shown by the clear affordance.
  final IconData? clearIcon;

  /// Text style for selected values in the anchor.
  final TextStyle? anchorValueTextStyle;

  /// Text style for hint text in the anchor.
  final TextStyle? anchorHintTextStyle;

  /// Text style for validation error text in the anchor.
  final TextStyle? anchorErrorTextStyle;

  /// Padding inside the default themed anchor.
  final EdgeInsetsGeometry? anchorPadding;

  /// Decoration applied to the dropdown panel surface.
  final BoxDecoration? panelDecoration;

  /// Padding inside the dropdown panel.
  final EdgeInsetsGeometry? panelPadding;

  /// Maximum height of the dropdown panel.
  final double? panelMaxHeight;

  /// Material elevation for the dropdown panel surface.
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

  /// Duration used by panel animations.
  final Duration? animationDuration;

  /// Curve used by panel animations.
  final Curve? animationCurve;

  /// Decoration for the search text field.
  final InputDecoration? searchInputDecoration;

  /// Padding around the search text field.
  final EdgeInsetsGeometry? searchFieldPadding;

  /// Text style for search input.
  final TextStyle? searchTextStyle;

  /// Icon shown in the search field.
  final IconData? searchIcon;

  /// Icon shown by the search clear affordance.
  final IconData? searchClearIcon;

  /// Text style for enabled entries.
  final TextStyle? entryTextStyle;

  /// Text style for disabled entries.
  final TextStyle? entryDisabledTextStyle;

  /// Decoration applied to selected entries.
  final BoxDecoration? entrySelectedDecoration;

  /// Decoration applied to hovered entries.
  final BoxDecoration? entryHoverDecoration;

  /// Decoration applied to focused entries.
  final BoxDecoration? entryFocusDecoration;

  /// Padding inside each entry row.
  final EdgeInsetsGeometry? entryPadding;

  /// Icon shown for selected entries.
  final IconData? entrySelectedIcon;

  /// Spacing between entry row children.
  final double? entrySpacing;

  /// Optional divider inserted between entries by themed builders.
  final Divider? entryDivider;

  /// Builder for async loading states.
  final WidgetBuilder? loadingBuilder;

  /// Builder for async error states.
  final Widget Function(BuildContext, Object error, VoidCallback retry)?
  errorBuilder;

  /// Builder for async empty states.
  ///
  /// The boolean argument is true when the current query is not empty.
  final Widget Function(BuildContext, bool hasQuery)? emptyBuilder;

  /// Builder for static no-results states.
  final WidgetBuilder? noResultsBuilder;

  /// Builder for paginated first-page loading states.
  final WidgetBuilder? firstPageProgressBuilder;

  /// Builder for paginated next-page loading footers.
  final WidgetBuilder? newPageProgressBuilder;

  /// Builder for paginated first-page error states.
  final Widget Function(BuildContext, Object, VoidCallback)?
  firstPageErrorBuilder;

  /// Builder for paginated next-page error footers.
  final Widget Function(BuildContext, Object, VoidCallback)?
  newPageErrorBuilder;

  /// Builder for paginated no-more-items footers.
  final WidgetBuilder? noMoreItemsBuilder;

  /// Button style for confirmable multi-select apply actions.
  final ButtonStyle? confirmButtonStyle;

  /// Button style for confirmable multi-select cancel actions.
  final ButtonStyle? cancelButtonStyle;

  /// Padding around confirmable multi-select and paging footers.
  final EdgeInsetsGeometry? footerPadding;

  /// Returns a copy of this theme with the given fields replaced.
  ///
  /// Null arguments leave the corresponding field unchanged.
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<InputDecorationTheme?>(
        'anchorDecorationTheme',
        anchorDecorationTheme,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<IconData?>(
        'trailingIcon',
        trailingIcon,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<IconData?>(
        'clearIcon',
        clearIcon,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextStyle?>(
        'anchorValueTextStyle',
        anchorValueTextStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextStyle?>(
        'anchorHintTextStyle',
        anchorHintTextStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextStyle?>(
        'anchorErrorTextStyle',
        anchorErrorTextStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        'anchorPadding',
        anchorPadding,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<BoxDecoration?>(
        'panelDecoration',
        panelDecoration,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        'panelPadding',
        panelPadding,
        defaultValue: null,
      ),
    );
    properties.add(
      DoubleProperty('panelMaxHeight', panelMaxHeight, defaultValue: null),
    );
    properties.add(
      DoubleProperty('panelElevation', panelElevation, defaultValue: null),
    );
    properties.add(ColorProperty('panelColor', panelColor, defaultValue: null));
    properties.add(
      ColorProperty('panelShadowColor', panelShadowColor, defaultValue: null),
    );
    properties.add(
      ColorProperty(
        'panelSurfaceTintColor',
        panelSurfaceTintColor,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<OutlinedBorder?>(
        'panelShape',
        panelShape,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<BorderSide?>(
        'panelSide',
        panelSide,
        defaultValue: null,
      ),
    );
    properties.add(
      EnumProperty<Clip?>(
        'panelClipBehavior',
        panelClipBehavior,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Duration?>(
        'animationDuration',
        animationDuration,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Curve?>(
        'animationCurve',
        animationCurve,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<InputDecoration?>(
        'searchInputDecoration',
        searchInputDecoration,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        'searchFieldPadding',
        searchFieldPadding,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextStyle?>(
        'searchTextStyle',
        searchTextStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<IconData?>(
        'searchIcon',
        searchIcon,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<IconData?>(
        'searchClearIcon',
        searchClearIcon,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextStyle?>(
        'entryTextStyle',
        entryTextStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextStyle?>(
        'entryDisabledTextStyle',
        entryDisabledTextStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<BoxDecoration?>(
        'entrySelectedDecoration',
        entrySelectedDecoration,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<BoxDecoration?>(
        'entryHoverDecoration',
        entryHoverDecoration,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<BoxDecoration?>(
        'entryFocusDecoration',
        entryFocusDecoration,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        'entryPadding',
        entryPadding,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<IconData?>(
        'entrySelectedIcon',
        entrySelectedIcon,
        defaultValue: null,
      ),
    );
    properties.add(
      DoubleProperty('entrySpacing', entrySpacing, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<Divider?>(
        'entryDivider',
        entryDivider,
        defaultValue: null,
      ),
    );
    properties.add(
      ObjectFlagProperty<WidgetBuilder?>.has('loadingBuilder', loadingBuilder),
    );
    properties.add(
      ObjectFlagProperty<
        Widget Function(BuildContext, Object, VoidCallback)?
      >.has('errorBuilder', errorBuilder),
    );
    properties.add(
      ObjectFlagProperty<Widget Function(BuildContext, bool hasQuery)?>.has(
        'emptyBuilder',
        emptyBuilder,
      ),
    );
    properties.add(
      ObjectFlagProperty<WidgetBuilder?>.has(
        'noResultsBuilder',
        noResultsBuilder,
      ),
    );
    properties.add(
      ObjectFlagProperty<WidgetBuilder?>.has(
        'firstPageProgressBuilder',
        firstPageProgressBuilder,
      ),
    );
    properties.add(
      ObjectFlagProperty<WidgetBuilder?>.has(
        'newPageProgressBuilder',
        newPageProgressBuilder,
      ),
    );
    properties.add(
      ObjectFlagProperty<
        Widget Function(BuildContext, Object, VoidCallback)?
      >.has('firstPageErrorBuilder', firstPageErrorBuilder),
    );
    properties.add(
      ObjectFlagProperty<
        Widget Function(BuildContext, Object, VoidCallback)?
      >.has('newPageErrorBuilder', newPageErrorBuilder),
    );
    properties.add(
      ObjectFlagProperty<WidgetBuilder?>.has(
        'noMoreItemsBuilder',
        noMoreItemsBuilder,
      ),
    );
    properties.add(
      DiagnosticsProperty<ButtonStyle?>(
        'confirmButtonStyle',
        confirmButtonStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<ButtonStyle?>(
        'cancelButtonStyle',
        cancelButtonStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        'footerPadding',
        footerPadding,
        defaultValue: null,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DropifyThemeData &&
            other.anchorDecorationTheme == anchorDecorationTheme &&
            other.trailingIcon == trailingIcon &&
            other.clearIcon == clearIcon &&
            other.anchorValueTextStyle == anchorValueTextStyle &&
            other.anchorHintTextStyle == anchorHintTextStyle &&
            other.anchorErrorTextStyle == anchorErrorTextStyle &&
            other.anchorPadding == anchorPadding &&
            other.panelDecoration == panelDecoration &&
            other.panelPadding == panelPadding &&
            other.panelMaxHeight == panelMaxHeight &&
            other.panelElevation == panelElevation &&
            other.panelColor == panelColor &&
            other.panelShadowColor == panelShadowColor &&
            other.panelSurfaceTintColor == panelSurfaceTintColor &&
            other.panelShape == panelShape &&
            other.panelSide == panelSide &&
            other.panelClipBehavior == panelClipBehavior &&
            other.animationDuration == animationDuration &&
            other.animationCurve == animationCurve &&
            other.searchInputDecoration == searchInputDecoration &&
            other.searchFieldPadding == searchFieldPadding &&
            other.searchTextStyle == searchTextStyle &&
            other.searchIcon == searchIcon &&
            other.searchClearIcon == searchClearIcon &&
            other.entryTextStyle == entryTextStyle &&
            other.entryDisabledTextStyle == entryDisabledTextStyle &&
            other.entrySelectedDecoration == entrySelectedDecoration &&
            other.entryHoverDecoration == entryHoverDecoration &&
            other.entryFocusDecoration == entryFocusDecoration &&
            other.entryPadding == entryPadding &&
            other.entrySelectedIcon == entrySelectedIcon &&
            other.entrySpacing == entrySpacing &&
            other.entryDivider == entryDivider &&
            other.loadingBuilder == loadingBuilder &&
            other.errorBuilder == errorBuilder &&
            other.emptyBuilder == emptyBuilder &&
            other.noResultsBuilder == noResultsBuilder &&
            other.firstPageProgressBuilder == firstPageProgressBuilder &&
            other.newPageProgressBuilder == newPageProgressBuilder &&
            other.firstPageErrorBuilder == firstPageErrorBuilder &&
            other.newPageErrorBuilder == newPageErrorBuilder &&
            other.noMoreItemsBuilder == noMoreItemsBuilder &&
            other.confirmButtonStyle == confirmButtonStyle &&
            other.cancelButtonStyle == cancelButtonStyle &&
            other.footerPadding == footerPadding;
  }

  @override
  int get hashCode {
    return Object.hashAll(<Object?>[
      anchorDecorationTheme,
      trailingIcon,
      clearIcon,
      anchorValueTextStyle,
      anchorHintTextStyle,
      anchorErrorTextStyle,
      anchorPadding,
      panelDecoration,
      panelPadding,
      panelMaxHeight,
      panelElevation,
      panelColor,
      panelShadowColor,
      panelSurfaceTintColor,
      panelShape,
      panelSide,
      panelClipBehavior,
      animationDuration,
      animationCurve,
      searchInputDecoration,
      searchFieldPadding,
      searchTextStyle,
      searchIcon,
      searchClearIcon,
      entryTextStyle,
      entryDisabledTextStyle,
      entrySelectedDecoration,
      entryHoverDecoration,
      entryFocusDecoration,
      entryPadding,
      entrySelectedIcon,
      entrySpacing,
      entryDivider,
      loadingBuilder,
      errorBuilder,
      emptyBuilder,
      noResultsBuilder,
      firstPageProgressBuilder,
      newPageProgressBuilder,
      firstPageErrorBuilder,
      newPageErrorBuilder,
      noMoreItemsBuilder,
      confirmButtonStyle,
      cancelButtonStyle,
      footerPadding,
    ]);
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
    required this.retryKey,
    required this.onRetry,
  });

  final String message;
  final Key retryKey;
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
              key: retryKey,
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
