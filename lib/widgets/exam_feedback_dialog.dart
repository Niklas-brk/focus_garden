import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/exam.dart';
import '../models/subject.dart';
import '../state/subject_provider.dart';
import '../utils/study_plan.dart';

/// Fragt nach abgelaufenen Prüfungsterminen: „Wie lief es?" (1–10).
/// Die Antwort wird am Termin gespeichert und passt den Lernplan an
/// (schlechtes Gefühl → Fach wird künftig stärker priorisiert).
///
/// [maybeAsk] beim App-Start aufrufen: zeigt für jede offene Prüfung
/// nacheinander einen Dialog. „Später" fragt beim nächsten Start erneut,
/// „Ohne Bewertung" schließt den Termin dauerhaft.
class ExamFeedback {
  static Future<void> maybeAsk(
    BuildContext context,
    SubjectProvider subjects,
  ) async {
    final pending =
        StudyPlan.pendingFeedback(subjects.subjects, DateTime.now());
    for (final (subject, exam) in pending) {
      if (!context.mounted) return;
      final result = await showDialog<_FeedbackResult>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ExamFeedbackDialog(subject: subject, exam: exam),
      );
      if (result == null || result.later) continue;

      final updatedExam = result.rating != null
          ? exam.copyWith(rating: result.rating)
          : exam.copyWith(ratingSkipped: true);
      final updatedExams = subject.exams
          .map((e) => e.id == exam.id ? updatedExam : e)
          .toList();
      await subjects.update(subject.copyWith(exams: updatedExams));
    }
  }
}

class _FeedbackResult {
  final int? rating; // null = ohne Bewertung geschlossen
  final bool later;
  const _FeedbackResult({this.rating, this.later = false});
}

class _ExamFeedbackDialog extends StatefulWidget {
  final Subject subject;
  final Exam exam;

  const _ExamFeedbackDialog({required this.subject, required this.exam});

  @override
  State<_ExamFeedbackDialog> createState() => _ExamFeedbackDialogState();
}

class _ExamFeedbackDialogState extends State<_ExamFeedbackDialog> {
  double _value = 5;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final body = S.examFeedbackBody
        .replaceFirst('{art}', S.examKind(widget.exam.kind))
        .replaceFirst('{fach}', widget.subject.name)
        .replaceFirst('{datum}', S.shortDate(widget.exam.date));

    return AlertDialog(
      title: Text(S.examFeedbackTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(body),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('😖', style: TextStyle(fontSize: 20)),
              Expanded(
                child: Slider(
                  value: _value,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _value.round().toString(),
                  onChanged: (v) => setState(() => _value = v),
                ),
              ),
              Text('🤩', style: TextStyle(fontSize: 20)),
            ],
          ),
          Center(
            child: Text(
              '${_value.round()} / 10',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.examFeedbackHint,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context)
              .pop(const _FeedbackResult(later: true)),
          child: Text(S.examFeedbackLater),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(const _FeedbackResult()),
          child: Text(S.examFeedbackSkip),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context)
              .pop(_FeedbackResult(rating: _value.round())),
          child: Text(S.examFeedbackSave),
        ),
      ],
    );
  }
}
