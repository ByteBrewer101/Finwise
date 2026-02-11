import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand
  static const Color primary = Color(0xFF2DBE7F);
  static const Color primaryDark = Color(0xFF1E8F60);

  // Backgrounds
  static const Color background = Color(0xFFF5F6F8);
  static const Color card = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF7A7A7A);

  // Status
  static const Color success = Color(0xFF2DBE7F);
  static const Color danger = Color(0xFFE74C3C);

  // Divider
  static const Color divider = Color(0xFFE0E0E0);

  // Chart highlight
  static const Color accentYellow = Color(0xFFFFC107);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF34C759), Color(0xFF1FAF5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
