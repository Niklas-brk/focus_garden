// Prüfungstermine eines Fachs. Jede Prüfung hat eine Kategorie (Schulaufgabe,
// Ex, Kurzarbeit, Präsentation) und ein Datum. Nach dem Termin fragt die App,
// wie es lief (1–10) – daraus lernt der Lernplan (schlechtes Gefühl → das Fach
// wird künftig stärker priorisiert).

/// Kategorie einer Prüfung. Bestimmt, wie früh und wie stark der Lernplan
/// das Fach vor dem Termin priorisiert (Schulaufgabe/Klausur am stärksten).
/// [klausur] ist die große Prüfung an Uni/Oberstufe außerhalb Bayerns.
enum ExamKind { schulaufgabe, klausur, kurzarbeit, ex, praesentation }

/// Welche Prüfungsarten im Termin-Dialog angeboten werden.
const List<ExamKind> kSchoolExamKinds = [
  ExamKind.schulaufgabe,
  ExamKind.klausur,
  ExamKind.kurzarbeit,
  ExamKind.ex,
  ExamKind.praesentation,
];
const List<ExamKind> kUniExamKinds = [
  ExamKind.klausur,
  ExamKind.praesentation,
];

/// Wie viele Tage vor dem Termin der Lernplan mit diesem Fach beginnt.
const Map<ExamKind, int> kExamLeadDays = {
  ExamKind.schulaufgabe: 14,
  ExamKind.klausur: 14,
  ExamKind.kurzarbeit: 7,
  ExamKind.ex: 5,
  ExamKind.praesentation: 10,
};

/// Grund-Gewicht einer Kategorie im Lernplan (größere Prüfung = wichtiger).
const Map<ExamKind, double> kExamWeights = {
  ExamKind.schulaufgabe: 3.0,
  ExamKind.klausur: 3.0,
  ExamKind.kurzarbeit: 2.0,
  ExamKind.ex: 1.5,
  ExamKind.praesentation: 2.0,
};

/// Ein Prüfungstermin. [rating] ist das Nachher-Feedback des Nutzers
/// (1 = lief schlecht … 10 = lief super), solange nicht beantwortet: null.
/// [ratingSkipped] merkt sich ein bewusstes „Überspringen", damit die App
/// nicht bei jedem Start erneut fragt.
class Exam {
  final String id;
  final DateTime date;
  final ExamKind kind;
  final int? rating; // 1–10, null = noch nicht bewertet
  final bool ratingSkipped;

  const Exam({
    required this.id,
    required this.date,
    required this.kind,
    this.rating,
    this.ratingSkipped = false,
  });

  /// Liegt der Termin (als Kalendertag) vor [today]?
  bool isPast(DateTime today) {
    final d = DateTime(date.year, date.month, date.day);
    final t = DateTime(today.year, today.month, today.day);
    return d.isBefore(t);
  }

  /// Steht das Feedback (1–10) noch aus?
  bool needsFeedback(DateTime today) =>
      isPast(today) && rating == null && !ratingSkipped;

  Exam copyWith({int? rating, bool? ratingSkipped}) => Exam(
        id: id,
        date: date,
        kind: kind,
        rating: rating ?? this.rating,
        ratingSkipped: ratingSkipped ?? this.ratingSkipped,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'dateMs': date.millisecondsSinceEpoch,
        'kind': kind.name,
        'rating': rating,
        'ratingSkipped': ratingSkipped,
      };

  factory Exam.fromMap(Map<String, dynamic> m) => Exam(
        id: m['id'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(m['dateMs'] as int),
        kind: _kindFromName(m['kind'] as String?),
        rating: m['rating'] as int?,
        ratingSkipped: m['ratingSkipped'] as bool? ?? false,
      );

  static ExamKind _kindFromName(String? name) {
    for (final k in ExamKind.values) {
      if (k.name == name) return k;
    }
    return ExamKind.ex; // robuster Fallback
  }
}
