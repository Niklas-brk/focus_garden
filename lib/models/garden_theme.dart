import 'package:flutter/material.dart';

/// Ein Hintergrund-Thema für die „Garten einrichten"-Ansicht.
///
/// `default` nutzt bewusst KEINE eigenen Farben (gradient/tile/on == null),
/// damit der Garten wie bisher im normalen App-Theme (Hell/Dunkel) erscheint.
/// Die übrigen Themen bringen einen festen Verlauf plus dazu passende
/// Kachel-/Textfarben mit, damit sie in Hell und Dunkel gleich aussehen.
@immutable
class GardenTheme {
  final String id;
  final String name;
  final bool isPremium;

  /// Hintergrund-Verlauf (oben → unten). `null` = App-Hintergrund verwenden.
  final List<Color>? gradient;

  /// Kachel-/Kartenfarbe auf diesem Hintergrund. `null` = `scheme.surface`.
  final Color? tileColor;

  /// Textfarbe auf diesem Hintergrund. `null` = `scheme.onSurface`.
  final Color? onColor;

  const GardenTheme({
    required this.id,
    required this.name,
    required this.isPremium,
    this.gradient,
    this.tileColor,
    this.onColor,
  });

  bool get isDefault => gradient == null;
}

/// Fester Katalog der Garten-Themen (2 gratis, 2 Premium; „Standard" gratis).
class GardenThemes {
  static const standard = GardenTheme(
    id: 'default',
    name: 'Standard',
    isPremium: false,
  );

  static const meadow = GardenTheme(
    id: 'meadow',
    name: 'Wiese',
    isPremium: false,
    gradient: [Color(0xFFCFEBBA), Color(0xFF8FCF7F)],
    tileColor: Color(0xE6FFFFFF),
    onColor: Color(0xFF2A2E31),
  );

  static const night = GardenTheme(
    id: 'night',
    name: 'Sternennacht',
    isPremium: false,
    gradient: [Color(0xFF233A66), Color(0xFF0E1526)],
    tileColor: Color(0x1AFFFFFF),
    onColor: Color(0xFFF2F0EB),
  );

  static const sunset = GardenTheme(
    id: 'sunset',
    name: 'Sonnenuntergang',
    isPremium: true,
    gradient: [Color(0xFFF7B267), Color(0xFFC65B7C)],
    tileColor: Color(0x38000000),
    onColor: Color(0xFFFFFFFF),
  );

  static const forest = GardenTheme(
    id: 'forest',
    name: 'Waldlichtung',
    isPremium: true,
    gradient: [Color(0xFF31513C), Color(0xFF14241B)],
    tileColor: Color(0x1AFFFFFF),
    onColor: Color(0xFFF4F1E8),
  );

  static const List<GardenTheme> all = [
    standard,
    meadow,
    night,
    sunset,
    forest,
  ];

  static GardenTheme byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => standard);
}
