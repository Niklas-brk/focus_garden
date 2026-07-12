import 'dart:ui' show Locale;

import '../models/exam.dart';
import '../models/subject.dart';

/// Zentrale Textbausteine (Deutsch primär, Englisch vollständig).
///
/// Alle sichtbaren Texte laufen über diese Klasse (Konzept Abschnitt 8).
/// Die Felder sind bewusst NICHT `const`: [init] wählt beim App-Start anhand
/// der Gerätesprache – Deutsch ist Standard, jede andere Sprache bekommt
/// Englisch. [_applyEnglish] überschreibt dafür JEDES Feld; der Test
/// `test/l10n_completeness_test.dart` wacht darüber, dass keins fehlt.
class S {
  static bool _english = false;

  /// Aktive Sprache (für Datumsformate u. Ä.).
  static bool get isEnglish => _english;

  /// Wählt die Sprache anhand der Gerätesprache. Vor `runApp` aufrufen.
  static void init(Locale locale) {
    _english = !locale.languageCode.toLowerCase().startsWith('de');
    if (_english) _applyEnglish();
  }

  // App
  static String appName = 'Focus Garden';

  // Navigation
  static String tabFocus = 'Fokus';
  static String tabGarden = 'Garten';
  static String tabStats = 'Statistik';
  static String tabGrades = 'Noten';

  // Onboarding (3 Screens, überspringbar – Konzept Abschnitt 3/4)
  static String onboardSkip = 'Überspringen';
  static String onboardNext = 'Weiter';
  static String onboardStart = 'Los geht’s';
  static String onboard1Title = 'Willkommen im Focus Garden 🌱';
  static String onboard1Body =
      'Konzentriere dich auf eine Sache – und eine Pflanze wächst mit jeder Minute Fokus.';
  static String onboard2Title = 'Bleib dran, sonst welkt sie';
  static String onboard2Body =
      'Verlässt du die App während der Session, verwelkt deine Pflanze. So bleibst du bei der Sache – im strengen Modus, jederzeit umstellbar.';
  static String onboard3Title = 'Sammle & flexe';
  static String onboard3Body =
      'Jede erblühte Pflanze wandert in deinen Garten. Baue Streaks auf und teile deine Flex-Card.';

  // Fokus-Screen
  static String choosePlant = 'Wähle deine Pflanze';
  static String chooseSubject = 'Woran arbeitest du?';
  static String chooseDuration = 'Fokusdauer';
  static String customDuration = 'Frei';
  static String minutesShort = 'Min';
  static String start = 'Starten';
  static String premiumLocked = 'Premium';
  // Leerzustand: erst ein Fach/Modul anlegen (Fokus läuft immer über ein Fach)
  static String focusNoSubjectTitle = 'Noch kein Fach';
  static String focusNoSubjectBody =
      'Lege zuerst ein Fach an – daran wächst deine Pflanze über mehrere Sessions.';
  static String focusNoSubjectButton = 'Fach anlegen';
  static String focusNoSubjectTitleUni = 'Noch kein Modul';
  static String focusNoSubjectBodyUni =
      'Lege zuerst ein Modul an – daran wächst deine Pflanze über mehrere Sessions.';
  static String focusNoSubjectButtonUni = 'Modul anlegen';
  // Blüh-Fortschritt (mehrstufige Blüte)
  static String bloomProgressLabel = 'Bis zur Blüte';
  static String bloomedBadge = '🌸'; // erblühte Pflanzen dieses Fachs
  static String bloomRemaining = 'Noch {n} Min bis zur Blüte';

  // Aktive Session
  static String grows = 'wächst gerade …';
  static String cancel = 'Abbrechen';
  static String cancelTitle = 'Bist du sicher?';
  static String cancelBody = 'Deine Pflanze stirbt 🥀';
  static String cancelConfirm = 'Ja, abbrechen';
  static String cancelKeep = 'Weiter fokussieren';

  // Ergebnis
  static String bloomedTitle = 'Erblüht! 🌸';
  static String bloomedBody = 'Deine Pflanze ist in den Garten gewandert.';
  static String grownTitle = 'Gewachsen 🌿';
  static String grownBody =
      'Deine Pflanze ist ein Stück gewachsen. Bleib dran bis zur Blüte!';
  static String wiltedTitle = 'Verwelkt 🥀';
  static String wiltedBody =
      'Diesmal nicht geschafft – der nächste Versuch zählt wieder.';
  static String backToGarden = 'Weiter';
  static String keepGoing = 'Weiter so';
  static String tryAgain = 'Nochmal';

  // Wachstumsstufen
  static String stageSeed = 'Samen';
  static String stageSprout = 'Spross';
  static String stagePlant = 'Pflanze';
  static String stageBloom = 'Blüte';

  // Garten
  static String gardenTitle = 'Dein Garten';
  static String gardenEmpty =
      'Noch keine Pflanzen.\nStarte deine erste Fokus-Session!';
  static String weekSummary = 'Diese Woche';
  static String plantsCount = 'Pflanzen';
  static String createFlexCard = 'Flex-Card erstellen';
  static String filterAll = 'Alle';

  // Garten einrichten
  static String gardenSetup = 'Einrichten';
  static String gardenSetupTitle = 'Garten einrichten';
  static String gardenNameLabel = 'Name des Gartens';
  static String gardenNameHint = 'Wie soll dein Garten heißen?';
  static String gardenBackground = 'Hintergrund';
  static String gardenArrange = 'Pflanzen anordnen';
  static String gardenArrangeHint = 'Halten & ziehen zum Umsortieren.';
  static String gardenArrangeEmpty =
      'Noch keine Pflanzen zum Anordnen – erblühe erst welche im Fokus.';
  static String gardenThemeLocked = 'Premium';
  static String save = 'Fertig';

