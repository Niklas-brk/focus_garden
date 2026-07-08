import '../models/edu_profile.dart';
import '../models/subject.dart';

/// Ergebnis der Durchschnittsberechnung. [hasData] ist false, solange kein
/// einziges Fach eine Note trägt.
class GradeSummary {
  final bool hasData;
  final double average;
  final GradingSystem system;
  final int gradedCount; // Anzahl benoteter Fächer
  final int? totalCredits; // nur uni: Σ ECTS
  final bool? passed; // nur uni: Ø ≤ 4,0

  const GradeSummary({
    required this.hasData,
    required this.average,
    required this.system,
    required this.gradedCount,
    this.totalCredits,
    this.passed,
  });
}

/// Reine, testbare Notenrechner-Logik. Fächer ohne eingetragene Note werden
/// überall ausgelassen.
class GradeCalc {
  static GradeSummary summarize(List<Subject> subjects, GradingSystem system) {
    final graded = subjects.where((s) => s.hasGrade).toList();
    if (graded.isEmpty) {
      return GradeSummary(
        hasData: false,
        average: 0,
        system: system,
        gradedCount: 0,
      );
    }

    switch (system) {
      case GradingSystem.punkte:
      case GradingSystem.noten:
        // Einfacher Mittelwert der Fach-Zeugnisnoten (jede Zeugnisnote ist
        // ihrerseits schon der gewichtete Schnitt der Noten-Arten).
        final sum = graded.fold<double>(0, (a, s) => a + s.finalGrade!);
        return GradeSummary(
          hasData: true,
          average: sum / graded.length,
          system: system,
          gradedCount: graded.length,
        );

      case GradingSystem.uni:
        // ECTS-gewichtet: Σ(Note×CP) / Σ CP. Fehlen überall die ECTS, fällt es
        // auf den einfachen Mittelwert zurück (statt durch 0 zu teilen).
        final totalCredits = graded.fold<int>(0, (a, s) => a + (s.credits ?? 0));
        final double avg;
        if (totalCredits > 0) {
          final weighted = graded.fold<double>(
              0, (a, s) => a + s.finalGrade! * (s.credits ?? 0));
          avg = weighted / totalCredits;
        } else {
          final sum = graded.fold<double>(0, (a, s) => a + s.finalGrade!);
          avg = sum / graded.length;
        }
        return GradeSummary(
          hasData: true,
          average: avg,
          system: system,
          gradedCount: graded.length,
          totalCredits: totalCredits,
          passed: avg <= 4.0,
        );
    }
  }

  /// Deutsche Zahlformatierung mit einer Nachkommastelle (Komma statt Punkt).
  static String fmt(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

  /// Formatiert einen einzelnen Notenwert kompakt: Punkte ganzzahlig (13),
  /// Noten mit einer Nachkommastelle (2,0).
  static String valueText(GradingSystem system, double v) {
    if (system == GradingSystem.punkte) return v.round().toString();
    return fmt(v);
  }
}
