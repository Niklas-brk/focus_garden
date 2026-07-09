import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_strings.dart';
import '../models/subject.dart';
import '../utils/study_plan.dart';

/// Exportiert Lernplan + Prüfungstermine als Kalender-Datei (.ics).
///
/// Bewusst OHNE Kalender-Berechtigung: Die App erzeugt eine Standard-Datei
/// und teilt sie – der Nutzer öffnet sie mit Google Kalender & Co. und die
/// Termine werden übernommen. So bleibt die App 100 % offline und braucht
/// kein einziges neues Recht.
class CalendarExport {
  /// Baut den ICS-Inhalt: je Lerntag ein 1-Stunden-Termin zur besten Lernzeit
  /// des empfohlenen Fachs, je Prüfung ein Ganztages-Termin.
  /// Öffentlich und rein (kein IO), damit Tests das Format prüfen können.
  static String buildIcs(List<Subject> subjects, DateTime from,
      {int days = 14}) {
    final buffer = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//Focus Garden//Lernplan//DE');

    // Lern-Sessions aus dem Plan.
    final plan = StudyPlan.build(subjects, from, days: days);
    for (final day in plan) {
      final top = day.top;
      if (top == null) continue;
      final hour = kLearnTimeHour[top.subject.learnTime]!;
      final start =
          DateTime(day.date.year, day.date.month, day.date.day, hour);
      _event(
        buffer,
        uid: 'fg-lernen-${_stampDate(day.date)}',
        summary:
            '📚 Lernen: ${top.subject.name} (${S.examKind(top.exam.kind)} ${S.shortDate(top.exam.date)})',
        start: start,
        end: start.add(const Duration(hours: 1)),
      );
    }

    // Prüfungen als Ganztages-Termine.
    for (final subject in subjects) {
      for (final exam in subject.exams) {
        if (exam.isPast(from)) continue;
        buffer
          ..writeln('BEGIN:VEVENT')
          ..writeln('UID:fg-exam-${exam.id}')
          ..writeln('DTSTAMP:${_stamp(from)}')
          ..writeln('DTSTART;VALUE=DATE:${_stampDate(exam.date)}')
          ..writeln(
              'SUMMARY:📝 ${S.examKind(exam.kind)} ${subject.name}')
          ..writeln('END:VEVENT');
      }
    }

    buffer.writeln('END:VCALENDAR');
    // ICS verlangt CRLF-Zeilenenden (writeln schreibt nur \n).
    return buffer.toString().replaceAll('\n', '\r\n');
  }

  static void _event(
    StringBuffer buffer, {
    required String uid,
    required String summary,
    required DateTime start,
    required DateTime end,
  }) {
    buffer
      ..writeln('BEGIN:VEVENT')
      ..writeln('UID:$uid')
      ..writeln('DTSTAMP:${_stamp(DateTime.now())}')
      ..writeln('DTSTART:${_stamp(start)}')
      ..writeln('DTEND:${_stamp(end)}')
      ..writeln('SUMMARY:$summary')
      ..writeln('END:VEVENT');
  }

  /// Lokale („floating") Zeit im ICS-Format: 20260715T180000.
  static String _stamp(DateTime d) =>
      '${_stampDate(d)}T${_two(d.hour)}${_two(d.minute)}00';

  static String _stampDate(DateTime d) =>
      '${d.year}${_two(d.month)}${_two(d.day)}';

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// Schreibt die Datei und öffnet den Teilen-Dialog.
  static Future<void> share(List<Subject> subjects) async {
    final ics = buildIcs(subjects, DateTime.now());
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/lernplan.ics');
    await file.writeAsString(ics);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/calendar')],
      text: S.planExportText,
    );
  }
}
