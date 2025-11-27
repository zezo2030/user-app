import 'package:flutter/material.dart';

/// Contains all gradient definitions used in the app
class AppGradients {
  /// Gradient for Map/Branches toggle button
  /// Colors extracted from the reference image with smooth transitions
  static const gradientMapBranches = LinearGradient(
    colors: [
      Color(0xFFFF8A00), // Bright orange
      Color(0xFFFF5E00), // Orange-red
      Color(0xFFE10000), // Deep red
      Color(0xFFB30000), // Dark red
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Additional gradients can be added here as needed
}

