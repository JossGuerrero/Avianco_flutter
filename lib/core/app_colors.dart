import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFD32F2F);
  static const primaryLight = Color(0xFFE53935);
  static const dark = Color(0xFF1A1A1A);
  static const darkAlt = Color(0xFF212121);
  static const darkRed = Color(0xFFB71C1C);
  static const deepRed = Color(0xFF8E0000);
  static const greyAccent = Color(0xFF616161);
  static const greyDark = Color(0xFF424242);
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFD32F2F);
  static const background = Color(0xFFF7F7F7);
  static const lightGrey = Color(0xFFF5F6FA);

  static const mainGradient = LinearGradient(
    colors: [primary, dark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const bannerGradient = LinearGradient(
    colors: [darkRed, dark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const promoGradient = LinearGradient(
    colors: [deepRed, dark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
