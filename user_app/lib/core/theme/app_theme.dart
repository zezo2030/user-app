import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryRed,
        brightness: Brightness.light,
        primary: AppColors.primaryRed,
        secondary: AppColors.primaryRed,
        surface: AppColors.surfaceColor,
        background: AppColors.backgroundColor,
        error: AppColors.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surfaceColor,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          side: const BorderSide(
            color: AppColors.primaryRed,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.greyMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.greyMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: AppColors.surfaceColor,
      ),
      
      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 2,
        shadowColor: AppColors.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: AppColors.surfaceColor,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceColor,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.greyMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryRed,
        linearTrackColor: AppColors.greyLight,
        circularTrackColor: AppColors.greyLight,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.greyLight,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryRed,
        brightness: Brightness.dark,
        primary: AppColors.primaryRed,
        secondary: AppColors.primaryPink,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        error: AppColors.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          side: const BorderSide(
            color: AppColors.primaryRed,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.greyMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.greyMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
      ),
      
      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 2,
        shadowColor: AppColors.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: Color(0xFF1E1E1E),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.greyMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryRed,
        linearTrackColor: AppColors.greyDark,
        circularTrackColor: AppColors.greyDark,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.greyDark,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
