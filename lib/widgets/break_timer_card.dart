import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/notification_service.dart';
import '../utils/break_advisor.dart';

/// Pausen-Empfehlung nach einer erfolgreichen Session (Ergebnis-Screen).
///
/// Zeigt die empfohlene Pausenlänge (siehe [BreakAdvisor]) und startet auf
/// Wunsch einen Pausen-Timer: Countdown in der Karte + Benachrichtigung zum
/// Pausen-Ende (auch wenn die App zwischendurch verlassen wird – Pausen sind
/// zum Weggehen da, hier verwelkt natürlich nichts).
class BreakTimerCard extends StatefulWidget {
  final BreakAdvice advice;
  final NotificationService notifications;

  const BreakTimerCard({
    super.key,
    required this.advice,
    required this.notifications,
  });

  @override
  State<BreakTimerCard> createState() => _BreakTimerCardState();
}

class _BreakTimerCardState extends State<BreakTimerCard> {
  DateTime? _endsAt;
  Timer? _ticker;
  bool _done = false;

  void _start() {
    final endsAt = DateTime.now().add(Duration(minutes: widget.advice.minutes));
    widget.notifications.scheduleBreakEnd(endsAt);
    setState(() => _endsAt = endsAt);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!DateTime.now().isBefore(_endsAt!)) {
        _ticker?.cancel();
        setState(() => _done = true);
      } else {
        setState(() {}); // Countdown weiterzeichnen
      }
    });
  }

  @override
  void dispose() {
    // Nur den Bildschirm-Ticker stoppen. Die geplante „Pause vorbei"-Meldung
    // bleibt bestehen – die Pause läuft ja weiter, auch ohne offenen Screen.
    _ticker?.cancel();
    super.dispose();
  }

  String get _remainingLabel {
    final total = _endsAt!.difference(DateTime.now()).inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final advice = widget.advice;
    final body = (advice.isLong ? S.breakBodyLong : S.breakBodyShort)
        .replaceFirst('{n}', '${advice.minutes}');

    return Container(
      width: 280,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('☕', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                _done
                    ? S.breakDone
                    : '${S.breakTitle}: ${advice.minutes} ${S.minutesShort}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          if (_endsAt == null) ...[
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.free_breakfast_rounded, size: 18),
              label: Text(S.breakStart),
            ),
          ] else if (!_done) ...[
            const SizedBox(height: 8),
            Text(
              _remainingLabel,
              style: TextStyle(
                fontFamily: 'Silkscreen',
                fontSize: 30,
                color: scheme.onSurface,
              ),
            ),
            Text(
              S.breakRunning,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
