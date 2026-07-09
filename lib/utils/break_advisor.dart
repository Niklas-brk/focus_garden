/// Empfehlung für die Pause nach einer Fokus-Session.
class BreakAdvice {
  final int minutes;
  final bool isLong; // lange Erholungspause (nach der 4. Session des Tages)
  const BreakAdvice({required this.minutes, required this.isLong});
}

/// Reine, testbare Pausen-Logik – „die perfekte Pausenzeit".
///
/// Grundlage sind bewährte Lern-Rhythmen:
///  - Pomodoro: 25 Min Fokus → 5 Min Pause (Verhältnis ~5:1)
///  - DeskTime-Studie: 52 Min Arbeit → 17 Min Pause (~4:1 bei langen Blöcken)
///  - Ultradiane Rhythmen: nach ~90 Min braucht das Gehirn 15–20 Min Erholung
///
/// Daraus die Faustregel: ~1 Minute Pause je 5 Minuten Fokus (begrenzt auf
/// 5–20 Min). Nach jeder 4. erfolgreichen Session des Tages (Pomodoro-Zyklus)
/// wird eine doppelt so lange Erholungspause (15–30 Min) empfohlen.
class BreakAdvisor {
  static BreakAdvice recommend({
    required int sessionMinutes,
    required int todaysCompletedSessions, // inkl. der gerade beendeten
  }) {
    final base = (sessionMinutes / 5).round().clamp(5, 20);
    final long =
        todaysCompletedSessions > 0 && todaysCompletedSessions % 4 == 0;
    if (long) {
      return BreakAdvice(minutes: (base * 2).clamp(15, 30), isLong: true);
    }
    return BreakAdvice(minutes: base, isLong: false);
  }
}
