// Bildungsprofil des Nutzers (Phase 1: Noten). Bestimmt, welches
// Bewertungssystem im Notenrechner gilt.

/// Ob der Nutzer zur Schule geht oder studiert.
enum EduKind { schuelerin, studentin }

/// Schulart (nur relevant, wenn [EduKind.schuelerin]). Gymnasium rechnet in
/// Punkten (0–15), alle anderen in Noten (1–6).
enum SchoolType { gymnasium, realschule, hauptschule, gesamtschule }

/// Das aktive Bewertungssystem.
/// - [punkte]: 0–15 Punkte, höher ist besser (Gymnasium/Oberstufe).
/// - [noten]: Noten 1–6, niedriger ist besser (Real-/Haupt-/Gesamtschule).
/// - [uni]: Noten 1,0–5,0, ECTS-gewichtet, 4,0 = bestanden (Studium).
enum GradingSystem { punkte, noten, uni }

/// Leitet das Bewertungssystem aus dem Profil ab.
GradingSystem gradingFor(EduKind kind, SchoolType schoolType) {
  if (kind == EduKind.studentin) return GradingSystem.uni;
  if (schoolType == SchoolType.gymnasium) return GradingSystem.punkte;
  return GradingSystem.noten;
}

/// Grenzen und Format der Noteneingabe je Bewertungssystem.
extension GradingSystemRange on GradingSystem {
  /// Kleinster erlaubter Wert.
  double get minGrade => this == GradingSystem.punkte ? 0 : 1;

  /// Größter erlaubter Wert.
  double get maxGrade {
    switch (this) {
      case GradingSystem.punkte:
        return 15;
      case GradingSystem.noten:
        return 6;
      case GradingSystem.uni:
        return 5;
    }
  }

  /// Bei Punkten ist die höhere Zahl besser, bei Noten die niedrigere.
  bool get higherIsBetter => this == GradingSystem.punkte;
}
