import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Централизованные размеры и отступы для всего приложения
/// Использует ScreenUtil для адаптивности
class ThemeDimensions {
  ThemeDimensions._();

  // Padding
  static double get paddingXS => 4.w;
  static double get paddingS => 8.w;
  static double get paddingM => 16.w;
  static double get paddingL => 24.w;
  static double get paddingXL => 32.w;
  static double get paddingXXL => 48.w;

  // Margin
  static double get marginXS => 4.w;
  static double get marginS => 8.w;
  static double get marginM => 16.w;
  static double get marginL => 24.w;
  static double get marginXL => 32.w;
  static double get marginXXL => 48.w;

  // Spacing (вертикальные отступы)
  static double get spacingXS => 4.h;
  static double get spacingS => 8.h;
  static double get spacingM => 16.h;
  static double get spacingL => 24.h;
  static double get spacingXL => 32.h;
  static double get spacingXXL => 48.h;
  static double get spacingXXXL => 64.h;

  // Border Radius
  static double get radiusXS => 4.r;
  static double get radiusS => 8.r;
  static double get radiusM => 12.r;
  static double get radiusL => 16.r;
  static double get radiusXL => 24.r;
  static double get radiusXXL => 32.r;
  static double get radiusRound => 999.r;

  // Icon Sizes
  static double get iconXS => 16.sp;
  static double get iconS => 20.sp;
  static double get iconM => 24.sp;
  static double get iconL => 32.sp;
  static double get iconXL => 48.sp;
  static double get iconXXL => 64.sp;

  // Font Sizes
  static double get fontSizeXS => 10.sp;
  static double get fontSizeS => 12.sp;
  static double get fontSizeM => 14.sp;
  static double get fontSizeL => 16.sp;
  static double get fontSizeXL => 18.sp;
  static double get fontSizeXXL => 20.sp;
  static double get fontSizeXXXL => 24.sp;
  static double get fontSizeDisplay => 32.sp;
  static double get fontSizeDisplayLarge => 48.sp;
  static double get fontSizeDisplayXL => 72.sp;

  // Button Heights
  static double get buttonHeightS => 32.h;
  static double get buttonHeightM => 48.h;
  static double get buttonHeightL => 56.h;
  static double get buttonHeightXL => 64.h;

  // Input Field Heights
  static double get inputHeightS => 40.h;
  static double get inputHeightM => 48.h;
  static double get inputHeightL => 56.h;

  // Card
  static double get cardElevation => 2.0;
  static double get cardPadding => 16.w;
  static double get cardRadius => 12.r;

  // AppBar
  static double get appBarHeight => 56.h;
  static double get appBarElevation => 0.0;

  // Bottom Navigation
  static double get bottomNavHeight => 56.h;

  // Divider
  static double get dividerHeight => 1.h;
  static double get dividerThickness => 1.h;

  // Avatar Sizes
  static double get avatarXS => 24.w;
  static double get avatarS => 32.w;
  static double get avatarM => 48.w;
  static double get avatarL => 64.w;
  static double get avatarXL => 96.w;

  // Floating Action Button
  static double get fabSize => 56.w;
  static double get fabSmallSize => 40.w;

  // Bottom Sheet
  static double get bottomSheetRadius => 16.r;
  static double get bottomSheetHandleWidth => 40.w;
  static double get bottomSheetHandleHeight => 4.h;

  // Dialog
  static double get dialogRadius => 16.r;
  static double get dialogPadding => 24.w;

  // Chip
  static double get chipHeight => 32.h;
  static double get chipPadding => 8.w;
  static double get chipRadius => 16.r;

  // Badge
  static double get badgeSize => 16.w;
  static double get badgePadding => 4.w;
  static double get badgeRadius => 8.r;
}

