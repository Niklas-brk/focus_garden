import 'package:flutter/material.dart';

import '../models/edu_profile.dart';
import '../models/scene_background.dart';
import '../services/storage_service.dart';

/// Hält die App-Einstellungen (Konzept Abschnitt 3) und schreibt sie nach Hive.
class SettingsProvider extends ChangeNotifier {
  final StorageService storage;

  static const _kStrict = 'strictMode';
  static const _kBlocker = 'blockerOn';
  static const _kSounds = 'soundsOn';
  static const _kHaptics = 'hapticsOn';
  static const _kTheme = 'themeMode';
  static const _kPremium = 'premium';
  static const _kOnboarded = 'onboardingDone';
  static const _kGardenName = 'gardenName';
  static const _kGardenTheme = 'gardenTheme';
  static const _kSceneBg = 'sceneBg';
  static const _kSceneTime = 'sceneTime';
  static const _kEduKind = 'eduKind';
  static const _kSchoolType = 'schoolType';
  static const _kStudiengang = 'studiengang';

  static const defaultGardenName = 'Mein Garten';

  /// Test-Builds fürs eigene Gerät: Premium per Build-Flag freischalten mit
  ///   flutter build apk --release --dart-define=PREMIUM_TEST=true ...
  /// Im normalen (Store-)Build ist das Flag nicht gesetzt -> false, keine
  /// Auswirkung. Wird bewusst NICHT gespeichert: ohne Flag gebaut gilt wieder
  /// der ehrliche Kauf-Status.
  static const _premiumTestBuild = bool.fromEnvironment('PREMIUM_TEST');

  late bool _strictMode;
  late bool _blockerOn;
  late bool _soundsOn;
  late bool _hapticsOn;
  late ThemeMode _themeMode;
  late bool _premium;
  late bool _onboardingDone;
  late String _gardenName;
  late String _gardenThemeId;
  late String _sceneBackgroundId;
  late SceneTime _sceneTime;
  late EduKind _eduKind;
  late SchoolType _schoolType;
  late String _studiengang;

  SettingsProvider(this.storage) {
    _strictMode = storage.getBool(_kStrict, true); // Standard: streng
    _blockerOn = storage.getBool(_kBlocker, false); // Standard: aus (opt-in)
    _soundsOn = storage.getBool(_kSounds, true);
    _hapticsOn = storage.getBool(_kHaptics, true);
    _themeMode = _themeFromString(storage.getString(_kTheme, 'dark'));
    _premium = _premiumTestBuild || storage.getBool(_kPremium, false);
    _onboardingDone = storage.getBool(_kOnboarded, false);
    _gardenName = storage.getString(_kGardenName, defaultGardenName);
    _gardenThemeId = storage.getString(_kGardenTheme, 'default');
    _sceneBackgroundId = storage.getString(_kSceneBg, 'greenhouse');
    _sceneTime = sceneTimeFromString(storage.getString(_kSceneTime, 'day'));
    _eduKind = _eduKindFromString(storage.getString(_kEduKind, 'schuelerin'));
    _schoolType =
        _schoolTypeFromString(storage.getString(_kSchoolType, 'gymnasium'));
    _studiengang = storage.getString(_kStudiengang, '');
  }

  bool get strictMode => _strictMode;

  /// Ob das Fokus-Schild (Overlay über anderen Apps) aktiv ist. Opt-in, weil
  /// dafür die Sonderberechtigung „Über anderen Apps anzeigen" nötig ist.
  bool get blockerOn => _blockerOn;
  bool get soundsOn => _soundsOn;
  bool get hapticsOn => _hapticsOn;
  ThemeMode get themeMode => _themeMode;
  bool get premium => _premium;

  /// Ob das Onboarding schon durchlaufen (oder übersprungen) wurde.
  bool get onboardingDone => _onboardingDone;

  /// Name des Gartens (frei wählbar in „Garten einrichten"). Leere Eingabe
  /// fällt auf den Standardnamen zurück.
  String get gardenName => _gardenName;

  /// ID des gewählten Garten-Hintergrund-Themas (siehe GardenThemes).
  String get gardenThemeId => _gardenThemeId;

  set gardenName(String v) {
    final name = v.trim().isEmpty ? defaultGardenName : v.trim();
    if (name == _gardenName) return;
    _gardenName = name;
    storage.setString(_kGardenName, name);
    notifyListeners();
  }

