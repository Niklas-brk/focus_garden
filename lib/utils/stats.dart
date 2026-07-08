import '../models/focus_session.dart';

/// Ein Balken für das 7-Tage-Diagramm.
class DayBar {
  final String label; // Mo, Di, ...
  final int minutes;
  final bool isToday;
  const DayBar(this.label, this.minutes, this.isToday);
}

/// Reine Statistik-Berechnungen (Konzept Abschnitt 3: heute / Woche / gesamt +
/// Streak). Fokusminuten, Sessions und Streak zählen seit Phase 2 ALLE
/// erfolgreichen Sessions (gewachsen + erblüht); die reine Pflanzenzahl (für
/// Garten/Flex-Card) zählt nur die vollen Blüten.
class Stats {
  /// Erfolgreiche Sessions (gewachsen + erblüht) – Basis für Zeit/Streak.
  final List<FocusSession> success;

  /// Nur volle Blüten – Basis für die Pflanzenzahl.
  final List<FocusSession> blooms;
  final DateTime now;

  Stats(List<FocusSession> sessions, {DateTime? now})
      : success = sessions.where((s) => s.isSuccess).toList(),
        blooms = sessions.where((s) => s.isBloomed).toList(),
        now = now ?? DateTime.now();

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get _today => _dateOnly(now);

  /// Montag der aktuellen Woche.
  DateTime get _weekStart {
    final t = _today;
    return t.subtract(Duration(days: t.weekday - 1));
  }

  int _minutesWhere(bool Function(DateTime) test) => success
      .where((s) => test(s.endTime))
      .fold(0, (sum, s) => sum + s.durationMinutes);

  int get todayMinutes => _minutesWhere((d) => _dateOnly(d) == _today);

  int get weekMinutes =>
      _minutesWhere((d) => !_dateOnly(d).isBefore(_weekStart));

  int get totalMinutes =>
      success.fold(0, (sum, s) => sum + s.durationMinutes);

  int get todaySessions =>
      success.where((s) => _dateOnly(s.endTime) == _today).length;

  int get weekSessions =>
      success.where((s) => !_dateOnly(s.endTime).isBefore(_weekStart)).length;

  int get totalSessions => success.length;

  /// Volle Blüten dieser Woche (= neue Pflanzen im Garten).
  int get weekBlooms =>
      blooms.where((s) => !_dateOnly(s.endTime).isBefore(_weekStart)).length;

  /// Alle jemals erblühten Pflanzen.
  int get totalBlooms => blooms.length;

  /// Aufeinanderfolgende Tage mit mind. 1 erfolgreichen Session.
  /// Zählt bis heute; ist heute noch nichts geschafft, bleibt eine bis gestern
  /// laufende Serie erhalten (der Tag kann noch vervollständigt werden).
  int get streak {
    final days = success.map((s) => _dateOnly(s.endTime)).toSet();
    if (days.isEmpty) return 0;

    var day = _today;
    if (!days.contains(day)) {
      day = day.subtract(const Duration(days: 1));
      if (!days.contains(day)) return 0;
    }

    var count = 0;
    while (days.contains(day)) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  /// Minuten pro Tag für die letzten 7 Tage (ältester zuerst).
  List<DayBar> last7Days() {
    const weekdayShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final bars = <DayBar>[];
    for (var i = 6; i >= 0; i--) {
      final day = _today.subtract(Duration(days: i));
      final minutes = success
          .where((s) => _dateOnly(s.endTime) == day)
          .fold(0, (sum, s) => sum + s.durationMinutes);
      bars.add(DayBar(weekdayShort[day.weekday - 1], minutes, i == 0));
    }
    return bars;
  }
}
