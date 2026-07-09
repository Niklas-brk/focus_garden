import 'exam.dart';
import 'grade_entry.dart';

/// Wann der Nutzer dieses Fach am besten lernen kann. Bestimmt die Uhrzeit
/// der Lern-Erinnerung und des Kalender-Eintrags im Lernplan.
enum LearnTime { morgens, mittags, abends }

/// Ein Fach (Schule) bzw. Modul (Studium). Trägt Name, gewählte Pflanze, die
/// eingetragenen Einzelnoten [grades] samt Gewichtung [weights] und – bei
/// Studenten – die ECTS-Punkte. Zusätzlich den Blüh-Fortschritt: [bloomProgress]
/// sind Fokusminuten Richtung der aktuellen Blüte, [bloomedCount] zählt die
/// schon vollendeten Blüten (Phase 2). Für den Lernplan: die bevorzugte
/// [learnTime] und die [exams] (Prüfungstermine mit Nachher-Feedback).
///
/// Wird wie [FocusSession] als einfache Map in Hive gespeichert – kein
/// Code-Generator, bewusst einsteigerfreundlich.
class Subject {
  final String id;
  final String name;
  final String plantId;
  final double bloomProgress; // Fokusminuten Richtung aktueller Blüte
  final int bloomedCount; // Anzahl schon erblühter Pflanzen dieses Fachs
  final List<GradeEntry> grades; // einzelne Noten (nach Art)
  final Map<GradeKind, double> weights; // Gewicht je Noten-Art
  final int? credits; // ECTS (nur Studium)
  final LearnTime learnTime; // beste Lernzeit für dieses Fach
  final List<Exam> exams; // Prüfungstermine

  Subject({
    required this.id,
    required this.name,
    required this.plantId,
    this.bloomProgress = 0,
    this.bloomedCount = 0,
    List<GradeEntry>? grades,
    Map<GradeKind, double>? weights,
    this.credits,
    this.learnTime = LearnTime.abends,
    List<Exam>? exams,
  })  : grades = grades ?? const [],
        weights = weights ?? const {...kDefaultGradeWeights},
        exams = exams ?? const [];

  bool get hasGrade => grades.isNotEmpty;

  /// Die nächste anstehende Prüfung (heute mitgezählt), sonst null.
  Exam? nextExam(DateTime today) {
    final upcoming = exams.where((e) => !e.isPast(today)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  /// Durchschnitt der abgegebenen Prüfungs-Feedbacks (1–10), null = keins.
  /// Fließt in den Lernplan ein: lief es schlecht, wird früher/mehr gelernt.
  double? get averageExamRating {
    final ratings = exams.map((e) => e.rating).whereType<int>().toList();
    if (ratings.isEmpty) return null;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  /// Effektives Gewicht einer Noten-Art (fällt auf den Standard zurück).
  double weightOf(GradeKind kind) =>
      weights[kind] ?? kDefaultGradeWeights[kind]!;

  /// Die berechnete Zeugnis-/Modulnote dieses Fachs: gewichteter Durchschnitt
  /// der ARTEN-Durchschnitte. Nur vorhandene Arten zählen, jede mit ihrem
  /// Gewicht. Beispiel Bayern: 2·Ø(Schulaufgaben) + 1·Ø(kleine) geteilt durch 3.
  /// Für die Uni liegt i. d. R. nur eine Note vor → einfacher Mittelwert.
  double? get finalGrade {
    if (grades.isEmpty) return null;
    double num = 0, den = 0;
    for (final kind in GradeKind.values) {
      final vals =
          grades.where((g) => g.kind == kind).map((g) => g.value).toList();
      if (vals.isEmpty) continue;
      final avg = vals.reduce((a, b) => a + b) / vals.length;
      final w = weightOf(kind);
      num += w * avg;
      den += w;
    }
    // Falls alle vorhandenen Arten Gewicht 0 haben: einfacher Mittelwert.
    if (den == 0) {
      final all = grades.map((g) => g.value);
      return all.reduce((a, b) => a + b) / grades.length;
    }
    return num / den;
  }

  /// Kopie mit geänderten Feldern. Für die Blüh-Progression (Phase 2) reicht
  /// es, [bloomProgress]/[bloomedCount] zu setzen; Noten/Gewichte/ECTS werden
  /// beim Bearbeiten hingegen komplett neu über den Editor gesetzt.
  Subject copyWith({
    String? name,
    String? plantId,
    double? bloomProgress,
    int? bloomedCount,
    List<GradeEntry>? grades,
    Map<GradeKind, double>? weights,
    int? credits,
    LearnTime? learnTime,
    List<Exam>? exams,
  }) {
    return Subject(
      id: id,
      name: name ?? this.name,
      plantId: plantId ?? this.plantId,
      bloomProgress: bloomProgress ?? this.bloomProgress,
      bloomedCount: bloomedCount ?? this.bloomedCount,
      grades: grades ?? this.grades,
      weights: weights ?? this.weights,
      credits: credits ?? this.credits,
      learnTime: learnTime ?? this.learnTime,
      exams: exams ?? this.exams,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'plantId': plantId,
        'bloomProgress': bloomProgress,
        'bloomedCount': bloomedCount,
        'grades': grades.map((g) => g.toMap()).toList(),
        'weights': {
          for (final e in weights.entries) e.key.name: e.value,
        },
        'credits': credits,
        'learnTime': learnTime.name,
        'exams': exams.map((e) => e.toMap()).toList(),
      };

  factory Subject.fromMap(Map<String, dynamic> m) => Subject(
        id: m['id'] as String,
        name: m['name'] as String,
        plantId: m['plantId'] as String,
        bloomProgress: (m['bloomProgress'] as num?)?.toDouble() ?? 0,
        bloomedCount: m['bloomedCount'] as int? ?? 0,
        grades: _gradesFromMap(m),
        weights: _weightsFromMap(m['weights']),
        credits: m['credits'] as int?,
        // Migration: alte Fächer haben die Felder noch nicht -> Standardwerte.
        learnTime: _learnTimeFromName(m['learnTime'] as String?),
        exams: _examsFromMap(m['exams']),
      );

  static LearnTime _learnTimeFromName(String? name) {
    for (final t in LearnTime.values) {
      if (t.name == name) return t;
    }
    return LearnTime.abends;
  }

  static List<Exam> _examsFromMap(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((e) => Exam.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Liest die Notenliste. Migration alter Fächer: fehlt [grades], wird das
  /// frühere Einzelfeld [grade] als eine mündliche Note übernommen.
  static List<GradeEntry> _gradesFromMap(Map<String, dynamic> m) {
    final raw = m['grades'];
    if (raw is List) {
      return raw
          .map((e) => GradeEntry.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    final legacy = m['grade'];
    if (legacy is num) {
      return [GradeEntry(kind: GradeKind.muendlich, value: legacy.toDouble())];
    }
    return [];
  }

  static Map<GradeKind, double> _weightsFromMap(dynamic raw) {
    final result = <GradeKind, double>{...kDefaultGradeWeights};
    if (raw is Map) {
      for (final kind in GradeKind.values) {
        final v = raw[kind.name];
        if (v is num) result[kind] = v.toDouble();
      }
    }
    return result;
  }
}
