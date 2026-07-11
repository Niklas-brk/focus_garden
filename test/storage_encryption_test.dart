import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:focus_garden/models/subject.dart';
import 'package:focus_garden/services/storage_service.dart';
import 'package:focus_garden/state/settings_provider.dart';
import 'package:focus_garden/state/subject_provider.dart';

/// Test-Ersatz fuer den Android Keystore: merkt sich Geheimnisse im RAM.
class FakeSecretStore implements SecretStore {
  final Map<String, String> data = {};

  @override
  Future<String?> read(String key) async => data[key];

  @override
  Future<void> write(String key, String value) async => data[key] = value;
}

/// Beispiel-Session als rohe Map, so wie die alte (unverschluesselte)
/// App-Version sie in Hive abgelegt hat.
Map<String, dynamic> _sessionMap(String id) => {
      'id': id,
      'plantId': 'p01',
      'subjectId': 'mathe',
      'durationMinutes': 25,
      'startMs': DateTime(2026, 7, 8, 10).millisecondsSinceEpoch,
      'endMs': DateTime(2026, 7, 8, 10, 25).millisecondsSinceEpoch,
      'outcome': 'bloomed',
    };

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fg_hive_test');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('Neue Installation: Daten ueberleben verschluesselt einen Neustart',
      () async {
    final secrets = FakeSecretStore();

    final storage = StorageService(secrets: secrets);
    await storage.init(testPath: tempDir.path);
    await storage.setString('gardenName', 'Niklas Garten');
    await storage.setActive({'plantId': 'p02', 'endMs': 123});

    // Schluessel + Migrations-Merker liegen im sicheren Speicher.
    expect(secrets.data['hive_aes_key'], isNotNull);
    expect(secrets.data['hive_encrypted_v1'], 'true');

    // "Neustart": Hive komplett schliessen und mit demselben Schluessel oeffnen.
    await Hive.close();
    final storage2 = StorageService(secrets: secrets);
    await storage2.init(testPath: tempDir.path);

    expect(storage2.getString('gardenName', ''), 'Niklas Garten');
    expect(storage2.getActive()?['plantId'], 'p02');
  });

  test('Migration: unverschluesselte Alt-Daten werden verlustfrei uebernommen',
      () async {
    // Alte App-Version simulieren: Boxen OHNE Verschluesselung befuellen.
    Hive.init(tempDir.path);
    final plainSessions = await Hive.openBox('sessions');
    await plainSessions.put('s1', _sessionMap('s1'));
    await plainSessions.put('s2', _sessionMap('s2'));
    final plainSettings = await Hive.openBox('settings');
    await plainSettings.put('gardenName', 'Alter Garten');
    await Hive.close();

    // Update auf die verschluesselte Version: frischer SecretStore (noch kein
    // Schluessel, kein Migrations-Merker).
    final secrets = FakeSecretStore();
    final storage = StorageService(secrets: secrets);
    await storage.init(testPath: tempDir.path);

    final sessions = storage.allSessions();
    expect(sessions.length, 2);
    expect(sessions.map((s) => s.id).toSet(), {'s1', 's2'});
    expect(storage.getString('gardenName', ''), 'Alter Garten');
    expect(secrets.data['hive_encrypted_v1'], 'true');

    // Beweis, dass die Datei jetzt wirklich verschluesselt ist: Der Klartext
    // von frueher darf in der Box-Datei nicht mehr vorkommen.
    final boxFile = File('${tempDir.path}/settings.hive');
    final bytes = await boxFile.readAsString(encoding: latin1);
    expect(bytes.contains('Alter Garten'), isFalse);

    // Und nach einem weiteren Neustart ist alles weiterhin lesbar.
    await Hive.close();
    final storage2 = StorageService(secrets: secrets);
    await storage2.init(testPath: tempDir.path);
    expect(storage2.allSessions().length, 2);
    expect(storage2.getString('gardenName', ''), 'Alter Garten');
  });

  test('Studienfaecher: ueberstehen Neustart, Umbenennen zieht Module mit',
      () async {
    final secrets = FakeSecretStore();
    final storage = StorageService(secrets: secrets);
    await storage.init(testPath: tempDir.path);

    final settings = SettingsProvider(storage);
    expect(settings.studienfaecher, isEmpty);
    expect(settings.addStudienfach('Deutsch'), isTrue);
    expect(settings.addStudienfach('deutsch'), isFalse); // Duplikat, Case egal
    expect(settings.addStudienfach('Reli'), isTrue);

    final subjects = SubjectProvider(storage);
    await subjects.add(Subject(
      id: 'm1',
      name: 'Dogmatik',
      plantId: 'p01',
      studienfach: 'Reli',
    ));

    // Umbenennen: Profil-Liste und Modul-Zuordnung wandern gemeinsam.
    expect(settings.renameStudienfach('Reli', 'Religion'), isTrue);
    expect(settings.renameStudienfach('Deutsch', 'religion'), isFalse);
    await subjects.renameStudienfach('Reli', 'Religion');
    expect(subjects.byStudienfach('Religion').length, 1);

    // "Neustart": alles kommt aus Hive zurueck.
    await Hive.close();
    final storage2 = StorageService(secrets: secrets);
    await storage2.init(testPath: tempDir.path);
    expect(SettingsProvider(storage2).studienfaecher, ['Deutsch', 'Religion']);
    expect(storage2.allSubjects().single.studienfach, 'Religion');
  });
}
