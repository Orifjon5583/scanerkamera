import 'package:flutter/material.dart';

/// Application color palette.
/// All colors used throughout the app are defined here for consistency.
class AppColors {
  AppColors._();

  /// Primary color seed for Material 3 dynamic color scheme
  static const Color primarySeed = Color(0xFF2563EB);

  /// Light theme backgrounds
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);

  /// Dark theme backgrounds
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);

  /// Accent colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  /// Scanner overlay colors
  static const Color scannerOverlay = Color(0x80000000);
  static const Color scannerBorder = Color(0xFF2563EB);
  static const Color scannerCorner = Color(0xFF10B981);

  /// Filter preview colors
  static const Color filterOriginal = Color(0xFF64748B);
  static const Color filterBW = Color(0xFF1E293B);
  static const Color filterMagic = Color(0xFF7C3AED);
  static const Color filterGray = Color(0xFF6B7280);
}
