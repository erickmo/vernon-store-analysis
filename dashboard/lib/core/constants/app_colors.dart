import 'package:flutter/material.dart';

/// Warna-warna utama aplikasi Vernon Store Analytics.
abstract class AppColors {
  // Primary
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF534BAE);
  static const Color primaryDark = Color(0xFF000051);

  // Accent
  static const Color accent = Color(0xFF00BCD4);
  static const Color accentLight = Color(0xFF62EFFF);
  static const Color accentDark = Color(0xFF008BA3);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutrals
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF2F7);
  static const Color onSurface = Color(0xFF1C1C1E);
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  // Alert severity
  static const Color alertHigh = Color(0xFFF44336);
  static const Color alertMedium = Color(0xFFFF9800);
  static const Color alertLow = Color(0xFFFFC107);

  // Chart colors
  static const Color chartBlue = Color(0xFF2196F3);
  static const Color chartGreen = Color(0xFF4CAF50);
  static const Color chartOrange = Color(0xFFFF9800);
  static const Color chartPurple = Color(0xFF9C27B0);
  static const Color chartPink = Color(0xFFE91E63);
  static const Color chartTeal = Color(0xFF009688);

  // Stream status
  static const Color streamActive = Color(0xFF4CAF50);
  static const Color streamInactive = Color(0xFF9E9E9E);
  static const Color streamError = Color(0xFFF44336);
}
