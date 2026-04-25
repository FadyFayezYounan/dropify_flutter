import 'package:flutter/material.dart';

/// Visual defaults shared by Dropify widgets.
@immutable
class DropifyThemeData {
  /// Creates Dropify theme data.
  const DropifyThemeData({
    this.anchorColor,
    this.panelColor,
    this.textStyle,
    this.padding = const EdgeInsets.all(8),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  /// Default anchor fill color.
  final Color? anchorColor;

  /// Default panel fill color.
  final Color? panelColor;

  /// Default text style.
  final TextStyle? textStyle;

  /// Default interior spacing.
  final EdgeInsetsGeometry? padding;

  /// Default rounded corners.
  final BorderRadius? borderRadius;

  /// Light defaults that do not require a Material ancestor.
  factory DropifyThemeData.light() {
    return const DropifyThemeData(
      anchorColor: Color(0xffffffff),
      panelColor: Color(0xffffffff),
      textStyle: TextStyle(color: Color(0xff111827)),
    );
  }

  /// Dark defaults that do not require a Material ancestor.
  factory DropifyThemeData.dark() {
    return const DropifyThemeData(
      anchorColor: Color(0xff111827),
      panelColor: Color(0xff1f2937),
      textStyle: TextStyle(color: Color(0xfff9fafb)),
    );
  }

  /// Creates defaults from the nearest Material [Theme].
  factory DropifyThemeData.fromMaterial(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DropifyThemeData(
      anchorColor: theme.colorScheme.surface,
      panelColor: theme.colorScheme.surface,
      textStyle: theme.textTheme.bodyMedium,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );
  }

  /// Returns a copy with changed fields.
  DropifyThemeData copyWith({
    Color? anchorColor,
    Color? panelColor,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return DropifyThemeData(
      anchorColor: anchorColor ?? this.anchorColor,
      panelColor: panelColor ?? this.panelColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
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
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DropifyThemeData &&
            other.anchorColor == anchorColor &&
            other.panelColor == panelColor &&
            other.textStyle == textStyle &&
            other.padding == padding &&
            other.borderRadius == borderRadius;
  }

  @override
  int get hashCode {
    return Object.hash(
      anchorColor,
      panelColor,
      textStyle,
      padding,
      borderRadius,
    );
  }
}
