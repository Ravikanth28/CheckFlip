import 'package:flutter/material.dart';

class AppColors {
  // Dark theme colors
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkRed = Color(0xFF2D0A0A);
  static const Color boardDark = Color(0xFF1A1A1A);
  static const Color boardBorder = Color(0xFF3A1A1A);

  // Card colors
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFF2A2A2A);
  static const Color cardShadow = Color(0x40000000);

  // Accent colors
  static const Color redAccent = Color(0xFFDC143C);
  static const Color redHighlight = Color(0xFFFF4444);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color grayText = Color(0xFF888888);

  // Player colors
  static const Color redPlayer = Color(0xFFDC143C);
  static const Color blackPlayer = Color(0xFF000000);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBackground, darkRed],
  );
}
