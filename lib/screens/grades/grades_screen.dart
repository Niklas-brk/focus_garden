import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../models/edu_profile.dart';
import '../../models/plant_catalog.dart';
import '../../models/subject.dart';
import '../../state/settings_provider.dart';
import '../../state/subject_provider.dart';
import '../../utils/grade_calc.dart';
import '../../widgets/plant_sprite.dart';
import 'subject_edit_screen.dart';

/// Noten-Tab: Bildungsprofil oben, Fächer/Module in der Mitte, Durchschnitt
/// unten. Alles rein lokal (offline).
class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  late final TextEditingController _studiengangController;

  @override
  void initState() {
    super.initState();
    _studiengangController = TextEditingController(
      text: context.read<SettingsProvider>().studiengang,
    );
  }

  @override
  void dispose() {
    _studiengangController.dispose();
    super.dispose();
  }

  void _openEditor([Subject? subject]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SubjectEditScreen(subject: subject)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final subjectProvider = context.watch<SubjectProvider>();
    final system = settings.gradingSystem;
    final subjects = subjectProvider.subjects;
    final isUni = system == GradingSystem.uni;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _ProfileCard(
          settings: settings,
          studiengangController: _studiengangController,
        ),
        const SizedBox(height: 20),

        // --- Fächer/Module ------------------------------------------------
        Row(
          children: [
            Expanded(
              child: Text(
                isUni ? S.subjectsUni : S.subjectsSchool,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(isUni ? S.subjectAddUni : S.subjectAddSchool),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (subjects.isEmpty)
          _EmptySubjects(isUni: isUni)
        else
          ...subjects.map(
            (s) => _SubjectTile(
              subject: s,
              system: system,
              onTap: () => _openEditor(s),
            ),
          ),

        const SizedBox(height: 20),
        _AverageCard(subjects: subjects, system: system),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Profil
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  final SettingsProvider settings;
  final TextEditingController studiengangController;

  const _ProfileCard({
    required this.settings,
    required this.studiengangController,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isStudent = settings.eduKind == EduKind.studentin;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(S.eduRoleLabel,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SegmentedButton<EduKind>(
            segments: const [
              ButtonSegment(
                value: EduKind.schuelerin,
                label: Text(S.eduSchueler),
                icon: Icon(Icons.backpack_outlined),
              ),
              ButtonSegment(
                value: EduKind.studentin,
                label: Text(S.eduStudent),
                icon: Icon(Icons.school_outlined),
              ),
            ],
            selected: {settings.eduKind},
            onSelectionChanged: (sel) => settings.eduKind = sel.first,
          ),
          const SizedBox(height: 16),

          if (isStudent) ...[
            const Text(S.studiengangLabel,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: studiengangController,
              textInputAction: TextInputAction.done,
              onChanged: (v) => settings.studiengang = v,
              decoration: InputDecoration(
                hintText: S.studiengangHint,
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                prefixIcon: const Icon(Icons.menu_book_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ] else ...[
            const Text(S.schoolTypeLabel,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final t in SchoolType.values)
                  ChoiceChip(
                    label: Text(_schoolLabel(t)),
                    selected: settings.schoolType == t,
                    onSelected: (_) => settings.schoolType = t,
                  ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: scheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _gradingHint(settings.gradingSystem),
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _schoolLabel(SchoolType t) {
    switch (t) {
      case SchoolType.gymnasium:
        return S.schoolGymnasium;
      case SchoolType.realschule:
        return S.schoolRealschule;
      case SchoolType.hauptschule:
        return S.schoolHauptschule;
      case SchoolType.gesamtschule:
        return S.schoolGesamtschule;
    }
  }

  static String _gradingHint(GradingSystem system) {
    switch (system) {
      case GradingSystem.punkte:
        return S.gradingHintPunkte;
      case GradingSystem.noten:
        return S.gradingHintNoten;
      case GradingSystem.uni:
        return S.gradingHintUni;
    }
  }
}

// ---------------------------------------------------------------------------
// Fach-Kachel
// ---------------------------------------------------------------------------

class _SubjectTile extends StatelessWidget {
  final Subject subject;
  final GradingSystem system;
  final VoidCallback onTap;

  const _SubjectTile({
    required this.subject,
    required this.system,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final plant = PlantCatalog.byId(subject.plantId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                PlantSprite(plant: plant, stage: 4, size: 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subject.name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      if (system == GradingSystem.uni && subject.credits != null)
                        Text('${subject.credits} ${S.creditsShort}',
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    scheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                _GradePill(subject: subject, system: system),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: scheme.onSurface.withValues(alpha: 0.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradePill extends StatelessWidget {
  final Subject subject;
  final GradingSystem system;
  const _GradePill({required this.subject, required this.system});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasGrade = subject.hasGrade;
    final bg = hasGrade
        ? scheme.primary.withValues(alpha: 0.15)
        : scheme.onSurface.withValues(alpha: 0.08);
    final fg =
        hasGrade ? scheme.primary : scheme.onSurface.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        hasGrade ? gradeText(system, subject.finalGrade!) : S.subjectNoGrade,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

/// Formatiert einen einzelnen Notenwert für die Anzeige: Punkte ganzzahlig,
/// Noten mit einer Nachkommastelle.
String gradeText(GradingSystem system, double grade) {
  if (system == GradingSystem.punkte) {
    return '${grade.round()} ${S.unitPoints}';
  }
  return GradeCalc.fmt(grade);
}

// ---------------------------------------------------------------------------
// Durchschnitt
// ---------------------------------------------------------------------------

class _AverageCard extends StatelessWidget {
  final List<Subject> subjects;
  final GradingSystem system;

  const _AverageCard({required this.subjects, required this.system});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final summary = GradeCalc.summarize(subjects, system);

    if (!summary.hasData) {
      return _Card(
        child: Row(
          children: [
            Icon(Icons.calculate_outlined,
                color: scheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                S.averageEmpty,
                style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      );
    }

    final unit = system == GradingSystem.punkte ? S.unitPoints : S.unitGrade;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.averageLabel,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface.withValues(alpha: 0.7))),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                GradeCalc.fmt(summary.average),
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: scheme.primary),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(unit,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface.withValues(alpha: 0.7))),
              ),
            ],
          ),
          if (system == GradingSystem.uni) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.stars_rounded,
                  text: '${S.creditsSumLabel}: ${summary.totalCredits}',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: summary.passed == true
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  text: summary.passed == true ? S.uniPassed : S.uniNotPassed,
                  color: summary.passed == true ? scheme.primary : scheme.error,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _InfoChip({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.onSurface.withValues(alpha: 0.7);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: c),
          const SizedBox(width: 5),
          Text(text,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: c)),
        ],
      ),
    );
  }
}

class _EmptySubjects extends StatelessWidget {
  final bool isUni;
  const _EmptySubjects({required this.isUni});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            isUni ? S.subjectsEmptyUni : S.subjectsEmptySchool,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
          ),
        ),
      ),
    );
  }
}

/// Einheitliche Karten-Hülle (weiche Ecken, Flächenfarbe) für den Noten-Tab.
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
