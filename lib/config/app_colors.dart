import 'package:flutter/material.dart';

/// Paleta global Avianco: rojo + negro.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryLight = Color(0xFFE53935);
  static const Color dark = Color(0xFF1A1A1A);
  static const Color darkAlt = Color(0xFF212121);
  static const Color darkRed = Color(0xFFB71C1C);
  static const Color deepRed = Color(0xFF8E0000);
  static const Color greyAccent = Color(0xFF616161);
  static const Color greyDark = Color(0xFF424242);
  static const Color success = Color(0xFF2E7D32);
  static const Color background = Color(0xFFF7F7F7);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [primary, dark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bannerGradient = LinearGradient(
    colors: [darkRed, dark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient promoGradient = LinearGradient(
    colors: [deepRed, dark],
  );
}
