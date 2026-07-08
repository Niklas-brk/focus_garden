import 'package:flutter/material.dart';
import 'plant.dart';

/// Der feste Pflanzen-Katalog (Basis: Konzept Abschnitt 5, erweitert).
///
/// p01–p04 sind gratis, p05–p10 sind Premium (Freischaltung erst in Phase 3 –
/// hier nur als gesperrte Vorschau vorhanden). p09 (Lavendel) und p10 (Tulpe)
/// sind Zusatzpflanzen über den Konzept-Katalog hinaus, bewusst als Premium.
class PlantCatalog {
  static const List<Plant> all = [
    Plant(
      id: 'p01',
      name: 'Sprössling',
      style: 'Klassische Topfpflanze',
      isPremium: false,
      foliage: Color(0xFF7BC96F),
      bloom: Color(0xFFF2C6D0),
    ),
    Plant(
      id: 'p02',
      name: 'Kaktus',
      style: 'Wüsten-Vibe',
      isPremium: false,
      foliage: Color(0xFF5FA35A),
      bloom: Color(0xFFE8A87C),
    ),
    Plant(
      id: 'p03',
      name: 'Bonsai',
      style: 'Ruhig, ästhetisch',
      isPremium: false,
      foliage: Color(0xFF6FB98F),
      bloom: Color(0xFFEBC17A),
    ),
    Plant(
      id: 'p04',
      name: 'Sonnenblume',
      style: 'Hell, freundlich',
      isPremium: false,
      foliage: Color(0xFF7BC96F),
      bloom: Color(0xFFF4C430),
    ),
    Plant(
      id: 'p05',
      name: 'Monstera Deluxe',
      style: 'Trendig',
      isPremium: true,
      foliage: Color(0xFF3E8E5A),
      bloom: Color(0xFFB8E4A0),
    ),
    Plant(
      id: 'p06',
      name: 'Glücksbambus',
      style: 'Minimalistisch',
      isPremium: true,
      foliage: Color(0xFF88C070),
      bloom: Color(0xFFDCE8B0),
    ),
    Plant(
      id: 'p07',
      name: 'Pixel-Rose',
      style: 'Verspielt',
      isPremium: true,
      foliage: Color(0xFF5FA857),
      bloom: Color(0xFFE86F8C),
    ),
    Plant(
      id: 'p08',
      name: 'Nachtschatten',
      style: 'Dark-Aesthetic',
      isPremium: true,
      foliage: Color(0xFF4A5A6A),
      bloom: Color(0xFF9B7BD4),
    ),
    Plant(
      id: 'p09',
      name: 'Lavendel',
      style: 'Beruhigend, lila',
      isPremium: true,
      foliage: Color(0xFF6E8B6A),
      bloom: Color(0xFF9B7BD4),
    ),
    Plant(
      id: 'p10',
      name: 'Tulpe',
      style: 'Frühlingsfrisch',
      isPremium: true,
      foliage: Color(0xFF5FA35A),
      bloom: Color(0xFFD65B5B),
    ),
  ];

  static List<Plant> get free => all.where((p) => !p.isPremium).toList();
  static List<Plant> get premium => all.where((p) => p.isPremium).toList();

  static Plant byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => all.first);
}
