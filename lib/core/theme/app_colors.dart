import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

// ==========================
// Primary Brand (UNCHANGED)
// ==========================
static const Color primary = Color(0xFF2DBE7F);
static const Color primaryDark = Color(0xFF1E8F60);


static const Color primaryLight = Color(0xFF6EE7B7);

  // ==========================
  // Backgrounds (UNCHANGED)
  // ==========================
  static const Color background = Color(0xFFF5F6F8);
  static const Color card = Colors.white;

  // NEW: Surface & Subtle Background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  // ==========================
  // Text (UNCHANGED)
  // ==========================
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF7A7A7A);

  // NEW: Additional text states
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Colors.white;

  // ==========================
  // Status (UNCHANGED)
  // ==========================
  static const Color success = Color(0xFF2DBE7F);
  static const Color danger = Color(0xFFE74C3C);

  // ==========================
  // Divider (UNCHANGED)
  // ==========================
  static const Color divider = Color(0xFFE0E0E0);

  // NEW: Border
  static const Color border = Color(0xFFE2E8F0);

  // ==========================
  // Chart highlight (UNCHANGED)
  // ==========================
  static const Color accentYellow = Color(0xFFFFC107);

  // ==========================
  // Gradients (UNCHANGED)
  // ==========================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF34C759), Color(0xFF1FAF5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
