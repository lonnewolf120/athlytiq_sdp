import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF3333); // Red
  static const Color primaryForeground = Color(0xFFFFFFFF); // White

  static const Color secondary = Color(
    0xFF1A1A1A,
  ); // Black (used for cards, buttons)
  static const Color secondaryForeground = Color(0xFFFFFFFF); // White

  // Backgrounds
  static const Color background = Color(0xFF121212); // A common dark background
  static const Color cardBackground = Color(0xFF1A1A1A); // Black for cards
  static const Color mutedBackground = Color(
    0xFF2A2A2A,
  ); // Slightly lighter black

  // Foregrounds / Text
  static const Color foreground = Color(
    0xFFE0E0E0,
  ); // Light text (not pure white for better readability)
  static const Color mutedForeground = Color(0xFFA1A1A1); // Gray
  static const Color cardForeground = Color(0xFFFFFFFF); // White

  static const Color error = Colors.blueGrey;

  static const Color accent = Color(0xFFFF3333); // Red, same as primary
  static const Color inputFillColor = Color(
    0xFF2A2A2A,
  ); // Dark background for inputs
  static const Color inputBorderColor = Color(
    0xFF424242,
  ); // Subtle border for inputs
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        surface: AppColors.cardBackground,
        onSurface: AppColors.cardForeground,
        background: AppColors.background,
        onBackground: AppColors.foreground,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      fontFamily: 'Quicksand',
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.foreground,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.foreground,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedForeground,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedForeground,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedForeground,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryForeground),
        titleTextStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryForeground,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillColor,
        hintStyle: TextStyle(
          fontFamily: 'Quicksand',
          color: AppColors.mutedForeground,
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          fontFamily: 'Quicksand',
          color: AppColors.mutedForeground,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: AppColors.inputBorderColor.withOpacity(0.5),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primaryForeground,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.mutedBackground,
        labelStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 12,
          color: AppColors.foreground,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        side: BorderSide.none,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.mutedForeground,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),
        labelStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerColor: AppColors.mutedBackground,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        surface: Colors.white,
        onSurface: Colors.black,
        background: Colors.white,
        onBackground: Colors.black,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      fontFamily: 'Quicksand',
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          
          color: Colors.black,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[200],
        hintStyle: const TextStyle(
          fontFamily: 'Quicksand',
          color: Colors.black54,
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Quicksand',
          color: Colors.black54,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.black26),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primaryForeground,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.mutedBackground,
        labelStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 12,
          color: AppColors.foreground,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        side: BorderSide.none,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.mutedForeground,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),  
        labelStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerColor: AppColors.mutedBackground,
    );
  }
}