  // Garten-Szene / Wallpaper (Pflanzen auf einer Wiese anordnen & exportieren)
  static String sceneEntry = 'Als Wallpaper gestalten';
  static String sceneTitle = 'Garten-Szene';
  static String sceneHint =
      'Ziehe Pflanzen & Deko. Deko lange drücken = entfernen.';
  // Szenen-/Tageszeit-Auswahl
  static String sceneBackgroundLabel = 'Szene';
  static String sceneTimeDay = 'Tag';
  static String sceneTimeSunset = 'Sonnenuntergang';
  static String sceneTimeNight = 'Nacht';
  // Deko
  static String sceneAddDeco = 'Deko';
  static String sceneDecoTitle = 'Deko hinzufügen';
  static String sceneDecoRemoved = 'Deko entfernt';
  static String sceneEmpty =
      'Noch keine Pflanzen für die Szene.\nErblühe erst welche im Fokus.';
  static String sceneShare = 'Teilen';
  static String sceneShareText = 'Mein Focus Garden 🌱';
  static String sceneShareError = 'Teilen hat nicht geklappt.';
  static String sceneSetWallpaper = 'Als Hintergrund';
  static String sceneWallpaperSet = 'Als Hintergrund festgelegt 🌱';
  static String sceneWallpaperError =
      'Hintergrund konnte nicht gesetzt werden.';
  static String sceneReset = 'Neu anordnen';
  static String sceneBranding = '🌱 Focus Garden';

  // Flex-Card (Konzept Abschnitt 6)
  static String flexTitle = 'Flex-Card';
  static String flexWeekLabel = 'MEINE WOCHE';
  static String flexMinutesLabel = 'Fokusminuten';
  static String flexStreakLabel = 'Tage-Streak';
  static String flexPlantsLabel = 'Pflanzen';
  static String flexRecentLabel = 'Zuletzt gepflanzt';
  static String flexBranding = '🌱 Focus Garden · ohne Abo';
  static String flexShare = 'Teilen';
  static String flexShareText = 'Meine Fokus-Woche mit Focus Garden 🌱';
  static String flexShareError = 'Teilen hat nicht geklappt.';
  static String flexStyleDark = 'Dunkel';
  static String flexStyleCozy = 'Cozy';
  static String flexStyleNeon = 'Neon';

  // Statistik
  static String statsTitle = 'Statistik';
  static String today = 'Heute';
  static String week = 'Woche';
  static String total = 'Gesamt';
  static String focusMinutes = 'Fokusminuten';
  static String sessions = 'Sessions';
  static String streak = 'Streak';
  static String days = 'Tage';
  static String last7days = 'Letzte 7 Tage';

  // Noten (Schule/Studium)
  static String gradesTitle = 'Noten';
  // Profil-Karte
  static String eduRoleLabel = 'Ich bin …';
  static String eduSchueler = 'Schüler:in';
  static String eduStudent = 'Student:in';
  static String schoolTypeLabel = 'Schulart';
  static String schoolGymnasium = 'Gymnasium';
  static String schoolRealschule = 'Realschule';
  static String schoolHauptschule = 'Hauptschule';
  static String schoolGesamtschule = 'Gesamtschule';
  static String schoolFachschule = 'Fachschule';
  static String studiengangLabel = 'Studiengang';
  static String studiengangHint = 'z. B. Informatik B.Sc.';
  // Studienfächer (z. B. Lehramt: Deutsch + Reli, je mit eigenen Klausuren)
  static String studienfaecherLabel = 'Studienfächer (optional)';
  static String studienfaecherHint =
      'Studierst du mehrere Fächer (z. B. Lehramt)? Lege sie hier an und '
      'ordne jedes Modul einem Fach zu. Antippen benennt ein Fach um.';
  static String studienfachAddChip = 'Fach';
  static String studienfachAddTitle = 'Studienfach hinzufügen';
  static String studienfachAddHint = 'z. B. Deutsch';
  static String studienfachAddButton = 'Hinzufügen';
  static String studienfachRenameTitle = 'Fach umbenennen';
  static String studienfachRenameButton = 'Speichern';
  static String studienfachDuplicate = 'Dieses Fach gibt es schon.';
  static String studienfachRemoveTooltip = 'Fach entfernen';
  static String studienfachRemoveTitle = 'Fach entfernen?';
  static String studienfachRemoveBody =
      'Die zugeordneten Module und ihre Noten bleiben erhalten – sie stehen '
      'danach unter „Ohne Fach".';
  static String studienfachLabel = 'Studienfach';
  static String studienfachNone = 'Ohne Fach';
  static String studienfachEmptyGroup = 'Noch keine Module in diesem Fach.';
  static String gradingHintPunkte = 'Bewertung in Punkten (0–15).';
  static String gradingHintNoten = 'Bewertung in Noten (1–6).';
  static String gradingHintUni = 'Uni-Noten (1,0–5,0), ECTS-gewichtet.';
  // Fächer-Liste
  static String subjectsSchool = 'Fächer';
  static String subjectsUni = 'Module';
  static String subjectAddSchool = 'Fach hinzufügen';
  static String subjectAddUni = 'Modul hinzufügen';
  static String subjectsEmptySchool =
      'Noch keine Fächer.\nLege dein erstes Fach an!';
  static String subjectsEmptyUni =
      'Noch keine Module.\nLege dein erstes Modul an!';
  static String subjectNoGrade = 'Keine Note';
  static String creditsShort = 'ECTS';
  // Durchschnitt-Karte
  static String averageLabel = 'Durchschnitt';
  static String averageEmpty =
      'Trage Noten ein, um deinen Durchschnitt zu sehen.';
  static String unitPoints = 'Punkte';
  static String unitGrade = 'Note';
  static String creditsSumLabel = 'Summe ECTS';
  static String uniPassed = 'bestanden';
  static String uniNotPassed = 'nicht bestanden';
  // Fach anlegen/bearbeiten
  static String subjectNewSchool = 'Neues Fach';
  static String subjectNewUni = 'Neues Modul';
  static String subjectEditSchool = 'Fach bearbeiten';
  static String subjectEditUni = 'Modul bearbeiten';
  static String subjectNameLabel = 'Name';
  static String subjectNameHint = 'z. B. Mathe';
  static String subjectNameRequired = 'Bitte gib einen Namen ein.';
  static String subjectPlantLabel = 'Pflanze wählen';
  static String gradeLabelPunkte = 'Punkte (0–15)';
  static String gradeLabelNoten = 'Note (1–6)';
  static String gradeLabelUni = 'Note (1,0–5,0)';
  static String gradeOptionalHint = 'Optional – du kannst sie später eintragen.';
  static String gradeInvalidPunkte = 'Bitte 0 bis 15 eingeben.';
  static String gradeInvalidNoten = 'Bitte 1 bis 6 eingeben.';
  static String gradeInvalidUni = 'Bitte 1,0 bis 5,0 eingeben.';
  static String creditsLabel = 'ECTS-Punkte';
  static String creditsHintField = 'z. B. 5';
  // Gewichtete Noten (Schule) → Zeugnisnote
  static String gradesSectionLabel = 'Noten';
  static String gradeKindSchulaufgabe = 'Schulaufgaben';
  static String gradeKindKurzarbeit = 'Kurzarbeiten';
  static String gradeKindEx = 'Exen';
  static String gradeKindMuendlich = 'Mündliche Noten';
  static String gradeWeightLabel = 'Gewicht';
  static String gradeWeightHint =
      'Schulaufgaben zählen standardmäßig doppelt (2:1). Gewicht pro Art anpassbar.';
  static String gradeAddChip = 'Note';
  static String gradeAddTitlePunkte = 'Punkte eintragen';
  static String gradeAddTitleNoten = 'Note eintragen';
  static String gradeAddButton = 'Hinzufügen';
  static String gradeRemoveTooltip = 'Note entfernen';
  static String finalGradeLabel = 'Zeugnisnote';
  static String finalGradeLabelUni = 'Modulnote';
  static String finalGradeNone = 'noch keine';
  static String subjectSave = 'Speichern';
  static String subjectDelete = 'Löschen';
  static String subjectDeleteTitle = 'Wirklich löschen?';
  static String subjectDeleteBody =
      'Das Fach und sein Fortschritt werden entfernt.';

