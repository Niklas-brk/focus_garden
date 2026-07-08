import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';
import 'services/blocker_service.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';
import 'services/sound_service.dart';
import 'services/storage_service.dart';
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

  // Werbe-SDK starten (Konzept Abschnitt 7, nur Banner im Statistik-Tab).
  await MobileAds.instance.initialize();

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
