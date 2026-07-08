import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/plant.dart';
import 'plant_sprite.dart';

/// Horizontales Karussell zur Pflanzenauswahl (Konzept Abschnitt 4).
class PlantCarousel extends StatefulWidget {
  final List<Plant> plants;
  final String selectedId;
  final ValueChanged<Plant> onSelected;

  /// Ob Premium freigeschaltet ist. Wenn nicht, werden Premium-Pflanzen
  /// gesperrt dargestellt.
  final bool premiumUnlocked;

  /// Tipp auf eine gesperrte Premium-Pflanze -> Kaufscreen öffnen.
  final VoidCallback onLockedTap;

  const PlantCarousel({
    super.key,
    required this.plants,
    required this.selectedId,
    required this.onSelected,
    required this.premiumUnlocked,
    required this.onLockedTap,
  });

  @override
  State<PlantCarousel> createState() => _PlantCarouselState();
}

class _PlantCarouselState extends State<PlantCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    final start =
        widget.plants.indexWhere((p) => p.id == widget.selectedId);
    _controller = PageController(
      viewportFraction: 0.62,
      initialPage: start < 0 ? 0 : start,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.plants.length,
        onPageChanged: (i) => widget.onSelected(widget.plants[i]),
        itemBuilder: (context, i) {
          final plant = widget.plants[i];
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              var scale = 1.0;
              if (_controller.position.haveDimensions) {
                final page = _controller.page ?? _controller.initialPage.toDouble();
                scale = (1 - (page - i).abs() * 0.22).clamp(0.82, 1.0);
              }
              return Transform.scale(scale: scale, child: child);
            },
            child: _PlantCard(
              plant: plant,
              selected: plant.id == widget.selectedId,
              locked: plant.isPremium && !widget.premiumUnlocked,
              onLockedTap: widget.onLockedTap,
            ),
          );
        },
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Plant plant;
  final bool selected;
  final bool locked;
  final VoidCallback onLockedTap;

  const _PlantCard({
    required this.plant,
    required this.selected,
    required this.locked,
    required this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? scheme.primary : Colors.transparent,
          width: 2.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: locked ? 0.55 : 1.0,
            child: PlantSprite(plant: plant, stage: 4, size: 140),
          ),
          const SizedBox(height: 4),
          Text(
            plant.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          if (locked)
            _LockBadge(scheme: scheme)
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                plant.style,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );

    if (!locked) return card;
    // Gesperrte Karte: Tippen öffnet den Premium-Kaufscreen.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onLockedTap,
      child: card,
    );
  }
}

class _LockBadge extends StatelessWidget {
  final ColorScheme scheme;
  const _LockBadge({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, size: 12, color: scheme.primary),
          const SizedBox(width: 4),
          Text(
            S.premiumLocked,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