  // Premium (Konzept Abschnitt 7)
  static String premiumTitle = 'Focus Garden Premium';
  static String premiumSubtitle =
      'Einmalig. Kein Abo. Keine Werbung. Keine Datensammlung.';
  static String premiumBenefitPlants = '6 zusätzliche Premium-Pflanzen';
  static String premiumBenefitStyles = 'Alle Flex-Card-Stile (Cozy & Neon)';
  static String premiumBenefitThemes = 'Alle Garten-Themes';
  static String premiumBuy = 'Freischalten';
  static String premiumPriceLoading = 'Preis wird geladen …';
  static String premiumRestore = 'Käufe wiederherstellen';
  static String premiumRestoreStarted = 'Suche nach früheren Käufen …';
  static String premiumRestored = 'Premium wiederhergestellt 💚';
  static String premiumCanceled = 'Kauf abgebrochen.';
  static String premiumError =
      'Kauf hat nicht geklappt. Bitte später erneut versuchen.';
  static String premiumUnavailable =
      'Der Store ist gerade nicht verfügbar. Bitte später erneut versuchen.';
  static String premiumActiveTitle = 'Premium ist aktiv 💚';
  static String premiumActiveBody = 'Danke, dass du Focus Garden unterstützt!';
  static String premiumClose = 'Schließen';
  static String premiumSection = 'Premium';
  static String premiumUpsell = 'Premium freischalten';
  static String premiumUpsellHint =
      'Alle Pflanzen, Stile & Themes – einmalig, ohne Abo.';
  static String premiumUnlockCta = 'Freischalten';
  static String debugTogglePremium = '[Debug] Premium umschalten';

  // Einstellungen
  static String settingsTitle = 'Einstellungen';
  static String sounds = 'Sounds';
  static String haptics = 'Haptik';
  static String strictMode = 'Strenger Modus';
  static String strictModeHint =
      'An: Verlässt du die App länger als 30 Sekunden, verwelkt die Pflanze. Aus: nur eine Warnung.';
  static String blocker = 'Andere Apps blockieren';
  static String blockerHint =
      'Verlässt du während einer Session die App, legt sich ein Vollbild-Hinweis über die andere App. Notfall-Abbruch bleibt immer möglich.';
  static String blockerPermNeeded =
      'Dafür brauchst du die Berechtigung „Über anderen Apps anzeigen".';
  static String blockerPermDenied =
      'Ohne diese Berechtigung lässt sich das Blockieren nicht einschalten.';
  static String appearance = 'Erscheinungsbild';

  // Fokus-Schild (Overlay über anderen Apps)
  static String shieldTitle = 'Bleib dran 🌱';
  static String shieldBody = 'Du bist im Fokus-Modus.\nZurück zum Lernen.';
  static String shieldResume = 'Zurück zur App';
  static String shieldAbort = 'Notfall: Session abbrechen';
  static String shieldAbortConfirm = 'Wirklich abbrechen? Pflanze stirbt 🥀';
  static String themeDark = 'Dunkel';
  static String themeLight = 'Hell';
  static String themeSystem = 'System';

