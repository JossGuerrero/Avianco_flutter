import 'package:flutter/material.dart';

/// Paleta global Avianco: rojo + negro.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryLight = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color dark = Color(0xFF121212);
  static const Color darkAlt = Color(0xFF1E1E1E);
  static const Color darkRed = Color(0xFF8E0000);
  static const Color deepRed = Color(0xFFB71C1C);
  static const Color greyAccent = Color(0xFF757575);
  static const Color greyDark = Color(0xFF424242);
  static const Color success = Color(0xFF2E7D32);
  static const Color background = Color(0xFFF4F5F8);
  static const Color surface = Color(0xFFFFFFFF);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bannerGradient = LinearGradient(
    colors: [darkRed, darkAlt],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient promoGradient = LinearGradient(
    colors: [primaryLight, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFF5F5F), primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
