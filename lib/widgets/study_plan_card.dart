import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/subject.dart';
import '../services/calendar_export.dart';
import '../utils/study_plan.dart';

/// Karte „Lernplan" im Noten-Tab: zeigt die nächsten 7 Tage (wer wann dran
/// ist, abgeleitet aus Prüfungsterminen, Lernzeit und Prüfungs-Feedback) und
/// exportiert den Plan auf Wunsch als Kalender-Datei (.ics).
class StudyPlanCard extends StatelessWidget {
  final List<Subject> subjects;

  const StudyPlanCard({super.key, required this.subjects});

  Future<void> _export(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await CalendarExport.share(subjects);
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(S.planExportError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final plan = StudyPlan.build(subjects, now, days: 7);
    final visibleDays = plan.where((d) => !d.isEmpty).toList();
    final hasPlan = visibleDays.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note_rounded, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.planTitle,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              if (hasPlan)
                TextButton.icon(
                  onPressed: () => _export(context),
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: Text(S.planExport),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (!hasPlan)
            Text(
              S.planEmpty,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            )
          else
            for (final day in visibleDays) _DayRow(day: day, now: now),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final StudyDay day;
  final DateTime now;

  const _DayRow({required this.day, required this.now});

  String get _dayLabel {
    final diff = daysUntil(now, day.date);
    if (diff == 0) return S.planToday;
    if (diff == 1) return S.planTomorrow;
    final wd = S.weekdayShort[day.date.weekday - 1];
    return '$wd ${S.shortDate(day.date)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final examToday = day.examsToday.isNotEmpty;
    final rec = examToday ? day.examsToday.first : day.top;
    if (rec == null) return const SizedBox.shrink();

    final String text;
    if (examToday) {
      // Prüfungstag: Daumen drücken statt lernen.
      text =
          '${S.planExamToday} ${S.examKind(rec.exam.kind)} · ${rec.subject.name} 🍀';
    } else {
      final left = rec.daysLeft(day.date);
      final wann = left == 1
          ? S.planTomorrow.toLowerCase()
          : S.planDaysLeft.replaceFirst('{n}', '$left');
      text =
          '${rec.subject.name} · ${S.examKind(rec.exam.kind)} $wann (${S.learnTime(rec.subject.learnTime).toLowerCase()})';
    }

    // Weitere fällige Fächer desselben Tags kompakt anhängen.
    final more = day.recommendations.skip(examToday ? 0 : 1).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(
              _dayLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: examToday ? scheme.error : scheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if (more.isNotEmpty)
                  Text(
                    '+ ${more.map((r) => r.subject.name).join(', ')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
