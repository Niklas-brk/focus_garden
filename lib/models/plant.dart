import 'package:flutter/material.dart';

/// Eine Pflanzenart. Sprites sind in Phase 1 programmatische Platzhalter
/// (siehe PlantSprite), die je Pflanze anhand von [foliage]/[bloom] eingefärbt
/// werden. In Phase 2 werden sie durch echte PNGs ersetzt.
@immutable
class Plant {
  final String id; // p01 .. p08
  final String name;
  final String style; // kurze Stil-Beschreibung
  final bool isPremium;
  final Color foliage; // Hauptfarbe des Grüns
  final Color bloom; // Farbe der Blüte (Stufe 4)

  const Plant({
    required this.id,
    required this.name,
    required this.style,
    required this.isPremium,
    required this.foliage,
    required this.bloom,
  });
}
