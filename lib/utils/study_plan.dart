import '../models/exam.dart';
import '../models/subject.dart';

/// Uhrzeit (Stunde) der Lern-Erinnerung je bevorzugter Lernzeit.
const Map<LearnTime, int> kLearnTimeHour = {
  LearnTime.morgens: 8,
  LearnTime.mittags: 13,
  LearnTime.abends: 18,
};

/// Kalendertage von [from] bis [target] (0 = derselbe Tag, negativ = vorbei).
int daysUntil(DateTime from, DateTime target) {
  final f = DateTime(from.year, from.month, from.day);
  final t = DateTime(target.year, target.month, target.day);
  return t.difference(f).inDays;
}

/// Eine Lern-Empfehlung für einen Tag: welches Fach, wegen welcher Prüfung,
/// und wie dringend ([score], nur zum Sortieren).
class StudyRecommendation {
  final Subject subject;
  final Exam exam; // die (dringendste) Prüfung, für die gelernt werden soll
  final double score;

  const StudyRecommendation({
    required this.subject,
    required this.exam,
    required this.score,
  });

  /// Verbleibende Tage bis zur Prüfung ab [day] (0 = Prüfungstag).
  int daysLeft(DateTime day) => daysUntil(day, exam.date);
}

/// Ein Tag im Lernplan: die empfohlenen Fächer (dringendstes zuerst) und die
/// Prüfungen, die an diesem Tag selbst stattfinden.
class StudyDay {
  final DateTime date;
  final List<StudyRecommendation> recommendations;
  final List<StudyRecommendation> examsToday;

  const StudyDay({
    required this.date,
    required this.recommendations,
    required this.examsToday,
  });

  bool get isEmpty => recommendations.isEmpty && examsToday.isEmpty;

  /// Das wichtigste Fach des Tages (für die Erinnerung), sonst null.
  StudyRecommendation? get top =>
      recommendations.isEmpty ? null : recommendations.first;
}

/// Reine, testbare Lernplan-Logik.
///
/// Idee: Jede anstehende Prüfung „zieht" ihr Fach in den Plan, sobald sie
/// näher rückt als ihr Vorlauf ([kExamLeadDays], Schulaufgabe 14 Tage, Ex 5 …).
/// Je näher der Termin und je größer die Prüfungsart ([kExamWeights]), desto
/// dringender. Das Prüfungs-Feedback (1–10) passt den Plan an: lief es zuletzt
/// schlecht (< 5,5), wird das Fach stärker priorisiert – lief es gut, schwächer.
class StudyPlan {
  /// Dringlichkeit eines Fachs an einem Tag (0 = heute nichts zu lernen).
  /// Öffentlich, damit Tests die Formel direkt prüfen können.
  static double scoreFor(Subject subject, DateTime day) {
    double score = 0;
    for (final exam in subject.exams) {
      final lead = kExamLeadDays[exam.kind]!;
      final left = daysUntil(day, exam.date);
      if (left < 0 || left > lead) continue; // vorbei oder noch zu weit weg
      // Von 1× (Vorlauf-Beginn) bis 2× (Prüfungstag) des Art-Gewichts.
      score += kExamWeights[exam.kind]! * (1 + (lead - left) / lead);
    }
    return score * ratingFactor(subject.averageExamRating);
  }

  /// Anpassung aus dem Prüfungs-Feedback: 1 (schlecht) → ×1,45 … 10 → ×0,55.
  /// Ohne Feedback neutral (×1). Begrenzung schützt vor Extremwerten.
  static double ratingFactor(double? avgRating) {
    if (avgRating == null) return 1;
    return (1 + (5.5 - avgRating) * 0.1).clamp(0.5, 1.6);
  }

  /// Die dringendste anstehende Prüfung eines Fachs ab [day] (im Vorlauf).
  static Exam? _dueExam(Subject subject, DateTime day) {
    Exam? best;
    var bestLeft = 1 << 30;
    for (final exam in subject.exams) {
      final left = daysUntil(day, exam.date);
      final lead = kExamLeadDays[exam.kind]!;
      if (left < 0 || left > lead) continue;
      if (left < bestLeft) {
        bestLeft = left;
        best = exam;
      }
    }
    return best;
  }

  /// Baut den Lernplan für [days] Tage ab [from]. Leere Tage stehen mit
  /// leeren Listen drin (die Anzeige überspringt sie).
  static List<StudyDay> build(
    List<Subject> subjects,
    DateTime from, {
    int days = 7,
  }) {
    final plan = <StudyDay>[];
    for (var i = 0; i < days; i++) {
      final day = DateTime(from.year, from.month, from.day + i);

      final recs = <StudyRecommendation>[];
      final today = <StudyRecommendation>[];
      for (final subject in subjects) {
        final due = _dueExam(subject, day);
        if (due == null) continue;
        final rec = StudyRecommendation(
          subject: subject,
          exam: due,
          score: scoreFor(subject, day),
        );
        if (rec.daysLeft(day) == 0) {
          today.add(rec); // Prüfungstag: nicht mehr „lernen", sondern Daumen!
        } else {
          recs.add(rec);
        }
      }
      recs.sort((a, b) => b.score.compareTo(a.score));
      plan.add(StudyDay(date: day, recommendations: recs, examsToday: today));
    }
    return plan;
  }

  /// Alle Prüfungen, deren Feedback (1–10) noch aussteht – für den Frage-Dialog
  /// beim App-Start. Liefert Paare (Fach, Prüfung), älteste zuerst.
  static List<(Subject, Exam)> pendingFeedback(
    List<Subject> subjects,
    DateTime today,
  ) {
    final result = <(Subject, Exam)>[];
    for (final subject in subjects) {
      for (final exam in subject.exams) {
        if (exam.needsFeedback(today)) result.add((subject, exam));
      }
    }
    result.sort((a, b) => a.$2.date.compareTo(b.$2.date));
    return result;
  }
}
