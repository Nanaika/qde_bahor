import 'package:flutter/material.dart';

/// Централизованные цвета для всего приложения
/// Поддерживает светлую и темную темы
class ThemeColors {
  ThemeColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2196F3); // Blue
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryContainer = Color(0xFFE3F2FD);
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Color(0xFF0D47A1);

  // Secondary Colors
  static const Color secondary = Color(0xFF03DAC6); // Teal
  static const Color secondaryLight = Color(0xFF66FFF9);
  static const Color secondaryDark = Color(0xFF00A896);
  static const Color secondaryContainer = Color(0xFFE0F7FA);
  static const Color onSecondary = Colors.black;
  static const Color onSecondaryContainer = Color(0xFF004D40);

  // Error Colors
  static const Color error = Color(0xFFB00020);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color onError = Colors.white;
  static const Color onErrorContainer = Color(0xFFB71C1C);

  // Success Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color onSuccess = Colors.white;
  static const Color onSuccessContainer = Color(0xFF1B5E20);

  // Warning Colors
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarning = Colors.black;
  static const Color onWarningContainer = Color(0xFFE65100);

  // Info Colors
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);
  static const Color infoContainer = Color(0xFFE3F2FD);
  static const Color onInfo = Colors.white;
  static const Color onInfoContainer = Color(0xFF0D47A1);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);
  static const Color onBackground = Color(0xFF1C1B1F);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);

  // Outline Colors
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  static const Color outlineDark = Color(0xFF938F99);
  static const Color outlineVariantDark = Color(0xFF49454F);

  // Shadow Colors
  static const Color shadow = Color(0xFF000000);
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Divider Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF3A3A3A);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textDisabledDark = Color(0xFF616161);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textHintDark = Color(0xFF757575);

  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);
  static const Color cardElevation = Color(0x0A000000);

  // AppBar Colors
  static const Color appBarBackground = Color(0xFFFFFFFF);
  static const Color appBarBackgroundDark = Color(0xFF1E1E1E);
  static const Color appBarForeground = Color(0xFF212121);
  static const Color appBarForegroundDark = Color(0xFFE0E0E0);

  // Button Colors
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  static const Color buttonDisabledDark = Color(0xFF424242);
  static const Color buttonDisabledText = Color(0xFF9E9E9E);
  static const Color buttonDisabledTextDark = Color(0xFF757575);

  // Input Field Colors
  static const Color inputBorder = Color(0xFFBDBDBD);
  static const Color inputBorderDark = Color(0xFF616161);
  static const Color inputBorderFocused = Color(0xFF2196F3);
  static const Color inputBorderFocusedDark = Color(0xFF64B5F6);
  static const Color inputBorderError = Color(0xFFB00020);
  static const Color inputBackground = Color(0xFFFAFAFA);
  static const Color inputBackgroundDark = Color(0xFF2C2C2C);

  // Chip Colors
  static const Color chipBackground = Color(0xFFE0E0E0);
  static const Color chipBackgroundDark = Color(0xFF424242);
  static const Color chipSelected = Color(0xFF2196F3);
  static const Color chipSelectedDark = Color(0xFF64B5F6);

  // Badge Colors
  static const Color badgeBackground = Color(0xFFB00020);
  static const Color badgeBackgroundDark = Color(0xFFEF5350);
  static const Color badgeText = Colors.white;

  // Status Colors
  static const Color statusOnline = Color(0xFF4CAF50);
  static const Color statusOffline = Color(0xFF9E9E9E);
  static const Color statusAway = Color(0xFFFF9800);
  static const Color statusBusy = Color(0xFFB00020);

  // Gradient Colors
  static const List<Color> gradientPrimary = [
    Color(0xFF2196F3),
    Color(0xFF1976D2),
  ];
  static const List<Color> gradientSecondary = [
    Color(0xFF03DAC6),
    Color(0xFF00A896),
  ];
  static const List<Color> gradientSuccess = [
    Color(0xFF4CAF50),
    Color(0xFF388E3C),
  ];
  static const List<Color> gradientError = [
    Color(0xFFEF5350),
    Color(0xFFC62828),
  ];

  // Helper method to get color based on brightness
  static Color getColorByBrightness(
    BuildContext context,
    Color lightColor,
    Color darkColor,
  ) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkColor : lightColor;
  }

  // Helper method to get text color based on brightness
  static Color getTextColorByBrightness(BuildContext context) {
    return getColorByBrightness(
      context,
      textPrimary,
      textPrimaryDark,
    );
  }

  // Helper method to get secondary text color based on brightness
  static Color getSecondaryTextColorByBrightness(BuildContext context) {
    return getColorByBrightness(
      context,
      textSecondary,
      textSecondaryDark,
    );
  }

  // Helper method to get background color based on brightness
  static Color getBackgroundColorByBrightness(BuildContext context) {
    return getColorByBrightness(
      context,
      background,
      backgroundDark,
    );
  }

  // Helper method to get surface color based on brightness
  static Color getSurfaceColorByBrightness(BuildContext context) {
    return getColorByBrightness(
      context,
      surface,
      surfaceDark,
    );
  }
}

