import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/focus_session.dart';
import '../models/subject.dart';

/// Minimale Schnittstelle für den sicheren Geheimnis-Speicher.
///
/// Im echten Betrieb steckt dahinter flutter_secure_storage – auf Android
/// landet der Schlüssel damit im Hardware-gestützten Android Keystore.
/// In Tests kann stattdessen eine einfache In-Memory-Map verwendet werden.
abstract class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class _SecureStorageSecretStore implements SecretStore {
  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

/// Kapselt die gesamte lokale Persistenz über Hive (Konzept Abschnitt 8).
///
/// Es werden bewusst nur einfache Maps/Primitive gespeichert – kein
/// Code-Generator, keine TypeAdapter. Das hält das Projekt für Einsteiger
/// überschaubar und robust.
///
/// Sicherheit: Alle Boxen sind mit AES-256 verschlüsselt (HiveAesCipher).
/// Der Schlüssel wird einmalig erzeugt und liegt ausschließlich im sicheren
/// Speicher des Systems (Android Keystore) – nie im Klartext in einer Datei.
/// Bestände aus älteren, unverschlüsselten Installationen werden beim ersten
/// Start einmalig verlustfrei in verschlüsselte Boxen überführt.
class StorageService {
  StorageService({SecretStore? secrets})
      : _secrets = secrets ?? _SecureStorageSecretStore();

  static const _sessionsBoxName = 'sessions';
  static const _settingsBoxName = 'settings';
  static const _activeBoxName = 'active_session';
  static const _subjectsBoxName = 'subjects';

  /// Einträge im sicheren Speicher: der AES-Schlüssel (base64) und ein
  /// Merker, dass die einmalige Verschlüsselungs-Migration abgeschlossen ist.
  static const _aesKeyEntry = 'hive_aes_key';
  static const _migratedEntry = 'hive_encrypted_v1';

  final SecretStore _secrets;

  late final Box _sessions;
  late final Box _settings;
  late final Box _active;
  late final Box _subjects;

  /// [testPath] nur für Tests: initialisiert Hive in einem Ordner statt über
  /// die Flutter-Plugins (die es in reinen Dart-Tests nicht gibt).
  Future<void> init({String? testPath}) async {
    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }

    final cipher = HiveAesCipher(await _loadOrCreateKey());
    final migrated = await _secrets.read(_migratedEntry) != null;

    _sessions = await _openEncrypted(_sessionsBoxName, cipher, migrated);
    _settings = await _openEncrypted(_settingsBoxName, cipher, migrated);
    _active = await _openEncrypted(_activeBoxName, cipher, migrated);
    _subjects = await _openEncrypted(_subjectsBoxName, cipher, migrated);

    if (!migrated) {
      await _secrets.write(_migratedEntry, 'true');
    }
  }

  /// Liest den AES-256-Schlüssel aus dem sicheren Speicher oder erzeugt ihn
  /// beim allerersten Start (kryptografisch sicherer Zufall).
  Future<List<int>> _loadOrCreateKey() async {
    final stored = await _secrets.read(_aesKeyEntry);
    if (stored != null) return base64Decode(stored);

    final key = Hive.generateSecureKey();
    await _secrets.write(_aesKeyEntry, base64Encode(key));
    return key;
  }

  /// Öffnet eine Box verschlüsselt. Existiert die Box noch aus einer alten,
  /// unverschlüsselten Installation, werden ihre Daten einmalig kopiert.
  Future<Box> _openEncrypted(
    String name,
    HiveAesCipher cipher,
    bool alreadyMigrated,
  ) async {
    if (!alreadyMigrated && await Hive.boxExists(name)) {
      try {
        // crashRecovery aus: Ist die Box wider Erwarten schon verschlüsselt
        // (z. B. Migration beim letzten Start abgebrochen), soll Hive einen
        // Fehler werfen statt vermeintlich kaputte Daten wegzukürzen.
        final plain = await Hive.openBox(name, crashRecovery: false);
        final data = Map<dynamic, dynamic>.of(plain.toMap());
        await plain.deleteFromDisk();
        final encrypted = await Hive.openBox(name, encryptionCipher: cipher);
        await encrypted.putAll(data);
        return encrypted;
      } catch (_) {
        // Ließ sich nicht unverschlüsselt lesen -> Box ist bereits
        // verschlüsselt, unten ganz normal öffnen.
      }
    }
    return Hive.openBox(name, encryptionCipher: cipher);
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
