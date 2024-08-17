// lib/constants/color_constants.dart
import 'package:flutter/material.dart';

class ColorConstants {
  static const Color black = Color.fromARGB(255, 0, 0, 0);
  static const Color white = Color.fromARGB(255, 255, 255, 255);
  static const Color cream = Color.fromARGB(255, 245, 245, 220);
  static const Color lightPink = Color.fromARGB(255, 255, 208, 200);

  // Define a map for category colors
  static final Map<String, Color> categoryColors = {
    'Identity': const Color.fromARGB(255, 254, 67, 35), // Example: Aadhaar
    'Education':
        const Color.fromRGBO(249, 215, 45, 1.0), // Example: Degree Certificate
    'Work': const Color.fromRGBO(0, 0, 0, 1.0), // Example: Offer Letter
    'Finance':
        const Color.fromARGB(255, 128, 128, 0), // Example: Bank Statement
    'Travel': const Color.fromRGBO(249, 243, 209, 1.0), // Example: Visa
  };

  // Define a map for category text colors
  static final Map<String, Color> categoryTextColors = {
    'Identity': Colors.white,
    'Education': Colors.black,
    'Work': Colors.white,
    'Finance': Colors.white,
    'Travel': Colors.black,
  };

  // Get color for a specific category
  static Color getCategoryColor(String category) {
    return categoryColors[category] ??
        white; // Default to white if category not found
  }

  // Get text color for a specific category
  static Color getCategoryTextColor(String category) {
    return categoryTextColors[category] ??
        black; // Default to black if category not found
  }
}
