import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Red to Pink Gradient (Matching the design)
  static const Color primaryRed = Color(0xFFD32F2F); // Red 700
  static const Color primaryPink = Color(0xFFE91E63); // Pink 500
  static const Color lightRed = Color(0xFFF44336); // Red 500
  static const Color darkRed = Color(0xFFB71C1C); // Red 900
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [darkRed, primaryRed],
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkRed, primaryRed],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, primaryPink],
  );
  
  // Status Colors (using red-pink theme)
  static const Color successColor = Color(0xFF4CAF50); // Green 500
  static const Color errorColor = Color(0xFFD32F2F); // Red 700
  static const Color warningColor = Color(0xFFFF9800); // Orange 500
  static const Color infoColor = Color(0xFF2196F3); // Blue 500
  
  // Status Colors with Red-Pink Theme
  static const Color availableColor = Color(0xFF4CAF50); // Green for available
  static const Color maintenanceColor = Color(0xFFFF9800); // Orange for maintenance
  static const Color reservedColor = Color(0xFFE91E63); // Pink for reserved
  static const Color closedColor = Color(0xFFB71C1C); // Dark red for closed
  
  // Language Indicator Colors
  static const Color arabicColor = Color(0xFFD32F2F); // Red for Arabic
  static const Color englishColor = Color(0xFFE91E63); // Pink for English
  
  // Rating Colors
  static const Color starColor = Color(0xFFFFC107); // Amber for stars
  static const Color starEmptyColor = Color(0xFFE0E0E0); // Light grey for empty stars
  
  // Neutral Colors
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyMedium = Color(0xFF9E9E9E);
  static const Color greyDark = Color(0xFF424242);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowColorLight = Color(0x0D000000);
}
