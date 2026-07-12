import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Wacht darüber, dass die englische Übersetzung vollständig bleibt:
/// Jedes `static String foo = …`-Feld (und jede statische Liste) in
/// `lib/l10n/app_strings.dart` muss in `_applyEnglish()` neu zugewiesen
/// werden. Fällt ein neues Feld durch, schlägt dieser Test fehl.
void main() {
  test('Englisch überschreibt jedes Strings-Feld', () {
    final source = File('lib/l10n/app_strings.dart').readAsStringSync();

    final englishStart = source.indexOf('static void _applyEnglish()');
    expect(englishStart, greaterThan(0),
        reason: '_applyEnglish() nicht gefunden');
    final declarations = source.substring(0, englishStart);
    final english = source.substring(englishStart);

    // Alle Feld-Namen aus den Deklarationen ziehen.
    final fieldPattern =
        RegExp(r'static (?:String|List<String>) (\w+) =', multiLine: true);
    final fields = fieldPattern
        .allMatches(declarations)
        .map((m) => m.group(1)!)
        .toSet();
    expect(fields.length, greaterThan(200),
        reason: 'Verdächtig wenige Felder gefunden – Regex kaputt?');

    // Jedes Feld muss im Englisch-Block per `name =` neu gesetzt werden.
    final missing = fields
        .where((f) => !RegExp('(^|\\s)$f\\s*=').hasMatch(english))
        .toList()
      ..sort();
    expect(missing, isEmpty,
        reason: 'Diese Felder haben keine englische Übersetzung: $missing');
  });
}
