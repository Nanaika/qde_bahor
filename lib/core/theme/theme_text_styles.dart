import 'package:flutter/material.dart';
import 'package:qde_eco_bahor/core/theme/theme_colors.dart';
import 'package:qde_eco_bahor/core/theme/theme_dimensions.dart';

/// Централизованные стили текста для всего приложения
/// Поддерживает светлую и темную темы
class ThemeTextStyles {
  ThemeTextStyles._();

  // Display Styles (Large Headings)
  static TextStyle displayLarge(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeDisplayXL,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.2,
      );

  static TextStyle displayMedium(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeDisplayLarge,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.25,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.2,
      );

  static TextStyle displaySmall(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeDisplay,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.3,
      );

  // Headline Styles
  static TextStyle headlineLarge(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeXXXL,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.3,
      );

  static TextStyle headlineMedium(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeXXL,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.4,
      );

  static TextStyle headlineSmall(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeXL,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.4,
      );

  // Title Styles
  static TextStyle titleLarge(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeXL,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.5,
      );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeL,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.5,
      );

  static TextStyle titleSmall(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeM,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.5,
      );

  // Body Styles
  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeL,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.5,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.5,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeM,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.5,
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeS,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
        color: ThemeColors.getSecondaryTextColorByBrightness(context),
        height: 1.5,
      );

  // Label Styles
  static TextStyle labelLarge(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeM,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.5,
      );

  static TextStyle labelMedium(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeS,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.5,
      );

  static TextStyle labelSmall(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeXS,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: ThemeColors.getSecondaryTextColorByBrightness(context),
        height: 1.5,
      );

  // Custom Styles
  static TextStyle button(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeL,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: ThemeColors.onPrimary,
        height: 1.5,
      );

  static TextStyle buttonSecondary(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeL,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: ThemeColors.primary,
        height: 1.5,
      );

  static TextStyle buttonText(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeL,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: ThemeColors.primary,
        height: 1.5,
      );

  static TextStyle inputLabel(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeM,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.5,
      );

  static TextStyle inputText(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeL,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.5,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.5,
      );

  static TextStyle inputHint(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeM,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
        color: ThemeColors.getColorByBrightness(
          context,
          ThemeColors.textHint,
          ThemeColors.textHintDark,
        ),
        height: 1.5,
      );

  static TextStyle inputError(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeS,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
        color: ThemeColors.error,
        height: 1.5,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeS,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
        color: ThemeColors.getSecondaryTextColorByBrightness(context),
        height: 1.4,
      );

  static TextStyle overline(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeXS,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: ThemeColors.getSecondaryTextColorByBrightness(context),
        height: 1.4,
      );

  // Status Styles
  static TextStyle success(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeM,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        color: ThemeColors.success,
        height: 1.5,
      );

  static TextStyle error(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeM,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        color: ThemeColors.error,
        height: 1.5,
      );

  static TextStyle warning(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeM,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        color: ThemeColors.warning,
        height: 1.5,
      );

  static TextStyle info(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeM,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        color: ThemeColors.info,
        height: 1.5,
      );

  // Link Styles
  static TextStyle link(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeM,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        color: ThemeColors.primary,
        height: 1.5,
        decoration: TextDecoration.underline,
        decorationColor: ThemeColors.primary,
      );

  static TextStyle linkLarge(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeL,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: ThemeColors.primary,
        height: 1.5,
        decoration: TextDecoration.underline,
        decorationColor: ThemeColors.primary,
      );

  // AppBar Styles
  static TextStyle appBarTitle(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeXL,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: ThemeColors.getColorByBrightness(
          context,
          ThemeColors.appBarForeground,
          ThemeColors.appBarForegroundDark,
        ),
        height: 1.5,
      );

  // Card Styles
  static TextStyle cardTitle(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeXL,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.4,
      );

  static TextStyle cardSubtitle(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeM,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
        color: ThemeColors.getSecondaryTextColorByBrightness(context),
        height: 1.5,
      );

  // Chip Styles
  static TextStyle chipLabel(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeS,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: ThemeColors.getTextColorByBrightness(context),
        height: 1.5,
      );

  // Badge Styles
  static TextStyle badgeLabel(BuildContext context) => TextStyle(
        fontSize: ThemeDimensions.fontSizeXS,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: ThemeColors.badgeText,
        height: 1.2,
      );

  // Helper method to create custom text style
  static TextStyle custom({
    required BuildContext context,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return TextStyle(
      fontSize: fontSize ?? ThemeDimensions.fontSizeM,
      fontWeight: fontWeight ?? FontWeight.normal,
      letterSpacing: letterSpacing ?? 0.25,
      color: color ?? ThemeColors.getTextColorByBrightness(context),
      height: height ?? 1.5,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }
}
