import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../state/session_provider.dart';
import '../state/settings_provider.dart';
import '../state/subject_provider.dart';
import '../widgets/exam_feedback_dialog.dart';
import 'focus/focus_screen.dart';
import 'garden/garden_screen.dart';
import 'grades/grades_screen.dart';
import 'settings/settings_screen.dart';
import 'stats/stats_screen.dart';

/// Grundgerüst mit Bottom-Navigation und 4 Tabs (Konzept Abschnitt 4 +
/// Noten-Tab).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _gradesTab = 3;

  late int _index;

  @override
  void initState() {
    super.initState();
    // Ohne angelegtes Fach zuerst im „Noten"-Tab starten: dort wählt man erst
    // Schüler:in/Student:in + Schulart und legt dann ein Fach an. Wer schon
    // Fächer hat, startet wie gewohnt im Fokus-Tab.
    final hasSubjects = context.read<SubjectProvider>().subjects.isNotEmpty;
    _index = hasSubjects ? 0 : _gradesTab;

    // Nach dem ersten Frame: abgelaufene Prüfungen abfragen („Wie lief es?").
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ExamFeedback.maybeAsk(context, context.read<SubjectProvider>());
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Während einer laufenden/aufgelösten Session zeigt der Fokus-Tab Vollbild.
    final phase = context.watch<SessionProvider>().phase;
    final immersive = _index == 0 && phase != FocusPhase.setup;

    // Der Garten-Tab trägt den frei wählbaren Garten-Namen als Titel.
    final gardenName = context.watch<SettingsProvider>().gardenName;
    final titles = [S.appName, gardenName, S.statsTitle, S.gradesTitle];

    return Scaffold(
      appBar: immersive
          ? null
          : AppBar(
              title: Text(titles[_index]),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_rounded),
                  tooltip: S.settingsTitle,
                  onPressed: _openSettings,
                ),
              ],
            ),
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            // Der Fokus-Leerzustand schickt zum „Noten"-Tab (Profil zuerst).
            FocusScreen(
              onOpenGrades: () => setState(() => _index = _gradesTab),
            ),
            const GardenScreen(),
            const StatsScreen(),
            const GradesScreen(),
          ],
        ),
      ),
      bottomNavigationBar: immersive
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.timer_outlined),
                  selectedIcon: Icon(Icons.timer_rounded),
                  label: S.tabFocus,
                ),
                NavigationDestination(
                  icon: Icon(Icons.local_florist_outlined),
                  selectedIcon: Icon(Icons.local_florist_rounded),
                  label: S.tabGarden,
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart_rounded),
                  label: S.tabStats,
                ),
                NavigationDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school_rounded),
                  label: S.tabGrades,
                ),
              ],
            ),
    );
  }
}
