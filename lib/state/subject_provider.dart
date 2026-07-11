import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../services/storage_service.dart';

/// Hält alle Fächer/Module des Nutzers und schreibt sie nach Hive.
class SubjectProvider extends ChangeNotifier {
  final StorageService storage;

  List<Subject> _subjects = [];

  SubjectProvider(this.storage) {
    reload();
  }

  /// Fächer in Anlege-Reihenfolge (Hive behält die Einfüge-Reihenfolge).
  List<Subject> get subjects => List.unmodifiable(_subjects);

  bool get isEmpty => _subjects.isEmpty;

  Subject? byId(String id) {
    for (final s in _subjects) {
      if (s.id == id) return s;
    }
    return null;
  }

  void reload() {
    _subjects = storage.allSubjects();
    notifyListeners();
  }

  Future<void> add(Subject subject) async {
    _subjects.add(subject);
    await storage.putSubject(subject.toMap());
    notifyListeners();
  }

  Future<void> update(Subject subject) async {
    final i = _subjects.indexWhere((s) => s.id == subject.id);
    if (i == -1) {
      return add(subject);
    }
    _subjects[i] = subject;
    await storage.putSubject(subject.toMap());
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _subjects.removeWhere((s) => s.id == id);
    await storage.deleteSubject(id);
    notifyListeners();
  }

  /// Alle Module, die diesem Studienfach zugeordnet sind (nur Studium).
  List<Subject> byStudienfach(String fach) =>
      _subjects.where((s) => s.studienfach == fach).toList();

  /// Löst die Zuordnung aller Module zu [fach] (wenn das Studienfach aus dem
  /// Profil entfernt wird). Die Module samt Noten bleiben erhalten.
  Future<void> clearStudienfach(String fach) async {
    for (var i = 0; i < _subjects.length; i++) {
      if (_subjects[i].studienfach != fach) continue;
      _subjects[i] = _subjects[i].copyWith(clearStudienfach: true);
      await storage.putSubject(_subjects[i].toMap());
    }
    notifyListeners();
  }

  /// Zieht die Modul-Zuordnungen beim Umbenennen eines Studienfachs nach:
  /// alle Module von [from] hängen danach an [to].
  Future<void> renameStudienfach(String from, String to) async {
    for (var i = 0; i < _subjects.length; i++) {
      if (_subjects[i].studienfach != from) continue;
      _subjects[i] = _subjects[i].copyWith(studienfach: to);
      await storage.putSubject(_subjects[i].toMap());
    }
    notifyListeners();
  }

  /// Für Phase 2 vorbereitet: schreibt Fokusminuten dem Blüh-Fortschritt des
  /// Fachs gut. Die eigentliche Blüh-Auswertung (Übertrag ab 120 min) baut
  /// Phase 2 im SessionProvider darauf auf.
  Future<void> addProgress(String id, double minutes) async {
    final subject = byId(id);
    if (subject == null) return;
    await update(
      subject.copyWith(bloomProgress: subject.bloomProgress + minutes),
    );
  }
}
