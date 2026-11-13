import 'package:flutter/material.dart';

/// Нежная пастельная палитра TaskFlow:
/// лаванда (основной), мята, персик, пудровая роза, небесный, сливочный.
class Pastel {
  Pastel._();

  static const lavender = Color(0xFF8E7CC3);
  static const lavenderLight = Color(0xFFEDE7FB);
  static const lavenderDeep = Color(0xFF4A3B7A);

  static const mint = Color(0xFF7DB9A5);
  static const mintLight = Color(0xFFDDF2EA);
  static const mintDeep = Color(0xFF2E6352);

  static const peach = Color(0xFFE9A28F);
  static const peachLight = Color(0xFFFDE6DD);
  static const peachDeep = Color(0xFF8A4A36);

  static const rose = Color(0xFFE08DA2);
  static const roseLight = Color(0xFFFCE3EA);
  static const roseDeep = Color(0xFF94405A);

  static const sky = Color(0xFF7FA7D9);
  static const skyLight = Color(0xFFE3EEFB);
  static const skyDeep = Color(0xFF3E5F8C);

  static const butter = Color(0xFFE3BE68);
  static const butterLight = Color(0xFFFBF1D6);
  static const butterDeep = Color(0xFF85661E);

  static const mauveLight = Color(0xFFEFE8EE);
  static const mauveDeep = Color(0xFF7D6E7B);

  static const background = Color(0xFFF8F5FC);
  static const card = Colors.white;
  static const ink = Color(0xFF3D3550);
  static const inkSoft = Color(0xFF7D7392);
  static const outline = Color(0xFFEAE3F4);

  static const avatarColors = [
    Color(0xFFE6DDFB),
    Color(0xFFDDF2EA),
    Color(0xFFFDE6DD),
    Color(0xFFFCE3EA),
    Color(0xFFE3EEFB),
    Color(0xFFFBF1D6),
  ];

  static const heroGradient = LinearGradient(
    colors: [Color(0xFFE9E1FB), Color(0xFFFBE3EC), Color(0xFFFDEBDF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class ChipColors {
  const ChipColors(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

