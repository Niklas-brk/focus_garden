import 'package:flutter/material.dart';

import '../models/plant.dart';

/// Zeigt den fertigen Pixel-Art-Sprite einer Pflanze (Konzept Abschnitt 10).
///
/// Die 512×512-PNGs liegen unter `assets/plants/` und heißen einheitlich
/// `<id>_stage1..4.png` bzw. `<id>_wilted.png`. Der Topf sitzt in allen
/// Sprites an derselben Stelle, dadurch bleibt die Pflanze über die Stufen
/// hinweg an einer festen Grundlinie stehen.
class PlantSprite extends StatelessWidget {
  final Plant plant;
  final int stage; // 1..4
  final bool wilted;
  final double size;

  const PlantSprite({
    super.key,
    required this.plant,
    required this.stage,
    this.wilted = false,
    this.size = 160,
  });

  String get _assetPath {
    final suffix = wilted ? 'wilted' : 'stage${stage.clamp(1, 4)}';
    return 'assets/plants/${plant.id}_$suffix.png';
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      // Sauberes Herunterskalieren der großen Sprites auf jede Anzeigegröße.
      filterQuality: FilterQuality.medium,
      // Fällt ein Sprite mal, bleibt nur ein leerer Platz – nie ein Absturz.
      errorBuilder: (_, _, _) => SizedBox(width: size, height: size),
    );
  }
}
