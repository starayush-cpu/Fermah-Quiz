import 'package:flutter/material.dart';

/// Fermah brand colours, shared across the app.
class AppColors {
  static const Color navy = Color(0xFF051624);
  static const Color navy2 = Color(0xFF0A2A3F);
  static const Color teal = Color(0xFF0FA3A3);
  static const Color tealDark = Color(0xFF0B7E7E);
  static const Color purple = Color(0xFF9553BE);
  static const Color purpleDark = Color(0xFF7A3FA3);
  static const Color sky = Color(0xFF4AA8D8);
  static const Color bg = Color(0xFFF0F4F8);
  static const Color ink = Color(0xFF10222F);
  static const Color muted = Color(0xFF465E6B);
  static const Color line = Color(0xFFD8E2E8);
  static const Color good = Color(0xFF1E7D4D);
  static const Color goodBg = Color(0xFFDDF3E5);
  static const Color bad = Color(0xFFB3261E);
  static const Color badBg = Color(0xFFFBE3E1);
  static const Color gold = Color(0xFFB7791F);
  static const Color noteBg = Color(0xFFFFF4D6);
  static const Color noteBorder = Color(0xFFE8C86A);
  static const Color noteText = Color(0xFF6B4E00);
}

class AppButtons {
  static ButtonStyle get primary => ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.navy,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  static ButtonStyle get navy => ElevatedButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  static ButtonStyle get purple => ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  static ButtonStyle get outline => OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navy,
        side: const BorderSide(color: AppColors.line),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      secondary: AppColors.purple,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.ink, fontSize: 15, height: 1.55),
      bodyLarge: TextStyle(color: AppColors.ink, fontSize: 16, height: 1.55),
      titleLarge: TextStyle(
        color: AppColors.ink,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: AppColors.ink,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
