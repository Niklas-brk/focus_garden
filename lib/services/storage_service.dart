import 'package:hive_flutter/hive_flutter.dart';

import '../models/focus_session.dart';
import '../models/subject.dart';

/// Kapselt die gesamte lokale Persistenz über Hive (Konzept Abschnitt 8).
///
/// Es werden bewusst nur einfache Maps/Primitive gespeichert – kein
/// Code-Generator, keine TypeAdapter. Das hält das Projekt für Einsteiger
/// überschaubar und robust.
class StorageService {
  static const _sessionsBoxName = 'sessions';
  static const _settingsBoxName = 'settings';
  static const _activeBoxName = 'active_session';
  static const _subjectsBoxName = 'subjects';

  late final Box _sessions;
  late final Box _settings;
  late final Box _active;
  late final Box _subjects;

  Future<void> init() async {
    await Hive.initFlutter();
    _sessions = await Hive.openBox(_sessionsBoxName);
    _settings = await Hive.openBox(_settingsBoxName);
    _active = await Hive.openBox(_activeBoxName);
    _subjects = await Hive.openBox(_subjectsBoxName);
  }

  // ---- Sessions / Garten ----------------------------------------------------

  List<FocusSession> allSessions() {
    return _sessions.values
        .map((e) => FocusSession.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addSession(FocusSession session) =>
      _sessions.put(session.id, session.toMap());

  /// Nur für Debug/Screenshots: löscht alle gespeicherten Sessions.
  Future<void> clearSessions() => _sessions.clear();

  // ---- Fächer / Module (Noten) ----------------------------------------------

  List<Subject> allSubjects() {
    return _subjects.values
        .map((e) => Subject.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> putSubject(Map<String, dynamic> map) =>
      _subjects.put(map['id'], map);

  Future<void> deleteSubject(String id) => _subjects.delete(id);

  // ---- Laufende Session (für Timestamp-Logik & Absturz-Wiederherstellung) ----

  Map<String, dynamic>? getActive() {
    final raw = _active.get('current');
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  Future<void> setActive(Map<String, dynamic> data) =>
      _active.put('current', data);

  Future<void> clearActive() => _active.delete('current');

  // ---- Einstellungen --------------------------------------------------------

  bool getBool(String key, bool def) =>
      _settings.get(key, defaultValue: def) as bool;

  Future<void> setBool(String key, bool value) => _settings.put(key, value);

  String getString(String key, String def) =>
      _settings.get(key, defaultValue: def) as String;

  Future<void> setString(String key, String value) =>
      _settings.put(key, value);

  List<String> getStringList(String key) {
    final raw = _settings.get(key);
    if (raw is List) return raw.cast<String>();
    return const [];
  }

  Future<void> setStringList(String key, List<String> value) =>
      _settings.put(key, value);
}