  set gardenThemeId(String id) {
    if (id == _gardenThemeId) return;
    _gardenThemeId = id;
    storage.setString(_kGardenTheme, id);
    notifyListeners();
  }

  // ---- Garten-Szene / Wallpaper-Hintergrund ---------------------------------

  /// Gewählte Hintergrund-Szene der Garten-Szene (siehe SceneBackgrounds).
  String get sceneBackgroundId => _sceneBackgroundId;

  /// Gewählte Tageszeit der Bild-Szene (Tag/Sonnenuntergang/Nacht).
  SceneTime get sceneTime => _sceneTime;

  set sceneBackgroundId(String id) {
    if (id == _sceneBackgroundId) return;
    _sceneBackgroundId = id;
    storage.setString(_kSceneBg, id);
    notifyListeners();
  }

  set sceneTime(SceneTime t) {
    if (t == _sceneTime) return;
    _sceneTime = t;
    storage.setString(_kSceneTime, t.name);
    notifyListeners();
  }

  // ---- Bildungsprofil (Noten) ------------------------------------------------

  /// Ob der Nutzer Schüler:in oder Student:in ist.
  EduKind get eduKind => _eduKind;

  /// Gewählte Schulart (nur relevant für Schüler:innen).
  SchoolType get schoolType => _schoolType;

  /// Freier Studiengang-Text (nur relevant für Student:innen).
  String get studiengang => _studiengang;

  /// Abgeleitetes Bewertungssystem des Notenrechners.
  GradingSystem get gradingSystem => gradingFor(_eduKind, _schoolType);

  set eduKind(EduKind v) {
    if (v == _eduKind) return;
    _eduKind = v;
    storage.setString(_kEduKind, v.name);
    notifyListeners();
  }

  set schoolType(SchoolType v) {
    if (v == _schoolType) return;
    _schoolType = v;
    storage.setString(_kSchoolType, v.name);
    notifyListeners();
  }

  set studiengang(String v) {
    final text = v.trim();
    if (text == _studiengang) return;
    _studiengang = text;
    storage.setString(_kStudiengang, text);
    notifyListeners();
  }

  /// Beim ersten Start nach dem Onboarding aufrufen: merkt sich, dass es
  /// nicht erneut gezeigt werden muss.
  void completeOnboarding() {
    if (_onboardingDone) return;
    _onboardingDone = true;
    storage.setBool(_kOnboarded, true);
    notifyListeners();
  }

  /// Schaltet Premium frei – nach erfolgreichem Kauf ODER wiederhergestelltem
  /// Kauf (Konzept Abschnitt 7). Idempotent.
  void unlockPremium() {
    if (_premium) return;
    _premium = true;
    storage.setBool(_kPremium, true);
    notifyListeners();
  }

  /// NUR für Entwicklung/Tests: Premium an-/ausschalten. Der aufrufende
  /// Debug-Schalter ist mit kDebugMode abgesichert und im Release nicht
  /// erreichbar (echte Freischaltung läuft ausschließlich über den Kauf).
  void debugTogglePremium() {
    _premium = !_premium;
    storage.setBool(_kPremium, _premium);
    notifyListeners();
  }

  set strictMode(bool v) {
    _strictMode = v;
    storage.setBool(_kStrict, v);
    notifyListeners();
  }

  set blockerOn(bool v) {
    _blockerOn = v;
    storage.setBool(_kBlocker, v);
    notifyListeners();
  }

  set soundsOn(bool v) {
    _soundsOn = v;
    storage.setBool(_kSounds, v);
    notifyListeners();
  }

  set hapticsOn(bool v) {
    _hapticsOn = v;
    storage.setBool(_kHaptics, v);
    notifyListeners();
  }

  set themeMode(ThemeMode v) {
    _themeMode = v;
    storage.setString(_kTheme, _themeToString(v));
    notifyListeners();
  }

  static ThemeMode _themeFromString(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  static String _themeToString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  static EduKind _eduKindFromString(String s) =>
      s == 'studentin' ? EduKind.studentin : EduKind.schuelerin;

  static SchoolType _schoolTypeFromString(String s) => SchoolType.values
      .firstWhere((t) => t.name == s, orElse: () => SchoolType.gymnasium);
}
