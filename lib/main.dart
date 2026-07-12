import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'services/blocker_service.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';
import 'services/sound_service.dart';
import 'services/storage_service.dart';
import 'services/study_plan_service.dart';
import 'state/history_provider.dart';
import 'state/session_provider.dart';
import 'state/settings_provider.dart';
import 'state/subject_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lokale Persistenz (Hive) und Benachrichtigungen initialisieren.
  final storage = StorageService();
  await storage.init();

  final notifications = NotificationService();
  await notifications.init();

  final sound = SoundService();
  final blocker = BlockerService();

  // Provider aufbauen (bewusst manuell, da sie sich gegenseitig kennen).
  final settings = SettingsProvider(storage);
  final history = HistoryProvider(storage);
  final subjects = SubjectProvider(storage);
  final session = SessionProvider(
    storage: storage,
    notifications: notifications,
    sound: sound,
    settings: settings,
    history: history,
    subjects: subjects,
    blocker: blocker,
  );

  // Der „Notfall-Abbruch"-Knopf im nativen Overlay endet die Session.
  blocker.setAbortHandler(session.cancelSession);

  // Lernplan: Erinnerungen beim Start planen und bei jeder Fach-Änderung
  // (neue Prüfung, Feedback, gelöschtes Fach …) neu berechnen.
  final studyPlan = StudyPlanService(notifications);
  Future<void> replan() => studyPlan.reschedule(
        subjects.subjects,
        enabled: settings.studyRemindersOn,
      );
  subjects.addListener(() => unawaited(replan()));
  var remindersWereOn = settings.studyRemindersOn;
  settings.addListener(() {
    // Nur neu planen, wenn wirklich der Erinnerungs-Schalter umgelegt wurde.
    if (settings.studyRemindersOn != remindersWereOn) {
      remindersWereOn = settings.studyRemindersOn;
      unawaited(replan());
    }
  });
  unawaited(replan());

  // Kauf-Dienst: schaltet bei erfolgreichem Kauf/Wiederherstellung Premium frei.
  final purchases = PurchaseService(onPremiumUnlocked: settings.unlockPremium);
  unawaited(purchases.init()); // blockiert den App-Start nicht

  runApp(
    FocusGardenApp(
      settings: settings,
      history: history,
      subjects: subjects,
      session: session,
      purchases: purchases,
      blocker: blocker,
    ),
  );
}
