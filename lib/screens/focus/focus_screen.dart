import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../models/edu_profile.dart';
import '../../state/history_provider.dart';
import '../../state/session_provider.dart';
import '../../state/settings_provider.dart';
import '../../state/subject_provider.dart';
import '../../utils/break_advisor.dart';
import '../../utils/study_plan.dart';
import '../../widgets/break_timer_card.dart';
import '../../widgets/confetti_overlay.dart';
import '../../widgets/duration_selector.dart';
import '../../widgets/plant_sprite.dart';
import '../../widgets/study_tip_card.dart';
import '../../widgets/subject_picker.dart';
import 'active_session_screen.dart';

/// Fokus-Tab. Zeigt je nach Phase Auswahl, laufende Session oder Ergebnis.
class FocusScreen extends StatelessWidget {
  /// Wechselt zum „Noten"-Tab (dort Profil wählen + Fach anlegen).
  final VoidCallback onOpenGrades;

  const FocusScreen({super.key, required this.onOpenGrades});

  @override
  Widget build(BuildContext context) {
    final phase = context.watch<SessionProvider>().phase;
    switch (phase) {
      case FocusPhase.setup:
        return _FocusSetup(onOpenGrades: onOpenGrades);
      case FocusPhase.running:
        return const ActiveSessionScreen();
      case FocusPhase.bloomed:
        return const _ResultView(kind: _ResultKind.bloomed);
      case FocusPhase.grown:
        return const _ResultView(kind: _ResultKind.grown);
      case FocusPhase.wilted:
        return const _ResultView(kind: _ResultKind.wilted);
    }
  }
}

class _FocusSetup extends StatelessWidget {
  final VoidCallback onOpenGrades;
  const _FocusSetup({required this.onOpenGrades});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final subjects = context.watch<SubjectProvider>().subjects;
    final isUni =
        context.watch<SettingsProvider>().gradingSystem == GradingSystem.uni;

    // Fokus läuft immer über ein Fach: ohne Fach erst zum Anlegen einladen.
    if (subjects.isEmpty) {
      return _NoSubject(isUni: isUni, onOpenGrades: onOpenGrades);
    }

    final selected = session.selectedSubject ?? subjects.first;

    // Lernplan-Tipp: das heute wichtigste Fach (falls Prüfungen anstehen).
    final today = StudyPlan.build(subjects, DateTime.now(), days: 1).first.top;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (today != null)
            Center(
              child: ActionChip(
                avatar: const Text('📚'),
                label: Text(
                  '${S.planSuggestionPrefix} ${today.subject.name}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: () => session.selectSubject(today.subject),
              ),
            ),
          _SectionLabel(S.chooseSubject),
          SubjectCarousel(
            subjects: subjects,
            selectedId: selected.id,
            onSelected: session.selectSubject,
          ),
          const SizedBox(height: 20),
          _SectionLabel(S.chooseDuration),
          const SizedBox(height: 8),
          DurationSelector(
            selected: session.selectedMinutes,
            onSelected: session.selectMinutes,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: session.start,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded),
                  const SizedBox(width: 8),
                  Text(S.start),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Fachspezifischer Lerntipp zum gewählten Fach (rotiert täglich).
          StudyTipCard(subjectName: selected.name),
        ],
      ),
    );
  }
}

/// Leerzustand: es gibt noch kein Fach/Modul. Führt zum „Noten"-Tab, wo man
/// erst Profil + Schulart wählt und dann ein Fach anlegt.
class _NoSubject extends StatelessWidget {
  final bool isUni;
  final VoidCallback onOpenGrades;
  const _NoSubject({required this.isUni, required this.onOpenGrades});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined,
                size: 64, color: scheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              isUni ? S.focusNoSubjectTitleUni : S.focusNoSubjectTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              isUni ? S.focusNoSubjectBodyUni : S.focusNoSubjectBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onOpenGrades,
              icon: const Icon(Icons.school_rounded),
              label: Text(
                isUni ? S.focusNoSubjectButtonUni : S.focusNoSubjectButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

enum _ResultKind { bloomed, grown, wilted }

class _ResultView extends StatelessWidget {
  final _ResultKind kind;
  const _ResultView({required this.kind});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final scheme = Theme.of(context).colorScheme;
    final plant = session.selectedPlant;
    final bloomed = kind == _ResultKind.bloomed;
    final grown = kind == _ResultKind.grown;
    final success = bloomed || grown;

    final title = switch (kind) {
      _ResultKind.bloomed => S.bloomedTitle,
      _ResultKind.grown => S.grownTitle,
      _ResultKind.wilted => S.wiltedTitle,
    };
    final body = switch (kind) {
      _ResultKind.bloomed => S.bloomedBody,
      _ResultKind.grown => S.grownBody,
      _ResultKind.wilted => S.wiltedBody,
    };

    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.7, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: PlantSprite(
                plant: plant,
                stage: bloomed ? 4 : session.currentStage,
                wilted: kind == _ResultKind.wilted,
                size: 200,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (success) ...[
              const SizedBox(height: 16),
              Text(
                '${session.selectedMinutes} ${S.focusMinutes}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ],
            if (grown) ...[
              const SizedBox(height: 20),
              _BloomProgress(
                fraction: session.bloomFraction,
                remaining: session.bloomRemainingMinutes,
              ),
            ],
            if (success) ...[
              const SizedBox(height: 20),
              // Pausen-Empfehlung: Länge hängt von der Session-Dauer ab,
              // nach der 4. Session des Tages gibt es eine lange Pause.
              BreakTimerCard(
                advice: BreakAdvisor.recommend(
                  sessionMinutes: session.selectedMinutes,
                  todaysCompletedSessions:
                      context.watch<HistoryProvider>().stats.todaySessions,
                ),
                notifications: session.notifications,
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: FilledButton(
                onPressed: session.reset,
                child: Text(
                  bloomed
                      ? S.backToGarden
                      : (grown ? S.keepGoing : S.tryAgain),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!bloomed) return content;

    // Erfolgs-Moment: Konfetti nur bei voller Blüte. Die Animation läuft dank
    // eigenem State genau einmal beim Einblenden des Erblüht-Screens.
    return Stack(
      children: [
        Positioned.fill(child: content),
        const Positioned.fill(child: ConfettiOverlay()),
      ],
    );
  }
}

/// Fortschrittsbalken Richtung volle Blüte (im „gewachsen"-Ergebnis).
class _BloomProgress extends StatelessWidget {
  final double fraction;
  final int remaining;
  const _BloomProgress({required this.fraction, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          width: 240,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 10,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(scheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.bloomRemaining.replaceFirst('{n}', '$remaining'),
          style: TextStyle(
            fontSize: 13,
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
