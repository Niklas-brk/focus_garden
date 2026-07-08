/// Ausgang einer Session.
///
/// [bloomed] = die Fach-Pflanze hat die volle Blüte erreicht (wandert in den
/// Garten). [grown] = erfolgreiche Session, die Pflanze ist ein Stück gewachsen,
/// aber noch nicht voll erblüht (Phase 2, mehrstufige Blüte). [wilted]/[cancelled]
/// = abgebrochen bzw. verwelkt, kein Fortschritt.
enum SessionOutcome { bloomed, grown, wilted, cancelled }

/// Eine abgeschlossene Fokus-Session. Wird in Hive als einfache Map abgelegt
/// (kein Code-Generator nötig -> einfach & robust, Konzept Abschnitt 8).
class FocusSession {
  final String id;
  final String plantId;
  final String? subjectId; // zugehöriges Fach/Modul (Phase 2; alt: null)
  final int durationMinutes; // geplante Dauer
  final DateTime startTime;
  final DateTime endTime; // tatsächliches Ende (Auflösung)
  final SessionOutcome outcome;

  const FocusSession({
    required this.id,
    required this.plantId,
    this.subjectId,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    required this.outcome,
  });

  /// Volle Blüte -> Garten.
  bool get isBloomed => outcome == SessionOutcome.bloomed;

  /// Erfolgreiche Fokus-Session (gewachsen ODER erblüht) – zählt für
  /// Statistik/Streak/Fokusminuten.
  bool get isSuccess =>
      outcome == SessionOutcome.bloomed || outcome == SessionOutcome.grown;

  Map<String, dynamic> toMap() => {
        'id': id,
        'plantId': plantId,
        'subjectId': subjectId,
        'durationMinutes': durationMinutes,
        'startMs': startTime.millisecondsSinceEpoch,
        'endMs': endTime.millisecondsSinceEpoch,
        'outcome': outcome.name,
      };

  factory FocusSession.fromMap(Map<String, dynamic> m) => FocusSession(
        id: m['id'] as String,
        plantId: m['plantId'] as String,
        subjectId: m['subjectId'] as String?,
        durationMinutes: m['durationMinutes'] as int,
        startTime: DateTime.fromMillisecondsSinceEpoch(m['startMs'] as int),
        endTime: DateTime.fromMillisecondsSinceEpoch(m['endMs'] as int),
        outcome: SessionOutcome.values.firstWhere(
          (o) => o.name == m['outcome'],
          orElse: () => SessionOutcome.wilted,
        ),
      );
}
