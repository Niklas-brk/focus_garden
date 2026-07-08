import 'package:flutter_test/flutter_test.dart';

import 'package:focus_garden/models/plant_catalog.dart';
import 'package:focus_garden/models/focus_session.dart';
import 'package:focus_garden/utils/growth.dart';
import 'package:focus_garden/utils/stats.dart';

void main() {
  test('Katalog enthält 4 Gratis- und 6 Premium-Pflanzen', () {
    expect(PlantCatalog.free.length, 4);
    expect(PlantCatalog.premium.length, 6);
    expect(PlantCatalog.all.length, 10);
  });

  test('Wachstumsstufen ordnen den Fortschritt korrekt zu', () {
    expect(Growth.stageForProgress(0.0), 1);
    expect(Growth.stageForProgress(0.3), 2);
    expect(Growth.stageForProgress(0.6), 3);
    expect(Growth.stageForProgress(0.99), 4);
    expect(Growth.stageForProgress(1.0), 4);
  });

  test('Streak zählt aufeinanderfolgende Tage mit erblühter Session', () {
    final now = DateTime(2026, 7, 4, 12);
    FocusSession bloom(DateTime end) => FocusSession(
          id: end.toIso8601String(),
          plantId: 'p01',
          durationMinutes: 25,
          startTime: end.subtract(const Duration(minutes: 25)),
          endTime: end,
          outcome: SessionOutcome.bloomed,
        );
    final sessions = [
      bloom(DateTime(2026, 7, 4, 10)),
      bloom(DateTime(2026, 7, 3, 10)),
      bloom(DateTime(2026, 7, 2, 10)),
    ];
    final stats = Stats(sessions, now: now);
    expect(stats.streak, 3);
    expect(stats.totalSessions, 3);
    expect(stats.totalMinutes, 75);
  });

  test('Statistik zählt gewachsen + erblüht, Blüten separat', () {
    final now = DateTime(2026, 7, 4, 12);
    FocusSession make(DateTime end, SessionOutcome o, int min) => FocusSession(
          id: '${end.toIso8601String()}_${o.name}',
          plantId: 'p01',
          durationMinutes: min,
          startTime: end.subtract(Duration(minutes: min)),
          endTime: end,
          outcome: o,
        );
    final sessions = [
      make(DateTime(2026, 7, 4, 9), SessionOutcome.grown, 25),
      make(DateTime(2026, 7, 4, 11), SessionOutcome.bloomed, 45),
      make(DateTime(2026, 7, 3, 10), SessionOutcome.wilted, 25),
    ];
    final stats = Stats(sessions, now: now);
    // Fokusminuten/Sessions zählen gewachsen + erblüht (nicht verwelkt).
    expect(stats.totalSessions, 2);
    expect(stats.totalMinutes, 70);
    // Pflanzen im Garten = nur volle Blüten.
    expect(stats.totalBlooms, 1);
    expect(stats.weekBlooms, 1);
    // Verwelkter Tag zählt nicht für den Streak.
    expect(stats.streak, 1);
  });
}
