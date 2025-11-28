import 'package:flutter/material.dart';

class FlexVaultColors {
  FlexVaultColors._();

  static const Color vanillaCustard = Color(0xFFD4E09B);
  static const Color lightYellow = Color(0xFFF6F4D2);
  static const Color teaGreen = Color(0xFFCBDFBD);
  static const Color tangerineDream = Color(0xFFF19C79);
  static const Color reddishBrown = Color(0xFFA44A3F);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF242424);
  static const Color darkCard = Color(0xFF2E2E2E);

  static const LinearGradient headerGradient = LinearGradient(
    colors: [teaGreen, lightYellow, tangerineDream],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [
      Color(0xFF6C8F6B),
      Color(0xFF3A3A3A),
      Color(0xFFB56E57),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

