import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/plant.dart';
import 'plant_sprite.dart';

/// Die drei teilbaren Flex-Card-Stile (Konzept Abschnitt 6).
enum FlexCardStyle { dark, cozy, neon }

/// Farb-/Stilvorgaben je Flex-Card-Variante.
@immutable
class FlexCardTheme {
  final List<Color> bg; // Hintergrund-Verlauf (oben -> unten)
  final Color text; // Hauptzahlen/-text
  final Color subtext; // sekundärer Text
  final Color accent; // Marke + Einheit
  final Color streak; // Streak-Akzent
  final Color tile; // Kachel-/Pillen-Fläche
  final Color tileBorder;

  const FlexCardTheme({
    required this.bg,
    required this.text,
    required this.subtext,
    required this.accent,
    required this.streak,
    required this.tile,
    required this.tileBorder,
  });

  static FlexCardTheme of(FlexCardStyle style) {
    switch (style) {
      case FlexCardStyle.dark:
        return const FlexCardTheme(
          bg: [Color(0xFF1B2227), Color(0xFF12171A)],
          text: Color(0xFFF2F0EB),
          subtext: Color(0xFF9BA6AD),
          accent: Color(0xFF7BC96F),
          streak: Color(0xFFE8A87C),
          tile: Color(0xFF232B31),
          tileBorder: Color(0xFF2F3940),
        );
      case FlexCardStyle.cozy:
        return const FlexCardTheme(
          bg: [Color(0xFFFBF6EA), Color(0xFFEFE3CE)],
          text: Color(0xFF3B3225),
          subtext: Color(0xFF9A8A6E),
          accent: Color(0xFF5FA857),
          streak: Color(0xFFD1905F),
          tile: Color(0xFFFFFFFF),
          tileBorder: Color(0xFFE3D6BE),
        );
      case FlexCardStyle.neon:
        return const FlexCardTheme(
          bg: [Color(0xFF15103A), Color(0xFF0A0820)],
          text: Color(0xFFEAF2FF),
          subtext: Color(0xFF8E86C9),
          accent: Color(0xFF5CF2B0),
          streak: Color(0xFFFF5FA8),
          tile: Color(0xFF1E1850),
          tileBorder: Color(0xFF3A2F7A),
        );
    }
  }
}

/// Teilbare Wochen-Karte im Story-Format. Wird mit fester Logik-Größe
/// 360×640 aufgebaut und beim Export per RepaintBoundary auf 1080×1920
/// hochgerechnet (pixelRatio 3).
class FlexCard extends StatelessWidget {
  final int weekMinutes;
  final int weekPlants;
  final int streak;
  final String periodLabel;
  final List<Plant> plants; // letzte gesammelte Pflanzen, neueste zuerst
  final FlexCardStyle style;

  static const double logicalWidth = 360;
  static const double logicalHeight = 640;

  const FlexCard({
    super.key,
    required this.weekMinutes,
    required this.weekPlants,
    required this.streak,
    required this.periodLabel,
    required this.plants,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final t = FlexCardTheme.of(style);
    return Container(
      width: logicalWidth,
      height: logicalHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: t.bg,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kopf: Marke + Zeitraum
            Row(
              children: [
                Text('🌱',
                    style: TextStyle(fontSize: 18, color: t.accent)),
                const SizedBox(width: 8),
                Text(
                  'FOCUS GARDEN',
                  style: TextStyle(
                    fontFamily: 'Silkscreen',
                    fontSize: 12,
                    color: t.accent,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Text(periodLabel,
                    style: TextStyle(fontSize: 12, color: t.subtext)),
              ],
            ),
            const SizedBox(height: 38),
            Text(
              S.flexWeekLabel,
              style: TextStyle(
                fontSize: 12,
                color: t.subtext,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$weekMinutes',
                  style: TextStyle(
                    fontFamily: 'Silkscreen',
                    fontSize: 76,
                    height: 1.0,
                    color: t.text,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'min',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: t.accent,
                    ),
                  ),
                ),
              ],
            ),
            Text(S.flexMinutesLabel,
                style: TextStyle(fontSize: 15, color: t.subtext)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatPill(
                    icon: '🔥',
                    value: '$streak',
                    label: S.flexStreakLabel,
                    valueColor: t.streak,
                    t: t,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatPill(
                    icon: '🌿',
                    value: '$weekPlants',
                    label: S.flexPlantsLabel,
                    valueColor: t.accent,
                    t: t,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              S.flexRecentLabel,
              style: TextStyle(
                fontSize: 12,
                color: t.subtext,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _MiniGarden(plants: plants, t: t),
            const Spacer(),
            Center(
              child: Text(
                S.flexBranding,
                style: TextStyle(fontSize: 12, color: t.subtext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color valueColor;
  final FlexCardTheme t;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.valueColor,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: t.tile,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.tileBorder),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Silkscreen',
                    fontSize: 22,
                    color: valueColor,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: t.subtext),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGarden extends StatelessWidget {
  final List<Plant> plants;
  final FlexCardTheme t;

  const _MiniGarden({required this.plants, required this.t});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(6, (i) {
        final plant = i < plants.length ? plants[i] : null;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: t.tile,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: t.tileBorder),
                ),
                child: plant == null
                    ? null
                    : Center(
                        child: PlantSprite(plant: plant, stage: 4, size: 42),
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
