import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/plant_catalog.dart';
import '../models/subject.dart';
import '../state/session_provider.dart';
import '../utils/growth.dart';
import 'plant_sprite.dart';

/// Horizontales Karussell zur Fach-Auswahl im Fokus-Tab (Phase 2). Zeigt je
/// Fach seine Pflanze in der aktuellen Wachstumsstufe, den Namen, den Blüh-
/// Fortschritt und – falls vorhanden – die Zahl schon erblühter Pflanzen.
class SubjectCarousel extends StatefulWidget {
  final List<Subject> subjects;
  final String selectedId;
  final ValueChanged<Subject> onSelected;

  const SubjectCarousel({
    super.key,
    required this.subjects,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<SubjectCarousel> createState() => _SubjectCarouselState();
}

class _SubjectCarouselState extends State<SubjectCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    final start = widget.subjects.indexWhere((s) => s.id == widget.selectedId);
    _controller = PageController(
      viewportFraction: 0.64,
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
        itemCount: widget.subjects.length,
        onPageChanged: (i) => widget.onSelected(widget.subjects[i]),
        itemBuilder: (context, i) {
          final subject = widget.subjects[i];
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              var scale = 1.0;
              if (_controller.position.haveDimensions) {
                final page =
                    _controller.page ?? _controller.initialPage.toDouble();
                scale = (1 - (page - i).abs() * 0.22).clamp(0.82, 1.0);
              }
              return Transform.scale(scale: scale, child: child);
            },
            child: _SubjectCard(
              subject: subject,
              selected: subject.id == widget.selectedId,
            ),
          );
        },
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final bool selected;

  const _SubjectCard({required this.subject, required this.selected});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final plant = PlantCatalog.byId(subject.plantId);
    final fraction =
        (subject.bloomProgress / SessionProvider.bloomTargetMinutes)
            .clamp(0.0, 1.0);
    final stage = Growth.stageForProgress(fraction);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
          PlantSprite(plant: plant, stage: stage, size: 130),
          const SizedBox(height: 4),
          Text(
            subject.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          _ProgressBar(fraction: fraction),
          const SizedBox(height: 6),
          Text(
            subject.bloomedCount > 0
                ? '${S.bloomedBadge} ${subject.bloomedCount}'
                : S.bloomProgressLabel,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dünner, abgerundeter Fortschrittsbalken (Blüh-Fortschritt des Fachs).
class _ProgressBar extends StatelessWidget {
  final double fraction;
  const _ProgressBar({required this.fraction});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: 7,
        backgroundColor: scheme.onSurface.withValues(alpha: 0.12),
        valueColor: AlwaysStoppedAnimation(scheme.primary),
      ),
    );
  }
}
