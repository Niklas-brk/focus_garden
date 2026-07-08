import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/focus_session.dart';
import '../models/plant.dart';
import '../models/plant_catalog.dart';
import '../models/subject.dart';
import '../services/blocker_service.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';
import '../utils/growth.dart';
import 'history_provider.dart';
import 'settings_provider.dart';
import 'subject_provider.dart';

enum FocusPhase { setup, running, grown, bloomed, wilted }

/// Kern der App: Fokus-Timer mit robuster Timestamp-Logik, Verwelk-Mechanik
/// über den App-Lifecycle und Absturz-Wiederherstellung (Konzept Abschnitt 8).
///
/// Ab Phase 2 läuft jede Session über ein **Fach** (statt einer losen Pflanze).
/// Die Fach-Pflanze wächst über mehrere Sessions: erst bei
/// [bloomTargetMinutes] Fokusminuten blüht sie voll auf und wandert in den
/// Garten; danach beginnt am selben Fach eine neue Pflanze.
class SessionProvider extends ChangeNotifier {
  final StorageService storage;
  final NotificationService notifications;
  final SoundService sound;
  final SettingsProvider settings;
  final HistoryProvider history;
  final SubjectProvider subjects;
  final BlockerService blocker;

  static const int graceSeconds = 30; // Gnadenfrist
  static const List<int> presets = [25, 45, 60, 90];
  static const int minCustom = 10;
  static const int maxCustom = 180;

  /// Fokusminuten bis zur vollen Blüte einer Fach-Pflanze (~4–5×25 Min).
  static const int bloomTargetMinutes = 120;

  SessionProvider({
    required this.storage,
    required this.notifications,
    required this.sound,
    required this.settings,
    required this.history,
    required this.subjects,
    required this.blocker,
  }) {
    _recover();
  }

  // ---- Auswahl --------------------------------------------------------------
  String? _selectedSubjectId;
  int _selectedMinutes = 25;

  /// Das aktuell gewählte Fach. Wird über die ID gegen den SubjectProvider
  /// aufgelöst, damit gelöschte Fächer automatisch auf das erste zurückfallen
  /// und der Fortschritt immer aktuell ist.
  Subject? get selectedSubject {
    final list = subjects.subjects;
    if (list.isEmpty) return null;
    if (_selectedSubjectId != null) {
      for (final s in list) {
        if (s.id == _selectedSubjectId) return s;
      }
    }
    return list.first;
  }

  /// Die Pflanze des gewählten Fachs (für Anzeige in Session/Ergebnis).
  Plant get selectedPlant =>
      PlantCatalog.byId(selectedSubject?.plantId ?? PlantCatalog.free.first.id);

  int get selectedMinutes => _selectedMinutes;

  void selectSubject(Subject s) {
    _selectedSubjectId = s.id;
    notifyListeners();
  }

  void selectMinutes(int minutes) {
    _selectedMinutes = minutes.clamp(minCustom, maxCustom);
    notifyListeners();
  }

  // ---- Laufzeit-Zustand -----------------------------------------------------
  FocusPhase _phase = FocusPhase.setup;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _strict = true;
  bool _willBloom = false; // erreicht diese Session die volle Blüte?
  Timer? _ticker;
  Duration _remaining = Duration.zero;
  DateTime? _pausedAt;

  FocusPhase get phase => _phase;
  Duration get remaining => _remaining;
  bool get isRunning => _phase == FocusPhase.running;
  bool get isWilted => _phase == FocusPhase.wilted;

