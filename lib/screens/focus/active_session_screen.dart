import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../state/session_provider.dart';
import '../../utils/growth.dart';
import '../../widgets/banner_ad_slot.dart';
import '../../widgets/plant_sprite.dart';

/// Vollbild-Timer während einer laufenden Session (Konzept Abschnitt 4).
class ActiveSessionScreen extends StatelessWidget {
  const ActiveSessionScreen({super.key});

  Future<void> _confirmCancel(BuildContext context) async {
    final session = context.read<SessionProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(S.cancelTitle),
        content: const Text(S.cancelBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(S.cancelKeep),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(S.cancelConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true) session.cancelSession();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final scheme = Theme.of(context).colorScheme;
    final stage = session.currentStage;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmCancel(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Growth.stageName(stage),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(260, 260),
                    painter: _RingPainter(
                      progress: session.progress,
                      track: scheme.onSurface.withValues(alpha: 0.12),
                      color: scheme.primary,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: PlantSprite(
                      key: ValueKey(stage),
                      plant: session.selectedPlant,
                      stage: stage,
                      size: 180,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              session.remainingLabel,
              style: TextStyle(
                fontFamily: 'Silkscreen',
                fontSize: 44,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${session.selectedSubject?.name ?? session.selectedPlant.name} ${S.grows}',
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${S.bloomProgressLabel}: ${session.bloomProgressMinutes.round().clamp(0, SessionProvider.bloomTargetMinutes)} / ${SessionProvider.bloomTargetMinutes} ${S.minutesShort}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scheme.primary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: () => _confirmCancel(context),
              icon: const Icon(Icons.close_rounded),
              label: const Text(S.cancel),
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.error,
                side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            // Banner während der Session (nur Gratis-Version): hierhin schaut
            // man beim Fokussieren ohnehin nicht – Premium bleibt werbefrei.
            const BannerAdSlot(),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color track;
  final Color color;

  _RingPainter({
    required this.progress,
    required this.track,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;
    final stroke = 10.0;

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
