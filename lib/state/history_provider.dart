import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/focus_session.dart';
import '../models/scene_decoration.dart';
import '../services/storage_service.dart';
import '../utils/stats.dart';

/// Hält alle abgeschlossenen Sessions (Garten + Statistik-Quelle).
class HistoryProvider extends ChangeNotifier {
  final StorageService storage;

  static const _kGardenOrder = 'gardenOrder';
  static const _kScenePositions = 'scenePositions';
  static const _kSceneDecorations = 'sceneDecorations';

  List<FocusSession> _sessions = [];
  List<String> _gardenOrder = [];

  /// Frei gewählte Positionen der Pflanzen in der Garten-Szene (Wallpaper).
  /// Je Session-ID eine normalisierte Position (x,y je 0..1). Fehlt eine
  /// Pflanze hier, wird sie beim Öffnen automatisch platziert.
  Map<String, Offset> _scenePositions = {};

  /// Vom Nutzer platzierte Deko-Objekte (Emoji) in der Garten-Szene.
  List<SceneDecoration> _decorations = [];

  HistoryProvider(this.storage) {
    _gardenOrder = storage.getStringList(_kGardenOrder);
    _loadScenePositions();
    _loadDecorations();
    reload();
  }

  /// Lädt neu aus Hive (nach jeder abgeschlossenen Session).
  void reload() {
    _sessions = storage.allSessions()
      ..sort((a, b) => b.endTime.compareTo(a.endTime));
    notifyListeners();
  }

  /// Erblühte Pflanzen im Garten. Standard: neueste zuerst. Hat der Nutzer den
  /// Garten selbst angeordnet (`_gardenOrder`), gilt diese Reihenfolge; neue
  /// Pflanzen, die noch nicht einsortiert sind, erscheinen oben (neueste zuerst).
  List<FocusSession> get garden {
    final bloomed = _sessions.where((s) => s.isBloomed).toList();
    if (_gardenOrder.isEmpty) return bloomed; // schon neueste-zuerst sortiert

    bloomed.sort((a, b) {
      final ra = _gardenOrder.indexOf(a.id);
      final rb = _gardenOrder.indexOf(b.id);
      if (ra == -1 && rb == -1) return b.endTime.compareTo(a.endTime);
      if (ra == -1) return -1; // neue Pflanze zuerst
      if (rb == -1) return 1;
      return ra.compareTo(rb);
    });
    return bloomed;
  }

  /// Speichert die vom Nutzer gewählte Reihenfolge der Garten-Pflanzen.
  Future<void> setGardenOrder(List<String> ids) async {
    _gardenOrder = ids;
    await storage.setStringList(_kGardenOrder, ids);
    notifyListeners();
  }

  // ---- Garten-Szene / Wallpaper ---------------------------------------------

  /// Gespeicherte Positionen der Pflanzen auf der Wiese (normalisiert 0..1).
  Map<String, Offset> get scenePositions => Map.unmodifiable(_scenePositions);

  void _loadScenePositions() {
    final raw = storage.getString(_kScenePositions, '');
    if (raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _scenePositions = decoded.map((key, value) {
        final list = (value as List).cast<num>();
        return MapEntry(key, Offset(list[0].toDouble(), list[1].toDouble()));
      });
    } catch (_) {
      _scenePositions = {};
    }
  }

  /// Übernimmt die (kompletten) Szenen-Positionen und schreibt sie nach Hive.
  Future<void> setScenePositions(Map<String, Offset> positions) async {
    _scenePositions = Map.of(positions);
    final encoded = jsonEncode(
      positions.map((key, v) => MapEntry(key, [v.dx, v.dy])),
    );
    await storage.setString(_kScenePositions, encoded);
    notifyListeners();
  }

  /// Setzt die Anordnung zurück (Pflanzen werden neu automatisch verteilt).
  Future<void> resetScenePositions() async {
    _scenePositions = {};
    await storage.setString(_kScenePositions, '');
    notifyListeners();
  }

  /// Vom Nutzer platzierte Deko-Objekte der Garten-Szene.
  List<SceneDecoration> get decorations => List.unmodifiable(_decorations);

  void _loadDecorations() {
    final raw = storage.getString(_kSceneDecorations, '');
    if (raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List;
      _decorations = list
          .map((e) =>
              SceneDecoration.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      _decorations = [];
    }
  }

  /// Übernimmt die (komplette) Deko-Liste und schreibt sie nach Hive.
  Future<void> setDecorations(List<SceneDecoration> decorations) async {
    _decorations = List.of(decorations);
    final encoded =
        jsonEncode(decorations.map((d) => d.toMap()).toList());
    await storage.setString(_kSceneDecorations, encoded);
    notifyListeners();
  }

  Stats get stats => Stats(_sessions);

  /// Nur für Debug/Screenshots: füllt den Garten mit einer schönen Auswahl an
  /// Beispiel-Sessions über die letzten 7 Tage (ergibt Streak, Wochenbilanz und
  /// ein volles 7-Tage-Diagramm). Vorhandene Sessions werden vorher entfernt.
  Future<void> seedSampleData() async {
    await storage.clearSessions();
    final now = DateTime.now();

    FocusSession make(int daysAgo, int hour, String plantId, int minutes) {
      final end = DateTime(now.year, now.month, now.day, hour)
          .subtract(Duration(days: daysAgo));
      return FocusSession(
        id: 'seed_${daysAgo}_${plantId}_$minutes',
        plantId: plantId,
        durationMinutes: minutes,
        startTime: end.subtract(Duration(minutes: minutes)),
        endTime: end,
        outcome: SessionOutcome.bloomed,
      );
    }

    // Ein bis zwei Blüten pro Tag über 7 aufeinanderfolgende Tage.
    final samples = <FocusSession>[
      make(0, 9, 'p04', 25),
      make(0, 14, 'p07', 45),
      make(1, 10, 'p03', 60),
      make(2, 16, 'p01', 45),
      make(3, 11, 'p05', 90),
      make(4, 18, 'p02', 25),
      make(5, 8, 'p06', 45),
      make(6, 20, 'p08', 60),
    ];
    for (final s in samples) {
      await storage.addSession(s);
    }
    reload();
  }

  /// Monate (Jahr, Monat), in denen es erblühte Pflanzen gibt – für den Filter.
  List<DateTime> get availableMonths {
    final months = <DateTime>{};
    for (final s in garden) {
      months.add(DateTime(s.endTime.year, s.endTime.month));
    }
    final list = months.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }
}