  /// Zeit-Fortschritt der laufenden Session (für den Ring/Countdown).
  double get progress {
    if (_startTime == null || _endTime == null) return 0;
    final total = _endTime!.difference(_startTime!).inMilliseconds;
    if (total <= 0) return 1;
    final elapsed = DateTime.now().difference(_startTime!).inMilliseconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// Verstrichene Fokusminuten der laufenden Session (0, wenn nicht am Laufen).
  double get _elapsedMinutes {
    if (_phase != FocusPhase.running || _startTime == null) return 0;
    final secs = DateTime.now().difference(_startTime!).inSeconds;
    final capped = secs.clamp(0, _selectedMinutes * 60);
    return capped / 60.0;
  }

  /// Gesamter Blüh-Fortschritt (gespeicherte Fach-Minuten + laufende Session).
  double get bloomProgressMinutes {
    final base = selectedSubject?.bloomProgress ?? 0;
    return base + _elapsedMinutes;
  }

  /// Blüh-Fortschritt als Anteil 0.0–1.0 (Richtung [bloomTargetMinutes]).
  double get bloomFraction =>
      (bloomProgressMinutes / bloomTargetMinutes).clamp(0.0, 1.0);

  /// Noch fehlende Fokusminuten bis zur vollen Blüte.
  int get bloomRemainingMinutes {
    final rem = bloomTargetMinutes - bloomProgressMinutes;
    return rem <= 0 ? 0 : rem.ceil();
  }

  /// Stufe der aktuell gezeigten Pflanze: leitet sich (außer bei voller Blüte)
  /// aus dem Blüh-Fortschritt des Fachs ab.
  int get currentStage {
    if (_phase == FocusPhase.bloomed) return Growth.stageCount;
    return Growth.stageForProgress(bloomFraction);
  }

  String get remainingLabel {
    final total = _remaining.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ---- Steuerung ------------------------------------------------------------

  void start() {
    final subject = selectedSubject;
    if (subject == null) return; // ohne Fach kein Start
    _startTime = DateTime.now();
    _endTime = _startTime!.add(Duration(minutes: _selectedMinutes));
    _strict = settings.strictMode;
    _pausedAt = null;
    _willBloom = subject.bloomProgress + _selectedMinutes >= bloomTargetMinutes;
    _phase = FocusPhase.running;
    _persistActive();
    notifications.scheduleSessionEnd(_endTime!, willBloom: _willBloom);
    _startTicker();
    _haptic(HapticFeedback.mediumImpact);
    if (settings.soundsOn) sound.playStart();
    notifyListeners();
  }

  /// Nutzer bricht ab -> Pflanze stirbt.
  void cancelSession() {
    _finishWilted();
  }

  /// Zurück zum Auswahl-Screen nach einem Ergebnis.
  void reset() {
    _ticker?.cancel();
    _ticker = null;
    blocker.hideShield();
    _phase = FocusPhase.setup;
    _startTime = null;
    _endTime = null;
    _remaining = Duration.zero;
    _pausedAt = null;
    notifyListeners();
  }

  // ---- Ticker ---------------------------------------------------------------

  void _startTicker() {
    _ticker?.cancel();
    _updateRemaining();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _onTick() {
    final prevStage = currentStage;
    _updateRemaining();
    if (_remaining <= Duration.zero) {
      _finishSuccess(fromForeground: true);
    } else {
      if (currentStage != prevStage) _haptic(HapticFeedback.selectionClick);
      notifyListeners();
    }
  }

  void _updateRemaining() {
    if (_endTime == null) {
      _remaining = Duration.zero;
      return;
    }
    final r = _endTime!.difference(DateTime.now());
    _remaining = r.isNegative ? Duration.zero : r;
  }

  // ---- Auflösung ------------------------------------------------------------

  /// Erfolgreicher Session-Abschluss. Schreibt die Fokusminuten dem Fach gut:
  /// erreicht der Fortschritt [bloomTargetMinutes], blüht die Pflanze voll auf
  /// (Garten + Konfetti), sonst ist sie nur „gewachsen" (Zwischenstand).
  Future<void> _finishSuccess({required bool fromForeground}) async {
    _ticker?.cancel();
    _ticker = null;
    blocker.hideShield(); // Session vorbei -> ggf. Schild schließen

    await storage.clearActive();

    final subject = selectedSubject;
    if (subject == null) {
      // Fach wurde zwischenzeitlich gelöscht -> nichts gutschreiben.
      await notifications.cancelBloom();
      _pausedAt = null;
      _phase = FocusPhase.setup;
      notifyListeners();
      return;
    }

    final newProgress = subject.bloomProgress + _selectedMinutes;
    final didBloom = newProgress >= bloomTargetMinutes;

    // Session in der Historie ablegen (Statistik + ggf. Garten).
    final session = FocusSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      plantId: subject.plantId,
      subjectId: subject.id,
      durationMinutes: _selectedMinutes,
      startTime: _startTime ?? DateTime.now(),
      endTime: DateTime.now(),
      outcome: didBloom ? SessionOutcome.bloomed : SessionOutcome.grown,
    );
    await storage.addSession(session);

    // Fach-Fortschritt fortschreiben (Rest über die volle Blüte übertragen).
    final updated = didBloom
        ? subject.copyWith(
            bloomProgress: newProgress - bloomTargetMinutes,
            bloomedCount: subject.bloomedCount + 1,
          )
        : subject.copyWith(bloomProgress: newProgress);
    await subjects.update(updated);
    history.reload();

    // Genau eine Meldung: im Vordergrund geplante ersetzen.
    if (fromForeground) {
      await notifications.cancelBloom();
      if (didBloom) await notifications.showBloom();
    }

    _pausedAt = null;
    if (didBloom) {
      _phase = FocusPhase.bloomed;
      _celebrate();
      if (settings.soundsOn) sound.playSuccess();
    } else {
      _phase = FocusPhase.grown;
      _haptic(HapticFeedback.mediumImpact);
      if (settings.soundsOn) sound.playSuccess();
    }
    notifyListeners();
  }

  Future<void> _finishWilted() async {
    _ticker?.cancel();
    _ticker = null;
    blocker.hideShield(); // Session vorbei -> ggf. Schild schließen
    await storage.clearActive();
    await notifications.cancelBloom();
    await notifications.cancelWarning();
    _pausedAt = null;
    _phase = FocusPhase.wilted;
    _haptic(HapticFeedback.heavyImpact);
    if (settings.soundsOn) sound.playWilt();
    notifyListeners();
  }

  // ---- Lifecycle (Verwelk-Mechanik) -----------------------------------------

  void onAppPaused() {
    if (_phase != FocusPhase.running) return;
    // Fokus-Schild zeigen (unabhängig vom strengen Modus – reiner Reminder).
    // Idempotent, darf also auch beim zusätzlichen `hidden`-Übergang laufen.
    if (settings.blockerOn) blocker.showShield();
    if (!_strict) return;
    // Nur den ERSTEN Verlassen-Zeitpunkt merken. Flutter durchläuft beim
    // Zurückkehren zusätzlich den Zustand `hidden` (paused -> hidden ->
    // inactive -> resumed); ohne diesen Schutz würde er _pausedAt kurz vor
    // `resumed` auf "jetzt" zurücksetzen und die Verwelk-Prüfung austricksen.
    if (_pausedAt != null) return;
    _pausedAt = DateTime.now();
    // Geplante End-Meldung aussetzen, stattdessen Warnung zeigen.
    notifications.cancelBloom();
    notifications.showWiltWarning();
  }

  void onAppResumed() {
    // Sind wir zurück, ist das Schild überflüssig – immer schließen.
    blocker.hideShield();
    if (_phase != FocusPhase.running) return;
    final now = DateTime.now();
    final leftTooLong = _pausedAt != null &&
        now.difference(_pausedAt!).inSeconds > graceSeconds;

    if (_strict && leftTooLong) {
      _finishWilted();
      return;
    }

    notifications.cancelWarning();
    _pausedAt = null;

    if (!now.isBefore(_endTime ?? now)) {
      _finishSuccess(fromForeground: false);
    } else {
      if (_strict) {
        notifications.scheduleSessionEnd(_endTime!, willBloom: _willBloom);
      }
      _startTicker();
      notifyListeners();
    }
  }

  // ---- Wiederherstellung nach Prozess-Kill / Neustart -----------------------

  void _recover() {
    final data = storage.getActive();
    if (data == null) return;
    _startTime = DateTime.fromMillisecondsSinceEpoch(data['startMs'] as int);
    _endTime = DateTime.fromMillisecondsSinceEpoch(data['endMs'] as int);
    _strict = data['strict'] as bool;
    _selectedMinutes = data['minutes'] as int;
    _selectedSubjectId = data['subjectId'] as String?;

    final now = DateTime.now();
    if (!now.isBefore(_endTime!)) {
      // Timer war beim Start der App bereits abgelaufen -> auflösen.
      _finishSuccess(fromForeground: false);
    } else {
      // Session lief noch -> fortsetzen.
      _phase = FocusPhase.running;
      _willBloom = (selectedSubject?.bloomProgress ?? 0) + _selectedMinutes >=
          bloomTargetMinutes;
      notifications.scheduleSessionEnd(_endTime!, willBloom: _willBloom);
      _startTicker();
    }
  }

  // ---- Helfer ---------------------------------------------------------------

  void _persistActive() {
    storage.setActive({
      'subjectId': selectedSubject?.id,
      'minutes': _selectedMinutes,
      'startMs': _startTime!.millisecondsSinceEpoch,
      'endMs': _endTime!.millisecondsSinceEpoch,
      'strict': _strict,
    });
  }

  void _haptic(Future<void> Function() fn) {
    if (settings.hapticsOn) fn();
  }

  /// Festliche Vibrations-Sequenz zum Erfolgs-Moment (passend zum Konfetti):
  /// ein kleines „Ta-da" aus drei kurz aufeinanderfolgenden Impulsen.
  void _celebrate() {
    if (!settings.hapticsOn) return;
    HapticFeedback.mediumImpact();
    Future.delayed(
        const Duration(milliseconds: 130), HapticFeedback.lightImpact);
    Future.delayed(
        const Duration(milliseconds: 270), HapticFeedback.heavyImpact);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
