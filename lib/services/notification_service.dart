import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_strings.dart';

/// Lokale Benachrichtigungen (Konzept Abschnitt 8):
///  - geplante "erblüht"-Meldung zum Session-Ende
///  - sofortige Warnung, wenn die App im strengen Modus verlassen wird
///
/// Es werden ungenaue Alarme genutzt (inexactAllowWhileIdle), damit KEINE
/// Sonder-Berechtigung für exakte Alarme nötig ist.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int bloomId = 1;
  static const int warnId = 2;
  static const int breakId = 3;

  /// Lern-Erinnerungen des Lernplans belegen die IDs 100–115 (max. 2 pro Tag
  /// für 7 geplante Tage: Lern-Erinnerung + „Viel Erfolg" am Prüfungstag).
  static const int studyBaseId = 100;
  static const int studyMaxCount = 16;

  static const _channelId = 'focus_garden_channel';
  static const _channelName = 'Focus Garden';

  bool _ready = false;

  Future<void> init() async {
    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings: settings);

    // Android 13+: Benachrichtigungs-Erlaubnis anfragen.
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    _ready = true;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Fokus-Sessions und Erinnerungen',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );

  /// Plant die Session-Ende-Meldung für den Zeitpunkt [when]. Je nachdem, ob
  /// die Session die volle Blüte erreicht ([willBloom]) oder die Pflanze nur
  /// „wächst", wird die passende Meldung gewählt.
  Future<void> scheduleSessionEnd(DateTime when,
      {required bool willBloom}) async {
    if (!_ready) return;
    try {
      final target = tz.TZDateTime.from(when, tz.local);
      await _plugin.zonedSchedule(
        id: bloomId,
        scheduledDate: target,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: willBloom ? S.notifBloomTitle : S.notifGrownTitle,
        body: willBloom ? S.notifBloomBody : S.notifGrownBody,
      );
    } catch (e) {
      debugPrint('scheduleSessionEnd fehlgeschlagen: $e');
    }
  }

  /// Zeigt die "erblüht"-Meldung sofort an (Session im Vordergrund beendet).
  Future<void> showBloom() async {
    if (!_ready) return;
    try {
      await _plugin.show(
        id: bloomId,
        title: S.notifBloomTitle,
        body: S.notifBloomBody,
        notificationDetails: _details,
      );
    } catch (e) {
      debugPrint('showBloom fehlgeschlagen: $e');
    }
  }

  /// Zeigt die Warnung sofort an (App wurde verlassen, strenger Modus).
  Future<void> showWiltWarning() async {
    if (!_ready) return;
    try {
      await _plugin.show(
        id: warnId,
        title: S.notifWarnTitle,
        body: S.notifWarnBody,
        notificationDetails: _details,
      );
    } catch (e) {
      debugPrint('showWiltWarning fehlgeschlagen: $e');
    }
  }

  /// Plant die „Pause vorbei"-Meldung zum Ende der empfohlenen Pause.
  Future<void> scheduleBreakEnd(DateTime when) async {
    if (!_ready) return;
    try {
      await _plugin.zonedSchedule(
        id: breakId,
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: S.notifBreakOverTitle,
        body: S.notifBreakOverBody,
      );
    } catch (e) {
      debugPrint('scheduleBreakEnd fehlgeschlagen: $e');
    }
  }

  Future<void> cancelBreakEnd() async => _plugin.cancel(id: breakId);

  /// Plant die Lern-Erinnerungen des Lernplans neu: erst alle alten löschen,
  /// dann die übergebenen (Zeitpunkt, Titel, Text) eintragen.
  Future<void> scheduleStudyReminders(
    List<(DateTime, String, String)> entries,
  ) async {
    if (!_ready) return;
    await cancelStudyReminders();
    for (var i = 0; i < entries.length && i < studyMaxCount; i++) {
      final (time, title, body) = entries[i];
      try {
        await _plugin.zonedSchedule(
          id: studyBaseId + i,
          scheduledDate: tz.TZDateTime.from(time, tz.local),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: title,
          body: body,
        );
      } catch (e) {
        debugPrint('scheduleStudyReminders fehlgeschlagen: $e');
      }
    }
  }

  Future<void> cancelStudyReminders() async {
    for (var i = 0; i < studyMaxCount; i++) {
      await _plugin.cancel(id: studyBaseId + i);
    }
  }

  Future<void> cancelBloom() async => _plugin.cancel(id: bloomId);
  Future<void> cancelWarning() async => _plugin.cancel(id: warnId);
  Future<void> cancelAll() async => _plugin.cancelAll();
}
