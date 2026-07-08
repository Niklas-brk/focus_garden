import 'package:flutter/material.dart';

/// Farbpalette laut Konzept Abschnitt 9.
class AppColors {
  // Dark Theme (Standard)
  static const darkBackground = Color(0xFF14181B);
  static const darkSurface = Color(0xFF1E2428);
  static const darkText = Color(0xFFF2F0EB);

  // Light Theme
  static const lightBackground = Color(0xFFF7F4EC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF2A2E31);

  // Gemeinsame Akzente
  static const primaryGreen = Color(0xFF7BC96F); // Primär-Grün
  static const primaryGreenDark = Color(0xFF5FA857); // leicht abgedunkelt (Light)
  static const accent = Color(0xFFE8A87C);
  static const accentDark = Color(0xFFD1905F);
  static const wilted = Color(0xFFC96F6F); // Fehler / Verwelkt

  // Erd-/Topffarben für Platzhalter-Sprites
  static const pot = Color(0xFFB5744B);
  static const potDark = Color(0xFF8A5636);
  static const soil = Color(0xFF5A3D2B);
}
