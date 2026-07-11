import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../models/edu_profile.dart';
import '../../models/exam.dart';
import '../../models/grade_entry.dart';
import '../../models/plant.dart';
import '../../models/plant_catalog.dart';
import '../../models/subject.dart';
import '../../state/settings_provider.dart';
import '../../state/subject_provider.dart';
import '../../utils/grade_calc.dart';
import '../../widgets/plant_carousel.dart';
import '../premium/premium_screen.dart';

/// Legt ein Fach/Modul an oder bearbeitet es.
///
/// Schule (Punkte/Noten): mehrere Einzelnoten nach Art (Schulaufgabe, Kurzarbeit,
/// Ex, mündlich) mit einstellbarem Gewicht; die App berechnet daraus die
/// Zeugnisnote (bayerische 2:1-Regel als Standard).
///
/// Uni: eine Modulnote plus ECTS (ECTS-gewichtet im Durchschnitt).
class SubjectEditScreen extends StatefulWidget {
  /// null = neues Fach anlegen.
  final Subject? subject;

  const SubjectEditScreen({super.key, this.subject});

  @override
  State<SubjectEditScreen> createState() => _SubjectEditScreenState();
}

class _SubjectEditScreenState extends State<SubjectEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _gradeController; // nur Uni
  late final TextEditingController _creditsController;
  late String _selectedPlantId;

  // Schule: veränderbare Notenliste + Gewichte je Art.
  late List<GradeEntry> _grades;
  late Map<GradeKind, double> _weights;

  // Lernplan: beste Lernzeit + Prüfungstermine.
  late LearnTime _learnTime;
  late List<Exam> _exams;

  // Studium: gewähltes Studienfach des Moduls (null = ohne Fach).
  String? _studienfach;

  String? _nameError;
  String? _gradeError; // nur Uni

  bool get _isNew => widget.subject == null;

  @override
  void initState() {
    super.initState();
    final s = widget.subject;
    _nameController = TextEditingController(text: s?.name ?? '');
    _creditsController =
        TextEditingController(text: s?.credits?.toString() ?? '');
    _selectedPlantId = s?.plantId ?? PlantCatalog.free.first.id;
    _grades = List.of(s?.grades ?? const []);
    _weights = {...kDefaultGradeWeights, ...?s?.weights};
    _learnTime = s?.learnTime ?? LearnTime.abends;
    _exams = List.of(s?.exams ?? const []);
    _studienfach = s?.studienfach;
    _gradeController = TextEditingController(
      text: s?.finalGrade == null ? '' : _initialGradeText(s!.finalGrade!),
    );
  }

  /// Vorbelegung des Uni-Noten-Feldes (Komma statt Punkt).
  String _initialGradeText(double grade) => grade.toString().replaceAll('.', ',');

  @override
  void dispose() {
    _nameController.dispose();
    _gradeController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  void _selectPlant(Plant plant) {
    final premium = context.read<SettingsProvider>().premium;
    // Gesperrte Premium-Pflanzen bleiben unausgewählt (Tippen öffnet den Shop).
    if (plant.isPremium && !premium) return;
    setState(() => _selectedPlantId = plant.id);
  }

  double? _parseUniGrade() {
    final raw = _gradeController.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  void _save() {
    final system = context.read<SettingsProvider>().gradingSystem;
    final name = _nameController.text.trim();
    final isUni = system == GradingSystem.uni;

    setState(() {
      _nameError = name.isEmpty ? S.subjectNameRequired : null;
      _gradeError = isUni ? _validateUniGrade() : null;
    });
    if (_nameError != null || _gradeError != null) return;

    final existing = widget.subject;

    // Notenliste je nach System zusammenstellen.
    final List<GradeEntry> grades;
    if (isUni) {
      final g = _parseUniGrade();
      grades = g == null
          ? const []
          : [GradeEntry(kind: GradeKind.muendlich, value: g)];
    } else {
      grades = _grades;
    }

    final credits =
        isUni ? int.tryParse(_creditsController.text.trim()) : existing?.credits;

    final subject = Subject(
      id: existing?.id ?? 'subj_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      plantId: _selectedPlantId,
      bloomProgress: existing?.bloomProgress ?? 0,
      bloomedCount: existing?.bloomedCount ?? 0,
      grades: grades,
      weights: _weights,
      credits: credits,
      studienfach: isUni ? _studienfach : existing?.studienfach,
      learnTime: _learnTime,
      exams: _exams,
    );

    final provider = context.read<SubjectProvider>();
    if (_isNew) {
      provider.add(subject);
    } else {
      provider.update(subject);
    }
    Navigator.of(context).pop();
  }

  /// Prüft die Uni-Note. Leeres Feld ist erlaubt (Note optional).
  String? _validateUniGrade() {
    final raw = _gradeController.text.trim();
    if (raw.isEmpty) return null;
    final value = _parseUniGrade();
    if (value == null ||
        value < GradingSystem.uni.minGrade ||
        value > GradingSystem.uni.maxGrade) {
      return S.gradeInvalidUni;
    }
    return null;
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.subjectDeleteTitle),
        content: const Text(S.subjectDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(S.subjectDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.read<SubjectProvider>().remove(widget.subject!.id);
    if (mounted) Navigator.of(context).pop();
  }

  // --- Schul-Noten: hinzufügen / entfernen / Gewicht ------------------------

  Future<void> _addGrade(GradeKind kind, GradingSystem system) async {
    final value = await showDialog<double>(
      context: context,
      builder: (_) => _AddGradeDialog(system: system, kind: kind),
    );
    if (value == null) return;
    setState(() => _grades.add(GradeEntry(kind: kind, value: value)));
  }

  void _removeGrade(GradeEntry entry) {
    setState(() => _grades.remove(entry));
  }

  void _setWeight(GradeKind kind, double weight) {
    setState(() => _weights[kind] = weight);
  }

  // --- Prüfungstermine: hinzufügen ------------------------------------------

  Future<void> _addExam() async {
    final isUni =
        context.read<SettingsProvider>().gradingSystem == GradingSystem.uni;
    final exam = await showDialog<Exam>(
      context: context,
      builder: (_) => _AddExamDialog(isUni: isUni),
    );
    if (exam == null) return;
    setState(() {
      _exams
        ..add(exam)
        ..sort((a, b) => a.date.compareTo(b.date));
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final system = settings.gradingSystem;
    final isUni = system == GradingSystem.uni;

    final title = _isNew
        ? (isUni ? S.subjectNewUni : S.subjectNewSchool)
        : (isUni ? S.subjectEditUni : S.subjectEditSchool);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: S.subjectDelete,
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // --- Name --------------------------------------------------------
          _Label(S.subjectNameLabel),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: _fieldDecoration(
              scheme,
              hint: S.subjectNameHint,
              icon: Icons.edit_outlined,
              errorText: _nameError,
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 20),

          // --- Studienfach (nur Studium, wenn Fächer im Profil angelegt) ----
          if (isUni && _fachChoices(settings).isNotEmpty) ...[
            _Label(S.studienfachLabel),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text(S.studienfachNone),
                  selected: _studienfach == null,
                  onSelected: (_) => setState(() => _studienfach = null),
                ),
                for (final fach in _fachChoices(settings))
                  ChoiceChip(
                    label: Text(fach),
                    selected: _studienfach == fach,
                    onSelected: (_) => setState(() => _studienfach = fach),
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // --- Pflanze -----------------------------------------------------
          _Label(S.subjectPlantLabel),
          const SizedBox(height: 4),
          PlantCarousel(
            plants: PlantCatalog.all,
            selectedId: _selectedPlantId,
            onSelected: _selectPlant,
            premiumUnlocked: settings.premium,
            onLockedTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            ),
          ),
          const SizedBox(height: 20),

          // --- Beste Lernzeit (für Lernplan & Erinnerungen) ------------------
          _Label(S.learnTimeLabel),
          SegmentedButton<LearnTime>(
            segments: const [
              ButtonSegment(
                value: LearnTime.morgens,
                label: Text(S.learnMorgens),
                icon: Icon(Icons.wb_sunny_outlined),
              ),
              ButtonSegment(
                value: LearnTime.mittags,
                label: Text(S.learnMittags),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: LearnTime.abends,
                label: Text(S.learnAbends),
                icon: Icon(Icons.nights_stay_outlined),
              ),
            ],
            selected: {_learnTime},
            onSelectionChanged: (sel) =>
                setState(() => _learnTime = sel.first),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 6),
            child: Text(
              S.learnTimeHint,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Prüfungstermine ----------------------------------------------
          _Label(S.examsSectionLabel),
          _ExamSection(
            exams: _exams,
            onAdd: _addExam,
            onRemove: (e) => setState(() => _exams.remove(e)),
          ),
          const SizedBox(height: 20),

          // --- Noten -------------------------------------------------------
          if (isUni)
            ..._buildUniGrade(scheme)
          else
            ..._buildSchoolGrades(scheme, system),

          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Text(S.subjectSave),
            ),
          ),
        ],
      ),
    );
  }

  /// Wählbare Studienfächer: die im Profil angelegten, plus – falls dieses
  /// Modul noch einem inzwischen entfernten Fach zugeordnet ist – dieses Fach,
  /// damit die Auswahl sichtbar bleibt.
  List<String> _fachChoices(SettingsProvider settings) {
    final choices = List.of(settings.studienfaecher);
    final current = _studienfach;
    if (current != null && !choices.contains(current)) choices.add(current);
    return choices;
  }

  // --- Uni: eine Modulnote + ECTS -------------------------------------------

  List<Widget> _buildUniGrade(ColorScheme scheme) {
    return [
      _Label(S.gradeLabelUni),
      TextField(
        controller: _gradeController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        textInputAction: TextInputAction.done,
        decoration: _fieldDecoration(
          scheme,
          hint: S.gradeLabelUni,
          icon: Icons.grade_outlined,
          errorText: _gradeError,
          helper: S.gradeOptionalHint,
        ),
        onChanged: (_) {
          if (_gradeError != null) setState(() => _gradeError = null);
        },
      ),
      const SizedBox(height: 20),
      _Label(S.creditsLabel),
      TextField(
        controller: _creditsController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.done,
        decoration: _fieldDecoration(
          scheme,
          hint: S.creditsHintField,
          icon: Icons.stars_outlined,
        ),
      ),
    ];
  }

  // --- Schule: mehrere Noten je Art mit Gewicht -----------------------------

  List<Widget> _buildSchoolGrades(ColorScheme scheme, GradingSystem system) {
    final preview = Subject(
      id: '',
      name: '',
      plantId: '',
      grades: _grades,
      weights: _weights,
    ).finalGrade;

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(child: _Label(S.gradesSectionLabel)),
          _FinalGradeBadge(
            system: system,
            value: preview,
            label: S.finalGradeLabel,
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 12),
        child: Text(
          S.gradeWeightHint,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
      for (final kind in GradeKind.values)
        _KindSection(
          kind: kind,
          system: system,
          entries: _grades.where((g) => g.kind == kind).toList(),
          weight: _weights[kind] ?? kDefaultGradeWeights[kind]!,
          onAdd: () => _addGrade(kind, system),
          onRemove: _removeGrade,
          onWeightChanged: (w) => _setWeight(kind, w),
        ),
    ];
  }

  InputDecoration _fieldDecoration(
    ColorScheme scheme, {
    required String hint,
    required IconData icon,
    String? errorText,
    String? helper,
  }) {
    return InputDecoration(
      hintText: hint,
      helperText: helper,
      errorText: errorText,
      filled: true,
      fillColor: scheme.surface,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Abschnitt einer Noten-Art (Schulaufgaben, Kurzarbeiten, …)
// ---------------------------------------------------------------------------

class _KindSection extends StatelessWidget {
  final GradeKind kind;
  final GradingSystem system;
  final List<GradeEntry> entries;
  final double weight;
  final VoidCallback onAdd;
  final ValueChanged<GradeEntry> onRemove;
  final ValueChanged<double> onWeightChanged;

  const _KindSection({
    required this.kind,
    required this.system,
    required this.entries,
    required this.weight,
    required this.onAdd,
    required this.onRemove,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _kindLabel(kind),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              Text(S.gradeWeightLabel,
                  style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(width: 8),
              _WeightStepper(value: weight, onChanged: onWeightChanged),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final e in entries)
                InputChip(
                  label: Text(
                    GradeCalc.valueText(system, e.value),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onDeleted: () => onRemove(e),
                  deleteIconColor: scheme.onSurface.withValues(alpha: 0.6),
                  deleteButtonTooltipMessage: S.gradeRemoveTooltip,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                ),
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: const Text(S.gradeAddChip),
                onPressed: onAdd,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _kindLabel(GradeKind kind) {
    switch (kind) {
      case GradeKind.schulaufgabe:
        return S.gradeKindSchulaufgabe;
      case GradeKind.kurzarbeit:
        return S.gradeKindKurzarbeit;
      case GradeKind.ex:
        return S.gradeKindEx;
      case GradeKind.muendlich:
        return S.gradeKindMuendlich;
    }
  }
}

/// Kleiner −/+-Regler für das Gewicht einer Noten-Art (ganzzahlig, 0–9).
class _WeightStepper extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _WeightStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(
            icon: Icons.remove_rounded,
            onTap: value > 0 ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 22,
            child: Text(
              value.toStringAsFixed(0),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
          _StepBtn(
            icon: Icons.add_rounded,
            onTap: value < 9 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? scheme.onSurface.withValues(alpha: 0.25)
              : scheme.primary,
        ),
      ),
    );
  }
}

/// Zeigt die berechnete Zeugnis-/Modulnote als kleines Abzeichen.
class _FinalGradeBadge extends StatelessWidget {
  final GradingSystem system;
  final double? value;
  final String label;

  const _FinalGradeBadge({
    required this.system,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final has = value != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: has
            ? scheme.primary.withValues(alpha: 0.15)
            : scheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.7))),
          Text(
            has ? GradeCalc.valueText(system, value!) : S.finalGradeNone,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: has ? scheme.primary : scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Prüfungstermine: Liste + Dialog
// ---------------------------------------------------------------------------

/// Zeigt die eingetragenen Prüfungstermine als Chips (Datum + Art, ggf. mit
/// Feedback „Lief 7/10") und den Hinzufügen-Knopf.
class _ExamSection extends StatelessWidget {
  final List<Exam> exams;
  final VoidCallback onAdd;
  final ValueChanged<Exam> onRemove;

  const _ExamSection({
    required this.exams,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.examsHint,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final e in exams)
                InputChip(
                  label: Text(
                    '${S.shortDate(e.date)} ${S.examKind(e.kind)}'
                    '${e.rating != null ? ' · ${S.examRatedPrefix} ${e.rating}/10' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onDeleted: () => onRemove(e),
                  deleteIconColor: scheme.onSurface.withValues(alpha: 0.6),
                  deleteButtonTooltipMessage: S.examRemoveTooltip,
                  backgroundColor: scheme.tertiary.withValues(alpha: 0.12),
                ),
              ActionChip(
                avatar: const Icon(Icons.event_rounded, size: 18),
                label: const Text(S.examAddChip),
                onPressed: onAdd,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dialog: Prüfung eintragen (Art wählen + Datum picken). Studenten sehen
/// Uni-Prüfungsarten (Klausur, Präsentation), Schüler:innen die schulischen.
class _AddExamDialog extends StatefulWidget {
  final bool isUni;

  const _AddExamDialog({required this.isUni});

  @override
  State<_AddExamDialog> createState() => _AddExamDialogState();
}

class _AddExamDialogState extends State<_AddExamDialog> {
  late ExamKind _kind =
      widget.isUni ? ExamKind.klausur : ExamKind.schulaufgabe;
  DateTime? _date;

  List<ExamKind> get _kinds =>
      widget.isUni ? kUniExamKinds : kSchoolExamKinds;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      // Auch (kurz) zurückliegende Termine erlauben – dann fragt die App
      // direkt beim nächsten Start nach dem Feedback.
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final date = _date;
    if (date == null) return;
    Navigator.of(context).pop(Exam(
      id: 'exam_${DateTime.now().microsecondsSinceEpoch}',
      date: date,
      kind: _kind,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(S.examAddTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(S.examKindLabel2,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final k in _kinds)
                ChoiceChip(
                  label: Text(S.examKind(k)),
                  selected: _kind == k,
                  onSelected: (_) => setState(() => _kind = k),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(S.examDateLabel,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month_rounded, size: 18),
            label: Text(
              _date == null
                  ? S.examPickDate
                  : '${S.shortDate(_date!)}${_date!.year}',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(S.cancel),
        ),
        FilledButton(
          onPressed: _date == null ? null : _submit,
          child: const Text(S.examAddButton),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog: eine Note eintragen
// ---------------------------------------------------------------------------

class _AddGradeDialog extends StatefulWidget {
  final GradingSystem system;
  final GradeKind kind;

  const _AddGradeDialog({required this.system, required this.kind});

  @override
  State<_AddGradeDialog> createState() => _AddGradeDialogState();
}

class _AddGradeDialogState extends State<_AddGradeDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw);
    final sys = widget.system;
    if (value == null || value < sys.minGrade || value > sys.maxGrade) {
      setState(() {
        _error = sys == GradingSystem.punkte
            ? S.gradeInvalidPunkte
            : S.gradeInvalidNoten;
      });
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final isPunkte = widget.system == GradingSystem.punkte;
    return AlertDialog(
      title: Text(
          isPunkte ? S.gradeAddTitlePunkte : S.gradeAddTitleNoten),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: isPunkte ? S.gradeLabelPunkte : S.gradeLabelNoten,
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(S.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text(S.gradeAddButton),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    );
  }
}
