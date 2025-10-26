import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Pink to Orange Gradient
  static const Color primaryPink = Color(0xFFE91E63); // Pink 500
  static const Color primaryOrange = Color(0xFFFF5722); // Deep Orange 500
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryPink, primaryOrange],
  );
  
  // Status Colors (using pink-orange theme)
  static const Color successColor = Color(0xFF4CAF50); // Green 500
  static const Color errorColor = Color(0xFFF44336); // Red 500
  static const Color warningColor = Color(0xFFFF9800); // Orange 500
  static const Color infoColor = Color(0xFF2196F3); // Blue 500
  
  // Status Colors with Pink-Orange Theme
  static const Color availableColor = Color(0xFF4CAF50); // Green for available
  static const Color maintenanceColor = Color(0xFFFF9800); // Orange for maintenance
  static const Color reservedColor = Color(0xFFE91E63); // Pink for reserved
  static const Color closedColor = Color(0xFFF44336); // Red for closed
  
  // Language Indicator Colors
  static const Color arabicColor = Color(0xFFE91E63); // Pink for Arabic
  static const Color englishColor = Color(0xFFFF5722); // Orange for English
  
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
