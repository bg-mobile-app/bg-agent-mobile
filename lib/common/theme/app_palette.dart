import 'package:flutter/material.dart';

class AppPalette {
  static const Color brandBlue = Color(0xFFF1F3FF);
  static const Color pageBackground = Color(0xFFF1F3FF);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textStrongBlue = Color(0xFF0B1E6D);
  static const Color borderSoftBlue = Color(0xFFDBEAFE);
  static const Color borderNeutral = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF166534);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFF92400E);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFB91C1C);

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0D2563EB),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x12051B44),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}
