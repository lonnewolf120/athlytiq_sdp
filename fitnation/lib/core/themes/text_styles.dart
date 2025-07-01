
import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const String fontFamily =
      'YourAppFontFamily';
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static var labelSmall;

  // Headline Medium Styles
  static TextStyle get darkHeadlineMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.darkPrimaryText,
    height: 1.25,
  );

  static TextStyle get lightHeadlineMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.lightPrimaryText,
    height: 1.25,
  );

  // Body Medium Styles
  static TextStyle get darkBodyMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: AppColors.darkSecondaryText,
  );

  static TextStyle get lightBodyMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: AppColors.lightSecondaryText,
  );

  // Dark Theme Text Styles
  static TextStyle get darkHeadlineLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.darkPrimaryText,
    height: 1.3,
  );

  static TextStyle get darkBodyLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.darkSecondaryText,
  );

  static TextStyle get darkLabelSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: AppColors.darkSecondaryText,
  );

  static TextStyle get darkButtonText => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: Colors.white, // Assuming gradient button text is always white
    fontWeight: FontWeight.bold,
  );

  static TextStyle get darkHintText =>
      TextStyle(fontFamily: fontFamily, color: AppColors.darkHintText);

  // Light Theme Text Styles
  static TextStyle get lightHeadlineLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.lightPrimaryText,
    height: 1.3,
  );

  static TextStyle get lightBodyLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.lightSecondaryText,
  );

  static TextStyle get lightLabelSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: AppColors.lightSecondaryText,
  );

  static TextStyle get lightButtonText => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: Colors.white, // Assuming gradient button text is always white
    fontWeight: FontWeight.bold,
  );

  static TextStyle get lightHintText =>
      TextStyle(fontFamily: fontFamily, color: AppColors.lightHintText);
  // Additional TextStyles based on the above themes

  // Headline Small
  static TextStyle get darkHeadlineSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkPrimaryText,
    height: 1.2,
  );

  static TextStyle get lightHeadlineSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.lightPrimaryText,
    height: 1.2,
  );

  // Body Small
  static TextStyle get darkBodySmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: AppColors.darkSecondaryText,
  );

  static TextStyle get lightBodySmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: AppColors.lightSecondaryText,
  );

  // Caption
  static TextStyle get darkCaption => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    color: AppColors.darkHintText,
  );

  static TextStyle get lightCaption => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    color: AppColors.lightHintText,
  );

  // Overline
  static TextStyle get darkOverline => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    color: AppColors.darkHintText,
    letterSpacing: 1.5,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get lightOverline => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    color: AppColors.lightHintText,
    letterSpacing: 1.5,
    fontWeight: FontWeight.w500,
  );

  // Headline Medium (Material default)
  static TextStyle get headlineSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1,
  );
  // Headline Medium (Material default)
  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  // Body Medium (Material default)
  static TextStyle get bodyMedium =>
      const TextStyle(fontFamily: fontFamily, fontSize: 14);
}
