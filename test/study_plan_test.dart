import 'package:flutter_test/flutter_test.dart';

import 'package:focus_garden/models/exam.dart';
import 'package:focus_garden/models/subject.dart';
import 'package:focus_garden/services/calendar_export.dart';
import 'package:focus_garden/utils/break_advisor.dart';
import 'package:focus_garden/utils/study_plan.dart';

/// Fester „Heute"-Anker für stabile Tests.
final today = DateTime(2026, 7, 9);

Subject subj(
  String name, {
  List<Exam>? exams,
  LearnTime learnTime = LearnTime.abends,
}) =>
    Subject(
      id: name,
      name: name,
      plantId: 'p01',
      exams: exams,
      learnTime: learnTime,
    );

Exam exam(ExamKind kind, DateTime date,
        {int? rating, bool skipped = false}) =>
    Exam(
      id: 'e_${kind.name}_${date.day}',
      date: date,
      kind: kind,
      rating: rating,
      ratingSkipped: skipped,
    );

void main() {
  // ---- Pausen-Empfehlung ----------------------------------------------------

  test('Pause: ~1 Minute je 5 Minuten Fokus, begrenzt auf 5-20', () {
    expect(
        BreakAdvisor.recommend(sessionMinutes: 25, todaysCompletedSessions: 1)
            .minutes,
        5);
    expect(
        BreakAdvisor.recommend(sessionMinutes: 45, todaysCompletedSessions: 1)
            .minutes,
        9);
    expect(
        BreakAdvisor.recommend(sessionMinutes: 90, todaysCompletedSessions: 1)
            .minutes,
        18);
    // Untergrenze 5, Obergrenze 20.
    expect(
        BreakAdvisor.recommend(sessionMinutes: 10, todaysCompletedSessions: 1)
            .minutes,
        5);
    expect(
        BreakAdvisor.recommend(sessionMinutes: 180, todaysCompletedSessions: 1)
            .minutes,
        20);
  });

  test('Pause: nach jeder 4. Session des Tages eine lange Pause (15-30)', () {
    final long =
        BreakAdvisor.recommend(sessionMinutes: 25, todaysCompletedSessions: 4);
    expect(long.isLong, true);
    expect(long.minutes, 15); // 2×5, Untergrenze 15

    final longMax =
        BreakAdvisor.recommend(sessionMinutes: 180, todaysCompletedSessions: 8);
    expect(longMax.minutes, 30); // Obergrenze 30

    final normal =
        BreakAdvisor.recommend(sessionMinutes: 25, todaysCompletedSessions: 5);
    expect(normal.isLong, false);
  });

  // ---- Lernplan: Priorität ----------------------------------------------------

  test('Schulaufgabe wiegt schwerer als Ex bei gleichem Abstand', () {
    final sa = subj('Mathe',
        exams: [exam(ExamKind.schulaufgabe, today.add(const Duration(days: 3)))]);
    final ex = subj('Bio',
        exams: [exam(ExamKind.ex, today.add(const Duration(days: 3)))]);
    expect(StudyPlan.scoreFor(sa, today),
        greaterThan(StudyPlan.scoreFor(ex, today)));
  });

  test('außerhalb des Vorlaufs zählt eine Prüfung nicht', () {
    // Ex hat 5 Tage Vorlauf -> in 6 Tagen noch kein Thema.
    final s = subj('Bio',
        exams: [exam(ExamKind.ex, today.add(const Duration(days: 6)))]);
    expect(StudyPlan.scoreFor(s, today), 0);
    // Schulaufgabe hat 14 Tage Vorlauf -> in 14 Tagen schon dabei.
    final s2 = subj('Mathe',
        exams: [
          exam(ExamKind.schulaufgabe, today.add(const Duration(days: 14)))
        ]);
    expect(StudyPlan.scoreFor(s2, today), greaterThan(0));
  });

  test('je näher die Prüfung, desto dringender', () {
    final s = subj('Mathe',
        exams: [
          exam(ExamKind.schulaufgabe, today.add(const Duration(days: 10)))
        ]);
    final early = StudyPlan.scoreFor(s, today);
    final later = StudyPlan.scoreFor(s, today.add(const Duration(days: 8)));
    expect(later, greaterThan(early));
  });

  test('schlechtes Prüfungs-Feedback erhöht die Priorität, gutes senkt sie',
      () {
    expect(StudyPlan.ratingFactor(null), 1);
    expect(StudyPlan.ratingFactor(2), greaterThan(1));
    expect(StudyPlan.ratingFactor(9), lessThan(1));
    // Begrenzung gegen Extreme.
    expect(StudyPlan.ratingFactor(1), lessThanOrEqualTo(1.6));
    expect(StudyPlan.ratingFactor(10), greaterThanOrEqualTo(0.5));

    final past = exam(ExamKind.ex, today.subtract(const Duration(days: 10)));
    final coming = exam(ExamKind.ex, today.add(const Duration(days: 3)));
    final badFeedback = subj('Mathe',
        exams: [past.copyWith(rating: 2), coming]);
    final goodFeedback = subj('Bio',
        exams: [past.copyWith(rating: 9), coming]);
    expect(StudyPlan.scoreFor(badFeedback, today),
        greaterThan(StudyPlan.scoreFor(goodFeedback, today)));
  });

  test('Klausur (Uni) zählt wie eine Schulaufgabe: 14 Tage Vorlauf, Gewicht 3',
      () {
    expect(kExamLeadDays[ExamKind.klausur], 14);
    expect(kExamWeights[ExamKind.klausur], kExamWeights[ExamKind.schulaufgabe]);
    // In 14 Tagen schon im Plan, in 15 noch nicht.
    final inLead = subj('Reli',
        exams: [exam(ExamKind.klausur, today.add(const Duration(days: 14)))]);
    expect(StudyPlan.scoreFor(inLead, today), greaterThan(0));
    final tooFar = subj('Deutsch',
        exams: [exam(ExamKind.klausur, today.add(const Duration(days: 15)))]);
    expect(StudyPlan.scoreFor(tooFar, today), 0);
  });

  test('build: Prüfungstag landet in examsToday, sonst in Empfehlungen', () {
    final s = subj('Mathe',
        exams: [exam(ExamKind.schulaufgabe, today.add(const Duration(days: 2)))]);
    final plan = StudyPlan.build([s], today, days: 3);

    expect(plan[0].top?.subject.name, 'Mathe'); // heute: lernen
    expect(plan[0].examsToday, isEmpty);
    expect(plan[2].examsToday.length, 1); // Prüfungstag
    expect(plan[2].recommendations, isEmpty);
  });

  test('build: dringendstes Fach steht vorn', () {
    final mathe = subj('Mathe',
        exams: [exam(ExamKind.schulaufgabe, today.add(const Duration(days: 2)))]);
    final bio = subj('Bio',
        exams: [exam(ExamKind.ex, today.add(const Duration(days: 4)))]);
    final day = StudyPlan.build([bio, mathe], today, days: 1).first;
    expect(day.recommendations.length, 2);
    expect(day.top?.subject.name, 'Mathe');
  });

  // ---- Prüfungs-Feedback -------------------------------------------------------

  test('pendingFeedback findet nur unbewertete, abgelaufene Prüfungen', () {
    final s = subj('Mathe', exams: [
      exam(ExamKind.ex, today.subtract(const Duration(days: 1))), // offen
      exam(ExamKind.ex, today.subtract(const Duration(days: 5)), rating: 7),
      exam(ExamKind.ex, today.subtract(const Duration(days: 3)), skipped: true),
      exam(ExamKind.ex, today.add(const Duration(days: 1))), // Zukunft
      exam(ExamKind.ex, today), // heute = noch nicht vorbei
    ]);
    final pending = StudyPlan.pendingFeedback([s], today);
    expect(pending.length, 1);
    expect(pending.first.$2.date, today.subtract(const Duration(days: 1)));
  });

  // ---- Persistenz / Migration ---------------------------------------------------

  test('Subject mit Lernzeit + Prüfungen übersteht die Map-Runde', () {
    final s = subj('Mathe',
        learnTime: LearnTime.morgens,
        exams: [
          exam(ExamKind.kurzarbeit, DateTime(2026, 7, 20), rating: 6),
        ]);
    final restored = Subject.fromMap(s.toMap());
    expect(restored.learnTime, LearnTime.morgens);
    expect(restored.exams.length, 1);
    expect(restored.exams.first.kind, ExamKind.kurzarbeit);
    expect(restored.exams.first.rating, 6);
    expect(restored.exams.first.date, DateTime(2026, 7, 20));
  });

  test('Migration: alte Fächer ohne neue Felder bekommen Standardwerte', () {
    final old = {
      'id': 'alt',
      'name': 'Alt',
      'plantId': 'p01',
    };
    final s = Subject.fromMap(old);
    expect(s.learnTime, LearnTime.abends);
    expect(s.exams, isEmpty);
    expect(s.studienfach, isNull); // vor dem Studienfächer-Update angelegt
  });

  test('Studienfach übersteht die Map-Runde und lässt sich wieder lösen', () {
    final modul = Subject(
      id: 'm1',
      name: 'Literaturwissenschaft',
      plantId: 'p01',
      studienfach: 'Deutsch',
    );
    final restored = Subject.fromMap(modul.toMap());
    expect(restored.studienfach, 'Deutsch');

    // copyWith ohne Angabe behält das Fach, clearStudienfach entfernt es.
    expect(restored.copyWith(name: 'Neu').studienfach, 'Deutsch');
    final cleared = restored.copyWith(clearStudienfach: true);
    expect(cleared.studienfach, isNull);
    expect(Subject.fromMap(cleared.toMap()).studienfach, isNull);
  });

  // ---- Kalender-Export -----------------------------------------------------------

  test('ICS enthält Lern-Termine und Prüfungen mit CRLF-Zeilenenden', () {
    final s = subj('Mathe',
        learnTime: LearnTime.morgens,
        exams: [
          exam(ExamKind.schulaufgabe, today.add(const Duration(days: 3)))
        ]);
    final ics = CalendarExport.buildIcs([s], today);

    expect(ics, startsWith('BEGIN:VCALENDAR'));
    expect(ics, contains('SUMMARY:📝 Schulaufgabe Mathe'));
    expect(ics, contains('DTSTART;VALUE=DATE:20260712'));
    expect(ics, contains('SUMMARY:📚 Lernen: Mathe'));
    expect(ics, contains('T080000')); // morgens = 8 Uhr
    expect(ics, contains('\r\n'));
    expect(ics.trim(), endsWith('END:VCALENDAR'));
  });
}
