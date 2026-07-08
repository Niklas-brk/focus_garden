import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_strings.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/blocker_service.dart';
import 'services/purchase_service.dart';
import 'state/history_provider.dart';
import 'state/session_provider.dart';
import 'state/settings_provider.dart';
import 'state/subject_provider.dart';
import 'theme/app_theme.dart';

/// App-Wurzel. Beobachtet den App-Lifecycle und leitet ihn an den
/// SessionProvider weiter (Grundlage der Verwelk-Mechanik, Abschnitt 8).
class FocusGardenApp extends StatefulWidget {
  final SettingsProvider settings;
  final HistoryProvider history;
  final SubjectProvider subjects;
  final SessionProvider session;
  final PurchaseService purchases;
  final BlockerService blocker;

  const FocusGardenApp({
    super.key,
    required this.settings,
    required this.history,
    required this.subjects,
    required this.session,
    required this.purchases,
    required this.blocker,
  });

  @override
  State<FocusGardenApp> createState() => _FocusGardenAppState();
}

class _FocusGardenAppState extends State<FocusGardenApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      widget.session.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      widget.session.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.settings),
        ChangeNotifierProvider.value(value: widget.history),
        ChangeNotifierProvider.value(value: widget.subjects),
        ChangeNotifierProvider.value(value: widget.session),
        ChangeNotifierProvider.value(value: widget.purchases),
        Provider<BlockerService>.value(value: widget.blocker),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: S.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          home: settings.onboardingDone
              ? const HomeShell()
              : const OnboardingScreen(),
        ),
      ),
    );
  }
}
