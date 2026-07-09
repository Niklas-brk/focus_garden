import '../l10n/app_strings.dart';
import '../models/subject.dart';
import '../utils/study_plan.dart';
import 'notification_service.dart';

/// Verbindet den Lernplan mit den Benachrichtigungen: plant für die nächsten
/// 7 Tage je eine Lern-Erinnerung (zur besten Lernzeit des wichtigsten Fachs)
/// und am Prüfungstag morgens eine „Viel Erfolg"-Meldung.
///
/// Wird bei jedem App-Start und nach jeder Fach-Änderung neu aufgerufen –
/// so bleibt der Plan aktuell, ganz ohne Hintergrund-Dienst.
class StudyPlanService {
  final NotificationService notifications;

  StudyPlanService(this.notifications);

  static const int planDays = 7;
  static const int examDayHour = 7; // „Viel Erfolg" am Prüfungstag um 7 Uhr

  Future<void> reschedule(
    List<Subject> subjects, {
    required bool enabled,
  }) async {
    if (!enabled) {
      await notifications.cancelStudyReminders();
      return;
    }

    final now = DateTime.now();
    final plan = StudyPlan.build(subjects, now, days: planDays);
    final entries = <(DateTime, String, String)>[];

    for (final day in plan) {
      // Prüfungstag: morgens Daumen drücken statt Lern-Erinnerung.
      if (day.examsToday.isNotEmpty) {
        final rec = day.examsToday.first;
        final when = DateTime(
            day.date.year, day.date.month, day.date.day, examDayHour);
        if (when.isAfter(now)) {
          entries.add((
            when,
            S.notifExamTodayTitle
                .replaceFirst('{art}', S.examKind(rec.exam.kind))
                .replaceFirst('{fach}', rec.subject.name),
            S.notifExamTodayBody,
          ));
        }
      }

      final top = day.top;
      if (top == null) continue;
      final hour = kLearnTimeHour[top.subject.learnTime]!;
      final when = DateTime(day.date.year, day.date.month, day.date.day, hour);
      if (!when.isAfter(now)) continue; // Zeitpunkt heute schon vorbei

      final left = top.daysLeft(day.date);
      final wann = left == 1
          ? S.planTomorrow.toLowerCase()
          : S.planDaysLeft.replaceFirst('{n}', '$left');
      entries.add((
        when,
        S.notifStudyTitle,
        S.notifStudyBody
            .replaceFirst('{fach}', top.subject.name)
            .replaceFirst('{art}', S.examKind(top.exam.kind))
            .replaceFirst('{wann}', wann),
      ));
    }

    await notifications.scheduleStudyReminders(entries);
  }
}