  // Benachrichtigungen
  static String notifBloomTitle = 'Deine Pflanze ist erblüht 🌸';
  static String notifBloomBody =
      'Starke Fokus-Session! Schau sie dir im Garten an.';
  static String notifGrownTitle = 'Session geschafft 🌿';
  static String notifGrownBody =
      'Deine Pflanze ist ein Stück gewachsen. Bleib dran!';
  static String notifWarnTitle = 'Komm zurück! 🥀';
  static String notifWarnBody =
      'Deine Pflanze verwelkt, wenn du nicht in 30 Sekunden zurückkommst.';

  // Beste Lernzeit (pro Fach, für Lernplan & Erinnerungen)
  static String learnTimeLabel = 'Beste Lernzeit';
  static String learnTimeHint =
      'Zu dieser Tageszeit erinnert dich der Lernplan an dieses Fach.';
  static String learnMorgens = 'Morgens';
  static String learnMittags = 'Mittags';
  static String learnAbends = 'Abends';

  // Prüfungstermine (pro Fach)
  static String examsSectionLabel = 'Prüfungstermine';
  static String examsHint =
      'Der Lernplan erinnert dich rechtzeitig vor jedem Termin.';
  static String examAddChip = 'Termin';
  static String examAddTitle = 'Prüfung eintragen';
  static String examKindLabel2 = 'Art der Prüfung';
  static String examDateLabel = 'Datum';
  static String examPickDate = 'Datum wählen';
  static String examAddButton = 'Eintragen';
  static String examRemoveTooltip = 'Termin entfernen';
  static String examKindSchulaufgabe = 'Schulaufgabe';
  static String examKindKlausur = 'Klausur';
  static String examKindEx = 'Ex';
  static String examKindKurzarbeit = 'Kurzarbeit';
  static String examKindPraesentation = 'Präsentation';
  static String examRatedPrefix = 'Lief'; // z. B. „Lief 7/10"

  // Prüfungs-Feedback (nach dem Termin, 1–10)
  static String examFeedbackTitle = 'Wie lief deine Prüfung?';
  static String examFeedbackBody =
      '{art} in {fach} am {datum} – wie lief es (1 = schlecht, 10 = super)?';
  static String examFeedbackHint =
      'Deine Antwort passt den Lernplan an: lief es schwer, plant er dieses Fach öfter ein.';
  static String examFeedbackSave = 'Speichern';
  static String examFeedbackLater = 'Später';
  static String examFeedbackSkip = 'Ohne Bewertung';

  // Lernplan
  static String planTitle = 'Lernplan';
  static String planEmpty =
      'Trage bei deinen Fächern Prüfungstermine ein – dann plant Focus Garden, wann du wofür lernst.';
  static String planToday = 'Heute';
  static String planTomorrow = 'Morgen';
  static String planExamToday = 'Prüfung!';
  static String planDaysLeft = 'in {n} Tagen';
  static String planExport = 'In Kalender';
  static String planExportText =
      'Mein Lernplan aus Focus Garden 🌱 – Datei öffnen, um die Termine in deinen Kalender zu übernehmen.';
  static String planExportError = 'Export hat nicht geklappt.';
  static String planReminders = 'Lern-Erinnerungen';
  static String planRemindersHint =
      'Tägliche Erinnerung zur besten Lernzeit des wichtigsten Fachs.';
  static String planSuggestionPrefix = 'Heute dran:';

  // Pausen-Empfehlung
  static String breakTitle = 'Empfohlene Pause';
  static String breakBodyShort =
      '{n} Min frische Luft, Wasser trinken, kurz bewegen – dann läuft die nächste Session besser.';
  static String breakBodyLong =
      'Starke Leistung – Zeit für eine längere Pause ({n} Min). Dein Kopf braucht sie nach mehreren Sessions wirklich.';
  static String breakStart = 'Pause starten';
  static String breakRunning = 'Pause läuft …';
  static String breakSkip = 'Ohne Pause weiter';
  static String breakDone = 'Pause vorbei 🌱';

  // Benachrichtigungen: Lernplan & Pause
  static String notifStudyTitle = 'Zeit zum Lernen 📚';
  static String notifStudyBody =
      '{fach}: {art} {wann} – eine Fokus-Session jetzt zahlt sich aus!';
  static String notifExamTodayTitle = 'Heute: {art} in {fach}';
  static String notifExamTodayBody = 'Viel Erfolg! 🍀 Du hast dafür gelernt.';
  static String notifBreakOverTitle = 'Pause vorbei 🌱';
  static String notifBreakOverBody =
      'Frisch erholt? Starte deine nächste Fokus-Session.';

