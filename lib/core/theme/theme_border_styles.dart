import 'package:flutter/material.dart';
import 'package:qde_eco_bahor/core/theme/theme_colors.dart';
import 'package:qde_eco_bahor/core/theme/theme_dimensions.dart';

/// Централизованные стили границ для всего приложения
/// Поддерживает светлую и темную темы
class ThemeBorderStyles {
  ThemeBorderStyles._();

  // Input Borders
  static InputBorder inputBorder(BuildContext context) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeDimensions.radiusS),
        borderSide: BorderSide(
          color: ThemeColors.getColorByBrightness(
            context,
            ThemeColors.inputBorder,
            ThemeColors.inputBorderDark,
          ),
          width: 1.0,
        ),
      );

  static InputBorder inputBorderFocused(BuildContext context) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeDimensions.radiusS),
        borderSide: BorderSide(
          color: ThemeColors.getColorByBrightness(
            context,
            ThemeColors.inputBorderFocused,
            ThemeColors.inputBorderFocusedDark,
          ),
          width: 2.0,
        ),
      );

  static InputBorder inputBorderError(BuildContext context) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeDimensions.radiusS),
        borderSide: BorderSide(
          color: ThemeColors.inputBorderError,
          width: 1.5,
        ),
      );

  static InputBorder inputBorderDisabled(BuildContext context) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeDimensions.radiusS),
        borderSide: BorderSide(
          color: ThemeColors.getColorByBrightness(
            context,
            ThemeColors.inputBorder,
            ThemeColors.inputBorderDark,
          ).withOpacity(0.5),
          width: 1.0,
        ),
      );

  static InputBorder inputBorderNone(BuildContext context) => InputBorder.none;

  // Button Borders
  static BorderRadius buttonBorderRadius(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.radiusS,
      );

  static BorderRadius buttonBorderRadiusSmall(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.radiusXS,
      );

  static BorderRadius buttonBorderRadiusLarge(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.radiusM,
      );

  static BorderRadius buttonBorderRadiusRound(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.radiusRound,
      );

  static BorderSide buttonBorderSide(BuildContext context) => BorderSide(
        color: ThemeColors.primary,
        width: 1.0,
      );

  static BorderSide buttonBorderSideSecondary(BuildContext context) => BorderSide(
        color: ThemeColors.secondary,
        width: 1.0,
      );

  static BorderSide buttonBorderSideError(BuildContext context) => BorderSide(
        color: ThemeColors.error,
        width: 1.0,
      );

  // Card Borders
  static BorderRadius cardBorderRadius(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.cardRadius,
      );

  static BorderRadius cardBorderRadiusSmall(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.radiusS,
      );

  static BorderRadius cardBorderRadiusLarge(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.radiusL,
      );

  static BorderSide cardBorderSide(BuildContext context) => BorderSide(
        color: ThemeColors.getColorByBrightness(
          context,
          ThemeColors.outline,
          ThemeColors.outlineDark,
        ),
        width: 1.0,
      );

  // Container Borders
  static BorderRadius containerBorderRadius(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.radiusM,
      );

  static BorderRadius containerBorderRadiusSmall(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.radiusS,
      );

  static BorderRadius containerBorderRadiusLarge(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.radiusL,
      );

  static Border containerBorder(BuildContext context) => Border.all(
        color: ThemeColors.getColorByBrightness(
          context,
          ThemeColors.outline,
          ThemeColors.outlineDark,
        ),
        width: 1.0,
      );

  static Border containerBorderPrimary(BuildContext context) => Border.all(
        color: ThemeColors.primary,
        width: 1.0,
      );

  static Border containerBorderError(BuildContext context) => Border.all(
        color: ThemeColors.error,
        width: 1.0,
      );

  static Border containerBorderSuccess(BuildContext context) => Border.all(
        color: ThemeColors.success,
        width: 1.0,
      );

  // Chip Borders
  static BorderRadius chipBorderRadius(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.chipRadius,
      );

  static BorderSide chipBorderSide(BuildContext context) => BorderSide(
        color: ThemeColors.getColorByBrightness(
          context,
          ThemeColors.chipBackground,
          ThemeColors.chipBackgroundDark,
        ),
        width: 1.0,
      );

  // Dialog Borders
  static BorderRadius dialogBorderRadius(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.dialogRadius,
      );

  // Bottom Sheet Borders
  static BorderRadius bottomSheetBorderRadius(BuildContext context) => BorderRadius.only(
        topLeft: Radius.circular(ThemeDimensions.bottomSheetRadius),
        topRight: Radius.circular(ThemeDimensions.bottomSheetRadius),
      );

  // AppBar Borders
  static BorderSide appBarBorderSide(BuildContext context) => BorderSide(
        color: ThemeColors.getColorByBrightness(
          context,
          ThemeColors.divider,
          ThemeColors.dividerDark,
        ),
        width: 1.0,
      );

  // Divider Styles
  static DividerThemeData dividerTheme(BuildContext context) => DividerThemeData(
        color: ThemeColors.getColorByBrightness(
          context,
          ThemeColors.divider,
          ThemeColors.dividerDark,
        ),
        thickness: ThemeDimensions.dividerThickness,
        space: ThemeDimensions.spacingM,
      );

  // List Tile Borders
  static BorderRadius listTileBorderRadius(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.radiusS,
      );

  // Avatar Borders
  static BorderRadius avatarBorderRadius(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.radiusRound,
      );

  static BorderSide avatarBorderSide(BuildContext context) => BorderSide(
        color: ThemeColors.getColorByBrightness(
          context,
          ThemeColors.surface,
          ThemeColors.surfaceDark,
        ),
        width: 2.0,
      );

  static BorderSide avatarBorderSidePrimary(BuildContext context) => BorderSide(
        color: ThemeColors.primary,
        width: 2.0,
      );

  // Badge Borders
  static BorderRadius badgeBorderRadius(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.badgeRadius,
      );

  // Floating Action Button Borders
  static BorderRadius fabBorderRadius(BuildContext context) => BorderRadius.circular(
        ThemeDimensions.radiusRound,
      );

  // Search Bar Borders
  static InputBorder searchBarBorder(BuildContext context) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeDimensions.radiusRound),
        borderSide: BorderSide(
          color: ThemeColors.getColorByBrightness(
            context,
            ThemeColors.inputBorder,
            ThemeColors.inputBorderDark,
          ),
          width: 1.0,
        ),
      );

  static InputBorder searchBarBorderFocused(BuildContext context) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeDimensions.radiusRound),
        borderSide: BorderSide(
          color: ThemeColors.primary,
          width: 2.0,
        ),
      );

  // Tab Borders
  static BorderRadius tabBorderRadius(BuildContext context) => BorderRadius.only(
        topLeft: Radius.circular(ThemeDimensions.radiusS),
        topRight: Radius.circular(ThemeDimensions.radiusS),
      );

  // Bottom Navigation Borders
  static BorderSide bottomNavBorderSide(BuildContext context) => BorderSide(
        color: ThemeColors.getColorByBrightness(
          context,
          ThemeColors.divider,
          ThemeColors.dividerDark,
        ),
        width: 1.0,
      );

  // Helper method to create custom border
  static Border customBorder({
    required BuildContext context,
    Color? color,
    double? width,
    BorderRadius? borderRadius,
  }) {
    return Border.all(
      color: color ??
          ThemeColors.getColorByBrightness(
            context,
            ThemeColors.outline,
            ThemeColors.outlineDark,
          ),
      width: width ?? 1.0,
    );
  }

  // Helper method to create custom border radius
  static BorderRadius customBorderRadius(double radius) {
    return BorderRadius.circular(radius);
  }

  // Helper method to create custom input border
  static InputBorder customInputBorder({
    required BuildContext context,
    double? radius,
    Color? color,
    double? width,
    bool isFocused = false,
    bool isError = false,
  }) {
    if (isError) {
      return inputBorderError(context);
    }
    if (isFocused) {
      return inputBorderFocused(context);
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius ?? ThemeDimensions.radiusS),
      borderSide: BorderSide(
        color: color ??
            ThemeColors.getColorByBrightness(
              context,
              ThemeColors.inputBorder,
              ThemeColors.inputBorderDark,
            ),
        width: width ?? 1.0,
      ),
    );
  }
}
