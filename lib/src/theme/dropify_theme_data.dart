import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Visual defaults shared by Dropify widgets.
@immutable
class DropifyThemeData {
  /// Creates Dropify theme data.
  const DropifyThemeData({
    this.anchorColor,
    this.panelColor,
    this.textStyle,
    this.labelTextStyle,
    this.hintTextStyle,
    this.itemTextStyle,
    this.selectedItemTextStyle,
    this.chipTextStyle,
    this.errorTextStyle = const TextStyle(
      color: Color(0xffb91c1c),
      fontSize: 12,
    ),
    this.searchDecoration = const InputDecoration(
      border: OutlineInputBorder(),
      isDense: true,
    ),
    this.anchorDecoration = const BoxDecoration(
      color: Color(0xffffffff),
      border: Border.fromBorderSide(BorderSide(color: Color(0xffd1d5db))),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.panelDecoration = const BoxDecoration(
      color: Color(0xffffffff),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Color(0x26000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.anchorPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),
    this.panelPadding = const EdgeInsets.all(8),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.panelConstraints,
    this.panelMaxHeight = 320,
    this.chevronIcon = Icons.expand_more,
    this.hintText = 'Select an option',
    this.searchHintText = 'Search',
    this.chipBackground = const Color(0xffe0e7ff),
    this.focusedItemColor = const Color(0xffeef2ff),
    this.disabledOpacity = 0.45,
    this.padding = const EdgeInsets.all(8),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.defaultLoadingBuilder,
    this.defaultErrorBuilder,
    this.defaultEmptyBuilder,
  });

  /// Default anchor fill color.
  final Color? anchorColor;

  /// Default panel fill color.
  final Color? panelColor;

  /// Default text style.
  final TextStyle? textStyle;

  /// Default label text style.
  final TextStyle? labelTextStyle;

  /// Default hint text style.
  final TextStyle? hintTextStyle;

  /// Default item text style.
  final TextStyle? itemTextStyle;

  /// Default selected item text style.
  final TextStyle? selectedItemTextStyle;

  /// Default selected chip text style.
  final TextStyle? chipTextStyle;

  /// Default error text style.
  final TextStyle errorTextStyle;

  /// Default search field decoration.
  final InputDecoration searchDecoration;

  /// Default anchor decoration.
  final Decoration anchorDecoration;

  /// Default panel decoration.
  final Decoration panelDecoration;

  /// Default anchor padding.
  final EdgeInsetsGeometry anchorPadding;

  /// Default panel padding.
  final EdgeInsetsGeometry panelPadding;

  /// Default item row padding.
  final EdgeInsetsGeometry itemPadding;

  /// Optional panel constraints.
  final BoxConstraints? panelConstraints;

  /// Default maximum panel height.
  final double panelMaxHeight;

  /// Default trailing chevron icon.
  final IconData chevronIcon;

  /// Default empty-selection hint text.
  final String hintText;

  /// Default search hint text.
  final String searchHintText;

  /// Default chip background color.
  final Color chipBackground;

  /// Default focused item background color.
  final Color focusedItemColor;

  /// Default opacity for disabled controls.
  final double disabledOpacity;

  /// Default interior spacing.
  final EdgeInsetsGeometry? padding;

  /// Default rounded corners.
  final BorderRadius? borderRadius;

  /// Optional loading-state builder for default panels.
  final WidgetBuilder? defaultLoadingBuilder;

  /// Optional error-state builder for default panels.
  final Widget Function(BuildContext, Object, VoidCallback)?
  defaultErrorBuilder;

  /// Optional empty-state builder for default panels.
  final Widget Function(BuildContext, String)? defaultEmptyBuilder;

  /// Light defaults that do not require a Material ancestor.
  factory DropifyThemeData.light() {
    return const DropifyThemeData(
      anchorColor: Color(0xffffffff),
      panelColor: Color(0xffffffff),
      textStyle: TextStyle(color: Color(0xff111827)),
      labelTextStyle: TextStyle(color: Color(0xff374151), fontSize: 12),
      hintTextStyle: TextStyle(color: Color(0xff6b7280)),
      itemTextStyle: TextStyle(color: Color(0xff111827)),
      selectedItemTextStyle: TextStyle(
        color: Color(0xff111827),
        fontWeight: FontWeight.w600,
      ),
      chipTextStyle: TextStyle(color: Color(0xff3730a3)),
    );
  }

  /// Dark defaults that do not require a Material ancestor.
  factory DropifyThemeData.dark() {
    return const DropifyThemeData(
      anchorColor: Color(0xff111827),
      panelColor: Color(0xff1f2937),
      textStyle: TextStyle(color: Color(0xfff9fafb)),
      labelTextStyle: TextStyle(color: Color(0xffd1d5db), fontSize: 12),
      hintTextStyle: TextStyle(color: Color(0xff9ca3af)),
      itemTextStyle: TextStyle(color: Color(0xfff9fafb)),
      selectedItemTextStyle: TextStyle(
        color: Color(0xfff9fafb),
        fontWeight: FontWeight.w600,
      ),
      chipTextStyle: TextStyle(color: Color(0xffc7d2fe)),
      errorTextStyle: TextStyle(color: Color(0xfffca5a5), fontSize: 12),
      anchorDecoration: BoxDecoration(
        color: Color(0xff111827),
        border: Border.fromBorderSide(BorderSide(color: Color(0xff4b5563))),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      panelDecoration: BoxDecoration(
        color: Color(0xff1f2937),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      chipBackground: Color(0xff312e81),
      focusedItemColor: Color(0xff374151),
    );
  }

  /// Creates defaults from the nearest Material [Theme].
  factory DropifyThemeData.fromMaterial(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DropifyThemeData(
      anchorColor: theme.colorScheme.surface,
      panelColor: theme.colorScheme.surface,
      textStyle: theme.textTheme.bodyMedium,
      labelTextStyle: theme.textTheme.labelMedium,
      hintTextStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.hintColor,
      ),
      itemTextStyle: theme.textTheme.bodyMedium,
      selectedItemTextStyle: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      chipTextStyle: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSecondaryContainer,
      ),
      errorTextStyle:
          theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error) ??
          TextStyle(color: theme.colorScheme.error, fontSize: 12),
      searchDecoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      anchorDecoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      panelDecoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: kElevationToShadow[4],
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      chipBackground: theme.colorScheme.secondaryContainer,
      focusedItemColor: theme.colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );
  }

  /// Returns a copy with changed fields.
  DropifyThemeData copyWith({
    Color? anchorColor,
    Color? panelColor,
    TextStyle? textStyle,
    TextStyle? labelTextStyle,
    TextStyle? hintTextStyle,
    TextStyle? itemTextStyle,
    TextStyle? selectedItemTextStyle,
    TextStyle? chipTextStyle,
    TextStyle? errorTextStyle,
    InputDecoration? searchDecoration,
    Decoration? anchorDecoration,
    Decoration? panelDecoration,
    EdgeInsetsGeometry? anchorPadding,
    EdgeInsetsGeometry? panelPadding,
    EdgeInsetsGeometry? itemPadding,
    BoxConstraints? panelConstraints,
    double? panelMaxHeight,
    IconData? chevronIcon,
    String? hintText,
    String? searchHintText,
    Color? chipBackground,
    Color? focusedItemColor,
    double? disabledOpacity,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    WidgetBuilder? defaultLoadingBuilder,
    Widget Function(BuildContext, Object, VoidCallback)? defaultErrorBuilder,
    Widget Function(BuildContext, String)? defaultEmptyBuilder,
  }) {
    return DropifyThemeData(
      anchorColor: anchorColor ?? this.anchorColor,
      panelColor: panelColor ?? this.panelColor,
      textStyle: textStyle ?? this.textStyle,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      selectedItemTextStyle:
          selectedItemTextStyle ?? this.selectedItemTextStyle,
      chipTextStyle: chipTextStyle ?? this.chipTextStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      searchDecoration: searchDecoration ?? this.searchDecoration,
      anchorDecoration: anchorDecoration ?? this.anchorDecoration,
      panelDecoration: panelDecoration ?? this.panelDecoration,
      anchorPadding: anchorPadding ?? this.anchorPadding,
      panelPadding: panelPadding ?? this.panelPadding,
      itemPadding: itemPadding ?? this.itemPadding,
      panelConstraints: panelConstraints ?? this.panelConstraints,
      panelMaxHeight: panelMaxHeight ?? this.panelMaxHeight,
      chevronIcon: chevronIcon ?? this.chevronIcon,
      hintText: hintText ?? this.hintText,
      searchHintText: searchHintText ?? this.searchHintText,
      chipBackground: chipBackground ?? this.chipBackground,
      focusedItemColor: focusedItemColor ?? this.focusedItemColor,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      defaultLoadingBuilder:
          defaultLoadingBuilder ?? this.defaultLoadingBuilder,
      defaultErrorBuilder: defaultErrorBuilder ?? this.defaultErrorBuilder,
      defaultEmptyBuilder: defaultEmptyBuilder ?? this.defaultEmptyBuilder,
    );
  }

  /// Linearly interpolates between two Dropify themes.
  static DropifyThemeData lerp(
    DropifyThemeData a,
    DropifyThemeData b,
    double t,
  ) {
    return DropifyThemeData(
      anchorColor: Color.lerp(a.anchorColor, b.anchorColor, t),
      panelColor: Color.lerp(a.panelColor, b.panelColor, t),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      labelTextStyle: TextStyle.lerp(a.labelTextStyle, b.labelTextStyle, t),
      hintTextStyle: TextStyle.lerp(a.hintTextStyle, b.hintTextStyle, t),
      itemTextStyle: TextStyle.lerp(a.itemTextStyle, b.itemTextStyle, t),
      selectedItemTextStyle: TextStyle.lerp(
        a.selectedItemTextStyle,
        b.selectedItemTextStyle,
        t,
      ),
      chipTextStyle: TextStyle.lerp(a.chipTextStyle, b.chipTextStyle, t),
      errorTextStyle: TextStyle.lerp(a.errorTextStyle, b.errorTextStyle, t)!,
      anchorDecoration: Decoration.lerp(
        a.anchorDecoration,
        b.anchorDecoration,
        t,
      )!,
      panelDecoration: Decoration.lerp(
        a.panelDecoration,
        b.panelDecoration,
        t,
      )!,
      anchorPadding: EdgeInsetsGeometry.lerp(
        a.anchorPadding,
        b.anchorPadding,
        t,
      )!,
      panelPadding: EdgeInsetsGeometry.lerp(a.panelPadding, b.panelPadding, t)!,
      itemPadding: EdgeInsetsGeometry.lerp(a.itemPadding, b.itemPadding, t)!,
      panelConstraints: BoxConstraints.lerp(
        a.panelConstraints,
        b.panelConstraints,
        t,
      ),
      panelMaxHeight: lerpDouble(a.panelMaxHeight, b.panelMaxHeight, t)!,
      chipBackground: Color.lerp(a.chipBackground, b.chipBackground, t)!,
      focusedItemColor: Color.lerp(a.focusedItemColor, b.focusedItemColor, t)!,
      disabledOpacity: lerpDouble(a.disabledOpacity, b.disabledOpacity, t)!,
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      defaultLoadingBuilder: t < 0.5
          ? a.defaultLoadingBuilder
          : b.defaultLoadingBuilder,
      defaultErrorBuilder: t < 0.5
          ? a.defaultErrorBuilder
          : b.defaultErrorBuilder,
      defaultEmptyBuilder: t < 0.5
          ? a.defaultEmptyBuilder
          : b.defaultEmptyBuilder,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DropifyThemeData &&
            other.anchorColor == anchorColor &&
            other.panelColor == panelColor &&
            other.textStyle == textStyle &&
            other.labelTextStyle == labelTextStyle &&
            other.hintTextStyle == hintTextStyle &&
            other.itemTextStyle == itemTextStyle &&
            other.selectedItemTextStyle == selectedItemTextStyle &&
            other.chipTextStyle == chipTextStyle &&
            other.errorTextStyle == errorTextStyle &&
            other.searchDecoration == searchDecoration &&
            other.anchorDecoration == anchorDecoration &&
            other.panelDecoration == panelDecoration &&
            other.anchorPadding == anchorPadding &&
            other.panelPadding == panelPadding &&
            other.itemPadding == itemPadding &&
            other.panelConstraints == panelConstraints &&
            other.panelMaxHeight == panelMaxHeight &&
            other.chevronIcon == chevronIcon &&
            other.hintText == hintText &&
            other.searchHintText == searchHintText &&
            other.chipBackground == chipBackground &&
            other.focusedItemColor == focusedItemColor &&
            other.disabledOpacity == disabledOpacity &&
            other.padding == padding &&
            other.borderRadius == borderRadius &&
            other.defaultLoadingBuilder == defaultLoadingBuilder &&
            other.defaultErrorBuilder == defaultErrorBuilder &&
            other.defaultEmptyBuilder == defaultEmptyBuilder;
  }

  @override
  int get hashCode {
    return Object.hashAll(<Object?>[
      anchorColor,
      panelColor,
      textStyle,
      labelTextStyle,
      hintTextStyle,
      itemTextStyle,
      selectedItemTextStyle,
      chipTextStyle,
      errorTextStyle,
      searchDecoration,
      anchorDecoration,
      panelDecoration,
      anchorPadding,
      panelPadding,
      itemPadding,
      panelConstraints,
      panelMaxHeight,
      chevronIcon,
      hintText,
      searchHintText,
      chipBackground,
      focusedItemColor,
      disabledOpacity,
      padding,
      borderRadius,
      defaultLoadingBuilder,
      defaultErrorBuilder,
      defaultEmptyBuilder,
    ]);
  }
}