  // Lerntipps (fachspezifisch, Kategorie-Erkennung in utils/study_tips.dart)
  static String tipTitle = 'Lerntipp';
  static String tipNext = 'Nächster Tipp';
  static List<String> tipsMath = [
    'Mathe lernst du durch Rechnen, nicht durch Lesen – löse Aufgaben, ohne die Lösung daneben zu haben.',
    'Rechne alte Prüfungen unter Zeitdruck – so übst du genau den Ernstfall.',
    'Verstehst du eine Musterlösung, deck sie zu und rechne die Aufgabe direkt nochmal allein.',
    'Führe eine Fehlerliste: Jeder Fehler bekommt eine Zeile – vor der Prüfung gehst du nur noch die Liste durch.',
    'Hängst du fest, wechsle die Darstellung: Skizze zeichnen, Zahlen einsetzen, kleines Beispiel bauen.',
  ];
  static List<String> tipsGerman = [
    'Fasse jeden gelesenen Abschnitt in einem Satz zusammen – das ist die halbe Analyse.',
    'Übe Aufsätze mit Gliederung: erst Stichpunkte für Einleitung, Hauptteil und Schluss – dann schreiben.',
    'Lerne Fachbegriffe (Metapher, Ironie, Parallelismus …) mit einem eigenen Beispiel statt nur der Definition.',
    'Belege jede Aussage am Text: Behauptung, Zitat, Erklärung – dieses Muster bringt die Punkte.',
    'Lies deinen Übungsaufsatz einen Tag später laut – so findest du Stil- und Logikfehler selbst.',
  ];
  static List<String> tipsLanguage = [
    'Vokabeln in kleinen Portionen: 10 pro Tag schlagen 70 am Sonntag.',
    'Lerne Vokabeln in ganzen Sätzen und in beide Richtungen – dann sitzen sie auch im Aufsatz.',
    'Schau Serien oder Videos in der Sprache mit Untertiteln – Hörverstehen trainiert sich nebenbei.',
    'Sprich laut, auch mit dir selbst – eine Sprache lernst du durchs Benutzen.',
    'Schreibe kurze Texte (Tagebuch, Chat-Nachrichten) und baue neue Vokabeln sofort ein.',
  ];
  static List<String> tipsScience = [
    'Zeichne den Stoff: Skizzen, Kreisläufe und Diagramme bleiben besser hängen als Fließtext.',
    'Formeln nicht nur auswendig lernen – rechne zu jeder ein Beispiel, dann kannst du sie anwenden.',
    'Erkläre Experimente in drei Schritten: Aufbau, Beobachtung, Erklärung – genau so fragt die Prüfung.',
    'Lerne Fachbegriffe wie Vokabeln – oft scheitert es an der Sprache, nicht am Verständnis.',
    'Suche den Alltagsbezug: Wer erklären kann, warum die Scheibe beschlägt, hat den Stoff verstanden.',
  ];
  static List<String> tipsSociety = [
    'Baue Zeitstrahlen und Schaubilder – Zusammenhänge zählen mehr als Jahreszahlen.',
    'Stelle zu jedem Thema drei Fragen: Ursachen? Verlauf? Folgen? Das ist dein Grundgerüst.',
    'Erkläre das Thema in zwei Minuten wie eine Mini-Doku – was du erzählen kannst, sitzt.',
    'Übe Quellenarbeit: Wer schreibt hier, wann und mit welcher Absicht?',
    'Verknüpfe den Stoff mit aktuellen Nachrichten – Transferfragen lieben Beispiele.',
  ];
  static List<String> tipsInformatics = [
    'Programmieren lernst du durch Tippen: Übernimm Beispiele und verändere sie, bis du sie verstehst.',
    'Baue kleine eigene Projekte – ein Mini-Spiel lehrt mehr als drei Tutorials.',
    'Erkläre deinen Code Zeile für Zeile laut (Rubber-Duck-Methode) – Denkfehler fallen sofort auf.',
    'Skizziere den Ablauf erst auf Papier oder als Pseudocode, dann tippe ihn.',
    'Lies Fehlermeldungen bis zum Ende und stelle eine Vermutung auf, bevor du etwas änderst.',
  ];
  static List<String> tipsGeneral = [
    'Erkläre den Stoff laut in eigenen Worten – was du erklären kannst, hast du verstanden.',
    'Teste dich selbst statt nur zu lesen: Abfragen bringt mehr als Markieren.',
    'Wiederhole mit Abstand: heute, morgen, nächste Woche – so wandert der Stoff ins Langzeitgedächtnis.',
    'Leg das Handy in einen anderen Raum – allein die Sichtbarkeit kostet Konzentration.',
    'Starte mit der schwersten Aufgabe, solange dein Kopf frisch ist.',
  ];

