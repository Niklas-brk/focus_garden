import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../utils/study_tips.dart';

/// Karte „Lerntipp" im Fokus-Tab: zeigt einen fachspezifischen Tipp zum
/// gewählten Fach (Kategorie-Erkennung in [StudyTips]). Der Tipp rotiert
/// täglich; der Knopf rechts blättert manuell weiter.
class StudyTipCard extends StatefulWidget {
  final String subjectName;

  const StudyTipCard({super.key, required this.subjectName});

  @override
  State<StudyTipCard> createState() => _StudyTipCardState();
}

class _StudyTipCardState extends State<StudyTipCard> {
  int _extra = 0; // manuelle Weiterklicks zusätzlich zur Tages-Rotation

  /// Tag des Jahres als Basis-Index: so zeigt jeder Tag einen anderen Tipp.
  /// Über UTC-Daten gerechnet, damit der Wechsel trotz Sommerzeit immer
  /// exakt um Mitternacht passiert.
  int get _dayIndex {
    final now = DateTime.now();
    return DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(now.year))
        .inDays;
  }

  @override
  void didUpdateWidget(covariant StudyTipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subjectName != widget.subjectName) {
      setState(() => _extra = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tip = StudyTips.tipFor(widget.subjectName, _dayIndex + _extra);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text('💡', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${S.tipTitle} · ${widget.subjectName}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                // Wechsel animieren, damit „Nächster Tipp" sichtbar reagiert.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    tip,
                    key: ValueKey(tip),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: scheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: S.tipNext,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.refresh_rounded,
              size: 20,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
            onPressed: () => setState(() => _extra++),
          ),
        ],
      ),
    );
  }
}
