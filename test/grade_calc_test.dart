import 'package:flutter_test/flutter_test.dart';

import 'package:focus_garden/models/edu_profile.dart';
import 'package:focus_garden/models/grade_entry.dart';
import 'package:focus_garden/models/subject.dart';
import 'package:focus_garden/utils/grade_calc.dart';

Subject subj(
  String id, {
  double? grade,
  int? credits,
  List<GradeEntry>? grades,
  Map<GradeKind, double>? weights,
}) =>
    Subject(
      id: id,
      name: id,
      plantId: 'p01',
      grades: grades ??
          (grade == null
              ? const []
              : [GradeEntry(kind: GradeKind.muendlich, value: grade)]),
      weights: weights,
      credits: credits,
    );

GradeEntry g(GradeKind kind, double value) =>
    GradeEntry(kind: kind, value: value);

void main() {
  test('gradingFor leitet das Bewertungssystem korrekt ab', () {
    expect(gradingFor(EduKind.schuelerin, SchoolType.gymnasium),
        GradingSystem.punkte);
    expect(gradingFor(EduKind.schuelerin, SchoolType.realschule),
        GradingSystem.noten);
    expect(gradingFor(EduKind.studentin, SchoolType.gymnasium),
        GradingSystem.uni);
  });

  test('ohne benotete Fächer gibt es keine Daten', () {
    final s = GradeCalc.summarize([subj('a')], GradingSystem.noten);
    expect(s.hasData, false);
  });

  test('Punkte: einfacher Mittelwert (13 & 11 -> 12,0)', () {
    final s = GradeCalc.summarize(
      [subj('a', grade: 13), subj('b', grade: 11)],
      GradingSystem.punkte,
    );
    expect(s.hasData, true);
    expect(s.average, 12.0);
    expect(GradeCalc.fmt(s.average), '12,0');
  });

  test('Noten: einfacher Mittelwert, unbenotete Fächer zählen nicht', () {
    final s = GradeCalc.summarize(
      [subj('a', grade: 2), subj('b', grade: 3), subj('c')],
      GradingSystem.noten,
    );
    expect(s.gradedCount, 2);
    expect(s.average, 2.5);
  });

  test('Uni: ECTS-gewichteter Durchschnitt + Summe CP + bestanden', () {
    // (1,0*5 + 3,0*10) / 15 = 35/15 = 2,333…
    final s = GradeCalc.summarize(
      [subj('a', grade: 1.0, credits: 5), subj('b', grade: 3.0, credits: 10)],
      GradingSystem.uni,
    );
    expect(s.totalCredits, 15);
    expect(s.average, closeTo(2.333, 0.001));
    expect(s.passed, true);
    expect(GradeCalc.fmt(s.average), '2,3');
  });

  test('Uni: 4,0 gilt als bestanden, schlechter als 4,0 nicht', () {
    final passed = GradeCalc.summarize(
      [subj('a', grade: 4.0, credits: 5)],
      GradingSystem.uni,
    );
    expect(passed.passed, true);
    final failed = GradeCalc.summarize(
      [subj('a', grade: 5.0, credits: 5)],
      GradingSystem.uni,
    );
    expect(failed.passed, false);
  });

  test('Uni ohne ECTS fällt auf einfachen Mittelwert zurück', () {
    final s = GradeCalc.summarize(
      [subj('a', grade: 2.0), subj('b', grade: 4.0)],
      GradingSystem.uni,
    );
    expect(s.totalCredits, 0);
    expect(s.average, 3.0);
  });

  // --- Zeugnisnote pro Fach (gewichtete Noten, bayerische 2:1-Regel) --------

  test('Bayern 2:1: 2·Ø Schulaufgaben + 1·Ø mündlich, geteilt durch 3', () {
    // Schulaufgaben Ø(13,11)=12 (Gewicht 2), mündlich 9 (Gewicht 1)
    // -> (2*12 + 1*9)/3 = 33/3 = 11,0
    final s = subj('Mathe', grades: [
      g(GradeKind.schulaufgabe, 13),
      g(GradeKind.schulaufgabe, 11),
      g(GradeKind.muendlich, 9),
    ]);
    expect(s.finalGrade, 11.0);
  });

  test('Ohne Schulaufgabe: Durchschnitt der vorhandenen Arten (je Gewicht 1)',
      () {
    // Exen Ø(10,8)=9, mündlich 12 -> (9 + 12)/2 = 10,5
    final s = subj('Sport', grades: [
      g(GradeKind.ex, 10),
      g(GradeKind.ex, 8),
      g(GradeKind.muendlich, 12),
    ]);
    expect(s.finalGrade, 10.5);
  });

  test('Eigenes Gewicht wird berücksichtigt', () {
    // Schulaufgabe 10 (Gewicht 3), mündlich 6 (Gewicht 1)
    // -> (3*10 + 1*6)/4 = 36/4 = 9,0
    final s = subj(
      'Deutsch',
      grades: [g(GradeKind.schulaufgabe, 10), g(GradeKind.muendlich, 6)],
      weights: {GradeKind.schulaufgabe: 3, GradeKind.muendlich: 1},
    );
    expect(s.finalGrade, 9.0);
  });

  test('Schul-Durchschnitt mittelt die Fach-Zeugnisnoten', () {
    // Fach A Zeugnisnote 11,0 ; Fach B nur eine Note 8 -> 8,0 ; Ø = 9,5
    final a = subj('A', grades: [
      g(GradeKind.schulaufgabe, 13),
      g(GradeKind.schulaufgabe, 11),
      g(GradeKind.muendlich, 9),
    ]);
    final b = subj('B', grades: [g(GradeKind.muendlich, 8)]);
    final s = GradeCalc.summarize([a, b], GradingSystem.punkte);
    expect(s.average, 9.5);
    expect(s.gradedCount, 2);
  });

  test('Migration: altes grade-Feld wird als eine Note übernommen', () {
    final s = Subject.fromMap({
      'id': 'x',
      'name': 'Alt',
      'plantId': 'p01',
      'grade': 12.0, // altes Einzelfeld, keine grades-Liste
    });
    expect(s.grades.length, 1);
    expect(s.grades.first.kind, GradeKind.muendlich);
    expect(s.finalGrade, 12.0);
  });

  test('Runde durch toMap/fromMap erhält Noten & Gewichte', () {
    final original = subj(
      'Bio',
      grades: [g(GradeKind.schulaufgabe, 14), g(GradeKind.ex, 10)],
      weights: {GradeKind.schulaufgabe: 2, GradeKind.ex: 1},
    );
    final restored = Subject.fromMap(original.toMap());
    expect(restored.grades.length, 2);
    expect(restored.weightOf(GradeKind.schulaufgabe), 2);
    expect(restored.finalGrade, original.finalGrade);
  });
}