  static List<String> weekdayShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  static List<String> monthNames = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
  ];

  /// Streak-Anzeige mit korrektem Singular/Plural („1 Tag", „7 Tage").
  static String streakDays(int n) {
    if (_english) return '$n ${n == 1 ? 'day' : 'days'}';
    return '$n ${n == 1 ? 'Tag' : 'Tage'}';
  }

  /// Anzeigename einer Prüfungs-Kategorie.
  static String examKind(ExamKind kind) {
    switch (kind) {
      case ExamKind.schulaufgabe:
        return examKindSchulaufgabe;
      case ExamKind.klausur:
        return examKindKlausur;
      case ExamKind.ex:
        return examKindEx;
      case ExamKind.kurzarbeit:
        return examKindKurzarbeit;
      case ExamKind.praesentation:
        return examKindPraesentation;
    }
  }

  /// Anzeigename einer Lernzeit.
  static String learnTime(LearnTime time) {
    switch (time) {
      case LearnTime.morgens:
        return learnMorgens;
      case LearnTime.mittags:
        return learnMittags;
      case LearnTime.abends:
        return learnAbends;
    }
  }

  /// Kurzes Datum – deutsch „15.07.", englisch „07/15".
  static String shortDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return _english ? '$month/$day' : '$day.$month.';
  }

  /// Englische Texte. Überschreibt JEDES Feld oben (Test wacht darüber).
  static void _applyEnglish() {
    appName = 'Focus Garden';

    tabFocus = 'Focus';
    tabGarden = 'Garden';
    tabStats = 'Stats';
    tabGrades = 'Grades';

    onboardSkip = 'Skip';
    onboardNext = 'Next';
    onboardStart = 'Let’s go';
    onboard1Title = 'Welcome to Focus Garden 🌱';
    onboard1Body =
        'Focus on one thing – and a plant grows with every minute of focus.';
    onboard2Title = 'Stay focused or it wilts';
    onboard2Body =
        'If you leave the app during a session, your plant wilts. That keeps you on task – in strict mode, changeable anytime.';
    onboard3Title = 'Collect & flex';
    onboard3Body =
        'Every bloomed plant joins your garden. Build streaks and share your Flex Card.';

    choosePlant = 'Choose your plant';
    chooseSubject = 'What are you working on?';
    chooseDuration = 'Focus duration';
    customDuration = 'Custom';
    minutesShort = 'min';
    start = 'Start';
    premiumLocked = 'Premium';
    focusNoSubjectTitle = 'No subject yet';
    focusNoSubjectBody =
        'Create a subject first – your plant grows on it across sessions.';
    focusNoSubjectButton = 'Create subject';
    focusNoSubjectTitleUni = 'No module yet';
    focusNoSubjectBodyUni =
        'Create a module first – your plant grows on it across sessions.';
    focusNoSubjectButtonUni = 'Create module';
    bloomProgressLabel = 'Until bloom';
    bloomedBadge = '🌸';
    bloomRemaining = '{n} min left until bloom';

    grows = 'is growing …';
    cancel = 'Cancel';
    cancelTitle = 'Are you sure?';
    cancelBody = 'Your plant will die 🥀';
    cancelConfirm = 'Yes, cancel';
    cancelKeep = 'Keep focusing';

    bloomedTitle = 'Bloomed! 🌸';
    bloomedBody = 'Your plant has moved into your garden.';
    grownTitle = 'Grown 🌿';
    grownBody = 'Your plant grew a little. Keep going until it blooms!';
    wiltedTitle = 'Wilted 🥀';
    wiltedBody = 'Not this time – your next try counts again.';
    backToGarden = 'Continue';
    keepGoing = 'Keep it up';
    tryAgain = 'Try again';

    stageSeed = 'Seed';
    stageSprout = 'Sprout';
    stagePlant = 'Plant';
    stageBloom = 'Bloom';

    gardenTitle = 'Your garden';
    gardenEmpty = 'No plants yet.\nStart your first focus session!';
    weekSummary = 'This week';
    plantsCount = 'Plants';
    createFlexCard = 'Create Flex Card';
    filterAll = 'All';

    gardenSetup = 'Customize';
    gardenSetupTitle = 'Customize garden';
    gardenNameLabel = 'Garden name';
    gardenNameHint = 'What should your garden be called?';
    gardenBackground = 'Background';
    gardenArrange = 'Arrange plants';
    gardenArrangeHint = 'Hold & drag to reorder.';
    gardenArrangeEmpty =
        'No plants to arrange yet – bloom some in focus first.';
    gardenThemeLocked = 'Premium';
    save = 'Done';

    sceneEntry = 'Design as wallpaper';
    sceneTitle = 'Garden scene';
    sceneHint = 'Drag plants & decor. Long-press decor to remove it.';
    sceneBackgroundLabel = 'Scene';
    sceneTimeDay = 'Day';
    sceneTimeSunset = 'Sunset';
    sceneTimeNight = 'Night';
    sceneAddDeco = 'Decor';
    sceneDecoTitle = 'Add decor';
    sceneDecoRemoved = 'Decor removed';
    sceneEmpty = 'No plants for the scene yet.\nBloom some in focus first.';
    sceneShare = 'Share';
    sceneShareText = 'My Focus Garden 🌱';
    sceneShareError = 'Sharing didn’t work.';
    sceneSetWallpaper = 'Set as wallpaper';
    sceneWallpaperSet = 'Set as wallpaper 🌱';
    sceneWallpaperError = 'Couldn’t set the wallpaper.';
    sceneReset = 'Rearrange';
    sceneBranding = '🌱 Focus Garden';

    flexTitle = 'Flex Card';
    flexWeekLabel = 'MY WEEK';
    flexMinutesLabel = 'Focus minutes';
    flexStreakLabel = 'day streak';
    flexPlantsLabel = 'Plants';
    flexRecentLabel = 'Recently planted';
    flexBranding = '🌱 Focus Garden · no subscription';
    flexShare = 'Share';
    flexShareText = 'My focus week with Focus Garden 🌱';
    flexShareError = 'Sharing didn’t work.';
    flexStyleDark = 'Dark';
    flexStyleCozy = 'Cozy';
    flexStyleNeon = 'Neon';

    statsTitle = 'Stats';
    today = 'Today';
    week = 'Week';
    total = 'Total';
    focusMinutes = 'Focus minutes';
    sessions = 'Sessions';
    streak = 'Streak';
    days = 'days';
    last7days = 'Last 7 days';

    gradesTitle = 'Grades';
    eduRoleLabel = 'I am …';
    eduSchueler = 'School student';
    eduStudent = 'University student';
    schoolTypeLabel = 'School type';
    schoolGymnasium = 'Gymnasium';
    schoolRealschule = 'Realschule';
    schoolHauptschule = 'Hauptschule';
    schoolGesamtschule = 'Gesamtschule';
    schoolFachschule = 'Fachschule';
    studiengangLabel = 'Degree program';
    studiengangHint = 'e.g. Computer Science B.Sc.';
    studienfaecherLabel = 'Study subjects (optional)';
    studienfaecherHint =
        'Studying several subjects (e.g. teaching degree)? Create them here '
        'and assign each module to one. Tap to rename a subject.';
    studienfachAddChip = 'Subject';
    studienfachAddTitle = 'Add study subject';
    studienfachAddHint = 'e.g. German';
    studienfachAddButton = 'Add';
    studienfachRenameTitle = 'Rename subject';
    studienfachRenameButton = 'Save';
    studienfachDuplicate = 'This subject already exists.';
    studienfachRemoveTooltip = 'Remove subject';
    studienfachRemoveTitle = 'Remove subject?';
    studienfachRemoveBody =
        'Its modules and grades are kept – they’ll show under “No subject”.';
    studienfachLabel = 'Study subject';
    studienfachNone = 'No subject';
    studienfachEmptyGroup = 'No modules in this subject yet.';
    gradingHintPunkte = 'Grading in points (0–15).';
    gradingHintNoten = 'Grading in marks (1–6).';
    gradingHintUni = 'University grades (1.0–5.0), ECTS-weighted.';
    subjectsSchool = 'Subjects';
    subjectsUni = 'Modules';
    subjectAddSchool = 'Add subject';
    subjectAddUni = 'Add module';
    subjectsEmptySchool = 'No subjects yet.\nCreate your first subject!';
    subjectsEmptyUni = 'No modules yet.\nCreate your first module!';
    subjectNoGrade = 'No grade';
    creditsShort = 'ECTS';
    averageLabel = 'Average';
    averageEmpty = 'Enter grades to see your average.';
    unitPoints = 'points';
    unitGrade = 'grade';
    creditsSumLabel = 'Total ECTS';
    uniPassed = 'passed';
    uniNotPassed = 'not passed';
    subjectNewSchool = 'New subject';
    subjectNewUni = 'New module';
    subjectEditSchool = 'Edit subject';
    subjectEditUni = 'Edit module';
    subjectNameLabel = 'Name';
    subjectNameHint = 'e.g. Math';
    subjectNameRequired = 'Please enter a name.';
    subjectPlantLabel = 'Choose a plant';
    gradeLabelPunkte = 'Points (0–15)';
    gradeLabelNoten = 'Mark (1–6)';
    gradeLabelUni = 'Grade (1.0–5.0)';
    gradeOptionalHint = 'Optional – you can add it later.';
    gradeInvalidPunkte = 'Please enter 0 to 15.';
    gradeInvalidNoten = 'Please enter 1 to 6.';
    gradeInvalidUni = 'Please enter 1.0 to 5.0.';
    creditsLabel = 'ECTS credits';
    creditsHintField = 'e.g. 5';
    gradesSectionLabel = 'Grades';
    gradeKindSchulaufgabe = 'Major tests';
    gradeKindKurzarbeit = 'Short tests';
    gradeKindEx = 'Pop quizzes';
    gradeKindMuendlich = 'Oral grades';
    gradeWeightLabel = 'Weight';
    gradeWeightHint =
        'Major tests count double by default (2:1). Weight adjustable per type.';
    gradeAddChip = 'Grade';
    gradeAddTitlePunkte = 'Enter points';
    gradeAddTitleNoten = 'Enter grade';
    gradeAddButton = 'Add';
    gradeRemoveTooltip = 'Remove grade';
    finalGradeLabel = 'Report grade';
    finalGradeLabelUni = 'Module grade';
    finalGradeNone = 'none yet';
    subjectSave = 'Save';
    subjectDelete = 'Delete';
    subjectDeleteTitle = 'Really delete?';
    subjectDeleteBody = 'The subject and its progress will be removed.';

    premiumTitle = 'Focus Garden Premium';
    premiumSubtitle =
        'One-time purchase. No subscription. No ads. No data collection.';
    premiumBenefitPlants = '6 additional premium plants';
    premiumBenefitStyles = 'All Flex Card styles (Cozy & Neon)';
    premiumBenefitThemes = 'All garden themes';
    premiumBuy = 'Unlock';
    premiumPriceLoading = 'Loading price …';
    premiumRestore = 'Restore purchases';
    premiumRestoreStarted = 'Looking for previous purchases …';
    premiumRestored = 'Premium restored 💚';
    premiumCanceled = 'Purchase canceled.';
    premiumError = 'Purchase didn’t work. Please try again later.';
    premiumUnavailable =
        'The store isn’t available right now. Please try again later.';
    premiumActiveTitle = 'Premium is active 💚';
    premiumActiveBody = 'Thanks for supporting Focus Garden!';
    premiumClose = 'Close';
    premiumSection = 'Premium';
    premiumUpsell = 'Unlock Premium';
    premiumUpsellHint =
        'All plants, styles & themes – one-time, no subscription.';
    premiumUnlockCta = 'Unlock';
    debugTogglePremium = '[Debug] Toggle premium';

    settingsTitle = 'Settings';
    sounds = 'Sounds';
    haptics = 'Haptics';
    strictMode = 'Strict mode';
    strictModeHint =
        'On: leaving the app for more than 30 seconds wilts your plant. Off: just a warning.';
    blocker = 'Block other apps';
    blockerHint =
        'If you leave the app during a session, a full-screen reminder covers the other app. Emergency cancel is always possible.';
    blockerPermNeeded =
        'This needs the “Display over other apps” permission.';
    blockerPermDenied =
        'Blocking can’t be enabled without this permission.';
    appearance = 'Appearance';

    shieldTitle = 'Stay focused 🌱';
    shieldBody = 'You’re in focus mode.\nBack to studying.';
    shieldResume = 'Back to the app';
    shieldAbort = 'Emergency: cancel session';
    shieldAbortConfirm = 'Really cancel? Your plant dies 🥀';
    themeDark = 'Dark';
    themeLight = 'Light';
    themeSystem = 'System';

    notifBloomTitle = 'Your plant has bloomed 🌸';
    notifBloomBody = 'Great focus session! Check it out in your garden.';
    notifGrownTitle = 'Session complete 🌿';
    notifGrownBody = 'Your plant grew a little. Keep going!';
    notifWarnTitle = 'Come back! 🥀';
    notifWarnBody =
        'Your plant will wilt if you don’t come back within 30 seconds.';

    learnTimeLabel = 'Best study time';
    learnTimeHint =
        'The study plan reminds you of this subject at this time of day.';
    learnMorgens = 'Morning';
    learnMittags = 'Midday';
    learnAbends = 'Evening';

    examsSectionLabel = 'Exam dates';
    examsHint = 'The study plan reminds you in time before each date.';
    examAddChip = 'Date';
    examAddTitle = 'Add exam';
    examKindLabel2 = 'Type of exam';
    examDateLabel = 'Date';
    examPickDate = 'Pick a date';
    examAddButton = 'Add';
    examRemoveTooltip = 'Remove date';
    examKindSchulaufgabe = 'Major test';
    examKindKlausur = 'Exam';
    examKindEx = 'Pop quiz';
    examKindKurzarbeit = 'Short test';
    examKindPraesentation = 'Presentation';
    examRatedPrefix = 'Went';

    examFeedbackTitle = 'How did your exam go?';
    examFeedbackBody =
        '{art} in {fach} on {datum} – how did it go (1 = bad, 10 = great)?';
    examFeedbackHint =
        'Your answer tunes the study plan: if it was hard, this subject gets scheduled more often.';
    examFeedbackSave = 'Save';
    examFeedbackLater = 'Later';
    examFeedbackSkip = 'No rating';

    planTitle = 'Study plan';
    planEmpty =
        'Add exam dates to your subjects – then Focus Garden plans when to study what.';
    planToday = 'Today';
    planTomorrow = 'Tomorrow';
    planExamToday = 'Exam!';
    planDaysLeft = 'in {n} days';
    planExport = 'To calendar';
    planExportText =
        'My study plan from Focus Garden 🌱 – open the file to add the dates to your calendar.';
    planExportError = 'Export didn’t work.';
    planReminders = 'Study reminders';
    planRemindersHint =
        'Daily reminder at the best study time of your most important subject.';
    planSuggestionPrefix = 'Up today:';

    breakTitle = 'Recommended break';
    breakBodyShort =
        '{n} min of fresh air, water, a bit of movement – the next session will go better.';
    breakBodyLong =
        'Great work – time for a longer break ({n} min). Your brain really needs it after several sessions.';
    breakStart = 'Start break';
    breakRunning = 'Break running …';
    breakSkip = 'Skip break';
    breakDone = 'Break’s over 🌱';

    notifStudyTitle = 'Time to study 📚';
    notifStudyBody =
        '{fach}: {art} {wann} – a focus session now pays off!';
    notifExamTodayTitle = 'Today: {art} in {fach}';
    notifExamTodayBody = 'Good luck! 🍀 You studied for this.';
    notifBreakOverTitle = 'Break’s over 🌱';
    notifBreakOverBody = 'Refreshed? Start your next focus session.';

    tipTitle = 'Study tip';
    tipNext = 'Next tip';
    tipsMath = [
      'You learn math by solving, not by reading – work through problems without the solution next to you.',
      'Do old exams under time pressure – it’s the closest thing to the real test.',
      'Once you understand a worked solution, cover it and solve the same problem again on your own.',
      'Keep an error list: every mistake gets one line – before the exam, practice only from that list.',
      'Stuck? Change the representation: draw a sketch, plug in numbers, build a small example.',
    ];
    tipsGerman = [
      'Summarize every section you read in one sentence – that is half the analysis.',
      'Practice essays with an outline: bullet points for intro, body and conclusion first – then write.',
      'Learn literary terms (metaphor, irony, parallelism …) with your own example instead of just the definition.',
      'Back up every claim with the text: statement, quote, explanation – that pattern earns you points.',
      'Read your practice essay out loud a day later – you will catch style and logic issues yourself.',
    ];
    tipsLanguage = [
      'Vocabulary in small doses: 10 words a day beat 70 on Sunday.',
      'Learn vocabulary in full sentences and in both directions – then it works in essays too.',
      'Watch shows or videos in the language with subtitles – your listening improves along the way.',
      'Speak out loud, even to yourself – you learn a language by using it.',
      'Write short texts (a diary, chat messages) and use new words right away.',
    ];
    tipsScience = [
      'Draw the material: sketches, cycles and diagrams stick better than plain text.',
      'Don’t just memorize formulas – work an example for each one, then you can apply it.',
      'Explain experiments in three steps: setup, observation, explanation – exams ask exactly that.',
      'Learn technical terms like vocabulary – many points are lost to language, not understanding.',
      'Find everyday connections: if you can explain why a window fogs up, you really understand the topic.',
    ];
    tipsSociety = [
      'Build timelines and diagrams – connections matter more than dates.',
      'Ask three questions about every topic: causes? course? consequences? That is your framework.',
      'Explain the topic in two minutes like a mini documentary – if you can retell it, you know it.',
      'Practice source analysis: who is writing, when, and with what intention?',
      'Link the material to current news – transfer questions love examples.',
    ];
    tipsInformatics = [
      'You learn coding by typing: take examples and change them until you understand them.',
      'Build small projects of your own – one mini game teaches more than three tutorials.',
      'Explain your code line by line out loud (rubber duck method) – logic errors surface fast.',
      'Sketch the flow on paper or as pseudocode first, then type it.',
      'Read error messages to the end and form a hypothesis before changing anything.',
    ];
    tipsGeneral = [
      'Explain the material out loud in your own words – what you can explain, you understand.',
      'Test yourself instead of rereading: active recall beats highlighting.',
      'Space your reviews: today, tomorrow, next week – that moves knowledge into long-term memory.',
      'Put your phone in another room – just seeing it costs focus.',
      'Start with the hardest task while your mind is fresh.',
    ];

    weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
  }
}
