import '../models/exam.dart';
import '../models/subject.dart';

/// Zentrale Textbausteine (Deutsch, primaer).
///
/// Alle sichtbaren Texte laufen ueber diese Klasse, damit spaeter leicht
/// Englisch ergaenzt werden kann (Konzept Abschnitt 8: Strings auslagern).
class S {
  // App
  static const appName = 'Focus Garden';

  // Navigation
  static const tabFocus = 'Fokus';
  static const tabGarden = 'Garten';
  static const tabStats = 'Statistik';
  static const tabGrades = 'Noten';

  // Onboarding (3 Screens, überspringbar – Konzept Abschnitt 3/4)
  static const onboardSkip = 'Überspringen';
  static const onboardNext = 'Weiter';
  static const onboardStart = 'Los geht’s';
  static const onboard1Title = 'Willkommen im Focus Garden 🌱';
  static const onboard1Body =
      'Konzentriere dich auf eine Sache – und eine Pflanze wächst mit jeder Minute Fokus.';
  static const onboard2Title = 'Bleib dran, sonst welkt sie';
  static const onboard2Body =
      'Verlässt du die App während der Session, verwelkt deine Pflanze. So bleibst du bei der Sache – im strengen Modus, jederzeit umstellbar.';
  static const onboard3Title = 'Sammle & flexe';
  static const onboard3Body =
      'Jede erblühte Pflanze wandert in deinen Garten. Baue Streaks auf und teile deine Flex-Card.';

  // Fokus-Screen
  static const choosePlant = 'Wähle deine Pflanze';
  static const chooseSubject = 'Woran arbeitest du?';
  static const chooseDuration = 'Fokusdauer';
  static const customDuration = 'Frei';
  static const minutesShort = 'Min';
  static const start = 'Starten';
  static const premiumLocked = 'Premium';
  // Leerzustand: erst ein Fach/Modul anlegen (Fokus läuft immer über ein Fach)
  static const focusNoSubjectTitle = 'Noch kein Fach';
  static const focusNoSubjectBody =
      'Lege zuerst ein Fach an – daran wächst deine Pflanze über mehrere Sessions.';
  static const focusNoSubjectButton = 'Fach anlegen';
  static const focusNoSubjectTitleUni = 'Noch kein Modul';
  static const focusNoSubjectBodyUni =
      'Lege zuerst ein Modul an – daran wächst deine Pflanze über mehrere Sessions.';
  static const focusNoSubjectButtonUni = 'Modul anlegen';
  // Blüh-Fortschritt (mehrstufige Blüte)
  static const bloomProgressLabel = 'Bis zur Blüte';
  static const bloomedBadge = '🌸'; // erblühte Pflanzen dieses Fachs
  static const bloomRemaining = 'Noch {n} Min bis zur Blüte';

  // Aktive Session
  static const grows = 'wächst gerade …';
  static const cancel = 'Abbrechen';
  static const cancelTitle = 'Bist du sicher?';
  static const cancelBody = 'Deine Pflanze stirbt 🥀';
  static const cancelConfirm = 'Ja, abbrechen';
  static const cancelKeep = 'Weiter fokussieren';

  // Ergebnis
  static const bloomedTitle = 'Erblüht! 🌸';
  static const bloomedBody = 'Deine Pflanze ist in den Garten gewandert.';
  static const grownTitle = 'Gewachsen 🌿';
  static const grownBody =
      'Deine Pflanze ist ein Stück gewachsen. Bleib dran bis zur Blüte!';
  static const wiltedTitle = 'Verwelkt 🥀';
  static const wiltedBody = 'Diesmal nicht geschafft – der nächste Versuch zählt wieder.';
  static const backToGarden = 'Weiter';
  static const keepGoing = 'Weiter so';
  static const tryAgain = 'Nochmal';

  // Wachstumsstufen
  static const stageSeed = 'Samen';
  static const stageSprout = 'Spross';
  static const stagePlant = 'Pflanze';
  static const stageBloom = 'Blüte';

  // Garten
  static const gardenTitle = 'Dein Garten';
  static const gardenEmpty = 'Noch keine Pflanzen.\nStarte deine erste Fokus-Session!';
  static const weekSummary = 'Diese Woche';
  static const plantsCount = 'Pflanzen';
  static const createFlexCard = 'Flex-Card erstellen';
  static const filterAll = 'Alle';

  // Garten einrichten
  static const gardenSetup = 'Einrichten';
  static const gardenSetupTitle = 'Garten einrichten';
  static const gardenNameLabel = 'Name des Gartens';
  static const gardenNameHint = 'Wie soll dein Garten heißen?';
  static const gardenBackground = 'Hintergrund';
  static const gardenArrange = 'Pflanzen anordnen';
  static const gardenArrangeHint = 'Halten & ziehen zum Umsortieren.';
  static const gardenArrangeEmpty =
      'Noch keine Pflanzen zum Anordnen – erblühe erst welche im Fokus.';
  static const gardenThemeLocked = 'Premium';
  static const save = 'Fertig';

  // Garten-Szene / Wallpaper (Pflanzen auf einer Wiese anordnen & exportieren)
  static const sceneEntry = 'Als Wallpaper gestalten';
  static const sceneTitle = 'Garten-Szene';
  static const sceneHint =
      'Ziehe Pflanzen & Deko. Deko lange drücken = entfernen.';
  // Szenen-/Tageszeit-Auswahl
  static const sceneBackgroundLabel = 'Szene';
  static const sceneTimeDay = 'Tag';
  static const sceneTimeSunset = 'Sonnenuntergang';
  static const sceneTimeNight = 'Nacht';
  // Deko
  static const sceneAddDeco = 'Deko';
  static const sceneDecoTitle = 'Deko hinzufügen';
  static const sceneDecoRemoved = 'Deko entfernt';
  static const sceneEmpty =
      'Noch keine Pflanzen für die Szene.\nErblühe erst welche im Fokus.';
  static const sceneShare = 'Teilen';
  static const sceneShareText = 'Mein Focus Garden 🌱';
  static const sceneShareError = 'Teilen hat nicht geklappt.';
  static const sceneSetWallpaper = 'Als Hintergrund';
  static const sceneWallpaperSet = 'Als Hintergrund festgelegt 🌱';
  static const sceneWallpaperError = 'Hintergrund konnte nicht gesetzt werden.';
  static const sceneReset = 'Neu anordnen';
  static const sceneBranding = '🌱 Focus Garden';

  // Flex-Card (Konzept Abschnitt 6)
  static const flexTitle = 'Flex-Card';
  static const flexWeekLabel = 'MEINE WOCHE';
  static const flexMinutesLabel = 'Fokusminuten';
  static const flexStreakLabel = 'Tage-Streak';
  static const flexPlantsLabel = 'Pflanzen';
  static const flexRecentLabel = 'Zuletzt gepflanzt';
  static const flexBranding = '🌱 Focus Garden · ohne Abo';
  static const flexShare = 'Teilen';
  static const flexShareText = 'Meine Fokus-Woche mit Focus Garden 🌱';
  static const flexShareError = 'Teilen hat nicht geklappt.';
  static const flexStyleDark = 'Dunkel';
  static const flexStyleCozy = 'Cozy';
  static const flexStyleNeon = 'Neon';

  // Statistik
  static const statsTitle = 'Statistik';
  static const today = 'Heute';
  static const week = 'Woche';
  static const total = 'Gesamt';
  static const focusMinutes = 'Fokusminuten';
  static const sessions = 'Sessions';
  static const streak = 'Streak';
  static const days = 'Tage';
  static const last7days = 'Letzte 7 Tage';

  // Noten (Schule/Studium)
  static const gradesTitle = 'Noten';
  // Profil-Karte
  static const eduRoleLabel = 'Ich bin …';
  static const eduSchueler = 'Schüler:in';
  static const eduStudent = 'Student:in';
  static const schoolTypeLabel = 'Schulart';
  static const schoolGymnasium = 'Gymnasium';
  static const schoolRealschule = 'Realschule';
  static const schoolHauptschule = 'Hauptschule';
  static const schoolGesamtschule = 'Gesamtschule';
  static const schoolFachschule = 'Fachschule';
  static const studiengangLabel = 'Studiengang';
  static const studiengangHint = 'z. B. Informatik B.Sc.';
  // Studienfächer (z. B. Lehramt: Deutsch + Reli, je mit eigenen Klausuren)
  static const studienfaecherLabel = 'Studienfächer (optional)';
  static const studienfaecherHint =
      'Studierst du mehrere Fächer (z. B. Lehramt)? Lege sie hier an und '
      'ordne jedes Modul einem Fach zu. Antippen benennt ein Fach um.';
  static const studienfachAddChip = 'Fach';
  static const studienfachAddTitle = 'Studienfach hinzufügen';
  static const studienfachAddHint = 'z. B. Deutsch';
  static const studienfachAddButton = 'Hinzufügen';
  static const studienfachRenameTitle = 'Fach umbenennen';
  static const studienfachRenameButton = 'Speichern';
  static const studienfachDuplicate = 'Dieses Fach gibt es schon.';
  static const studienfachRemoveTooltip = 'Fach entfernen';
  static const studienfachRemoveTitle = 'Fach entfernen?';
  static const studienfachRemoveBody =
      'Die zugeordneten Module und ihre Noten bleiben erhalten – sie stehen '
      'danach unter „Ohne Fach".';
  static const studienfachLabel = 'Studienfach';
  static const studienfachNone = 'Ohne Fach';
  static const studienfachEmptyGroup = 'Noch keine Module in diesem Fach.';
  static const gradingHintPunkte = 'Bewertung in Punkten (0–15).';
  static const gradingHintNoten = 'Bewertung in Noten (1–6).';
  static const gradingHintUni = 'Uni-Noten (1,0–5,0), ECTS-gewichtet.';
  // Fächer-Liste
  static const subjectsSchool = 'Fächer';
  static const subjectsUni = 'Module';
  static const subjectAddSchool = 'Fach hinzufügen';
  static const subjectAddUni = 'Modul hinzufügen';
  static const subjectsEmptySchool =
      'Noch keine Fächer.\nLege dein erstes Fach an!';
  static const subjectsEmptyUni =
      'Noch keine Module.\nLege dein erstes Modul an!';
  static const subjectNoGrade = 'Keine Note';
  static const creditsShort = 'ECTS';
  // Durchschnitt-Karte
  static const averageLabel = 'Durchschnitt';
  static const averageEmpty =
      'Trage Noten ein, um deinen Durchschnitt zu sehen.';
  static const unitPoints = 'Punkte';
  static const unitGrade = 'Note';
  static const creditsSumLabel = 'Summe ECTS';
  static const uniPassed = 'bestanden';
  static const uniNotPassed = 'nicht bestanden';
  // Fach anlegen/bearbeiten
  static const subjectNewSchool = 'Neues Fach';
  static const subjectNewUni = 'Neues Modul';
  static const subjectEditSchool = 'Fach bearbeiten';
  static const subjectEditUni = 'Modul bearbeiten';
  static const subjectNameLabel = 'Name';
  static const subjectNameHint = 'z. B. Mathe';
  static const subjectNameRequired = 'Bitte gib einen Namen ein.';
  static const subjectPlantLabel = 'Pflanze wählen';
  static const gradeLabelPunkte = 'Punkte (0–15)';
  static const gradeLabelNoten = 'Note (1–6)';
  static const gradeLabelUni = 'Note (1,0–5,0)';
  static const gradeOptionalHint = 'Optional – du kannst sie später eintragen.';
  static const gradeInvalidPunkte = 'Bitte 0 bis 15 eingeben.';
  static const gradeInvalidNoten = 'Bitte 1 bis 6 eingeben.';
  static const gradeInvalidUni = 'Bitte 1,0 bis 5,0 eingeben.';
  static const creditsLabel = 'ECTS-Punkte';
  static const creditsHintField = 'z. B. 5';
  // Gewichtete Noten (Schule) → Zeugnisnote
  static const gradesSectionLabel = 'Noten';
  static const gradeKindSchulaufgabe = 'Schulaufgaben';
  static const gradeKindKurzarbeit = 'Kurzarbeiten';
  static const gradeKindEx = 'Exen';
  static const gradeKindMuendlich = 'Mündliche Noten';
  static const gradeWeightLabel = 'Gewicht';
  static const gradeWeightHint =
      'Schulaufgaben zählen standardmäßig doppelt (2:1). Gewicht pro Art anpassbar.';
  static const gradeAddChip = 'Note';
  static const gradeAddTitlePunkte = 'Punkte eintragen';
  static const gradeAddTitleNoten = 'Note eintragen';
  static const gradeAddButton = 'Hinzufügen';
  static const gradeRemoveTooltip = 'Note entfernen';
  static const finalGradeLabel = 'Zeugnisnote';
  static const finalGradeLabelUni = 'Modulnote';
  static const finalGradeNone = 'noch keine';
  static const subjectSave = 'Speichern';
  static const subjectDelete = 'Löschen';
  static const subjectDeleteTitle = 'Wirklich löschen?';
  static const subjectDeleteBody =
      'Das Fach und sein Fortschritt werden entfernt.';

  // Premium (Konzept Abschnitt 7)
  static const premiumTitle = 'Focus Garden Premium';
  static const premiumSubtitle =
      'Einmal zahlen, für immer freigeschaltet – ohne Abo.';
  static const premiumBenefitPlants = '6 zusätzliche Premium-Pflanzen';
  static const premiumBenefitStyles = 'Alle Flex-Card-Stile (Cozy & Neon)';
  static const premiumBenefitNoAds = 'Keine Werbung mehr';
  static const premiumBuy = 'Freischalten';
  static const premiumPriceFallback = '1,99 €';
  static const premiumRestore = 'Käufe wiederherstellen';
  static const premiumRestoreStarted = 'Suche nach früheren Käufen …';
  static const premiumUnavailable =
      'Der Store ist gerade nicht verfügbar. Bitte später erneut versuchen.';
  static const premiumActiveTitle = 'Premium ist aktiv 💚';
  static const premiumActiveBody = 'Danke, dass du Focus Garden unterstützt!';
  static const premiumClose = 'Schließen';
  static const premiumSection = 'Premium';
  static const premiumUpsell = 'Premium freischalten';
  static const premiumUpsellHint = 'Alle Pflanzen & Stile, keine Werbung.';
  static const premiumUnlockCta = 'Freischalten';
  static const debugTogglePremium = '[Debug] Premium umschalten';

  // Einstellungen
  static const settingsTitle = 'Einstellungen';
  static const sounds = 'Sounds';
  static const haptics = 'Haptik';
  static const strictMode = 'Strenger Modus';
  static const strictModeHint =
      'An: Verlässt du die App länger als 30 Sekunden, verwelkt die Pflanze. Aus: nur eine Warnung.';
  static const blocker = 'Andere Apps blockieren';
  static const blockerHint =
      'Verlässt du während einer Session die App, legt sich ein Vollbild-Hinweis über die andere App. Notfall-Abbruch bleibt immer möglich.';
  static const blockerPermNeeded =
      'Dafür brauchst du die Berechtigung „Über anderen Apps anzeigen".';
  static const blockerPermDenied =
      'Ohne diese Berechtigung lässt sich das Blockieren nicht einschalten.';
  static const appearance = 'Erscheinungsbild';

  // Fokus-Schild (Overlay über anderen Apps)
  static const shieldTitle = 'Bleib dran 🌱';
  static const shieldBody = 'Du bist im Fokus-Modus.\nZurück zum Lernen.';
  static const shieldResume = 'Zurück zur App';
  static const shieldAbort = 'Notfall: Session abbrechen';
  static const shieldAbortConfirm = 'Wirklich abbrechen? Pflanze stirbt 🥀';
  static const themeDark = 'Dunkel';
  static const themeLight = 'Hell';
  static const themeSystem = 'System';

  // Benachrichtigungen
  static const notifBloomTitle = 'Deine Pflanze ist erblüht 🌸';
  static const notifBloomBody = 'Starke Fokus-Session! Schau sie dir im Garten an.';
  static const notifGrownTitle = 'Session geschafft 🌿';
  static const notifGrownBody =
      'Deine Pflanze ist ein Stück gewachsen. Bleib dran!';
  static const notifWarnTitle = 'Komm zurück! 🥀';
  static const notifWarnBody =
      'Deine Pflanze verwelkt, wenn du nicht in 30 Sekunden zurückkommst.';

  // Beste Lernzeit (pro Fach, für Lernplan & Erinnerungen)
  static const learnTimeLabel = 'Beste Lernzeit';
  static const learnTimeHint =
      'Zu dieser Tageszeit erinnert dich der Lernplan an dieses Fach.';
  static const learnMorgens = 'Morgens';
  static const learnMittags = 'Mittags';
  static const learnAbends = 'Abends';

  // Prüfungstermine (pro Fach)
  static const examsSectionLabel = 'Prüfungstermine';
  static const examsHint =
      'Der Lernplan erinnert dich rechtzeitig vor jedem Termin.';
  static const examAddChip = 'Termin';
  static const examAddTitle = 'Prüfung eintragen';
  static const examKindLabel2 = 'Art der Prüfung';
  static const examDateLabel = 'Datum';
  static const examPickDate = 'Datum wählen';
  static const examAddButton = 'Eintragen';
  static const examRemoveTooltip = 'Termin entfernen';
  static const examKindSchulaufgabe = 'Schulaufgabe';
  static const examKindKlausur = 'Klausur';
  static const examKindEx = 'Ex';
  static const examKindKurzarbeit = 'Kurzarbeit';
  static const examKindPraesentation = 'Präsentation';
  static const examRatedPrefix = 'Lief'; // z. B. „Lief 7/10"

  // Prüfungs-Feedback (nach dem Termin, 1–10)
  static const examFeedbackTitle = 'Wie lief deine Prüfung?';
  static const examFeedbackBody =
      '{art} in {fach} am {datum} – wie lief es (1 = schlecht, 10 = super)?';
  static const examFeedbackHint =
      'Deine Antwort passt den Lernplan an: lief es schwer, plant er dieses Fach öfter ein.';
  static const examFeedbackSave = 'Speichern';
  static const examFeedbackLater = 'Später';
  static const examFeedbackSkip = 'Ohne Bewertung';

  // Lernplan
  static const planTitle = 'Lernplan';
  static const planEmpty =
      'Trage bei deinen Fächern Prüfungstermine ein – dann plant Focus Garden, wann du wofür lernst.';
  static const planToday = 'Heute';
  static const planTomorrow = 'Morgen';
  static const planExamToday = 'Prüfung!';
  static const planDaysLeft = 'in {n} Tagen';
  static const planExport = 'In Kalender';
  static const planExportText =
      'Mein Lernplan aus Focus Garden 🌱 – Datei öffnen, um die Termine in deinen Kalender zu übernehmen.';
  static const planExportError = 'Export hat nicht geklappt.';
  static const planReminders = 'Lern-Erinnerungen';
  static const planRemindersHint =
      'Tägliche Erinnerung zur besten Lernzeit des wichtigsten Fachs.';
  static const planSuggestionPrefix = 'Heute dran:';

  // Pausen-Empfehlung
  static const breakTitle = 'Empfohlene Pause';
  static const breakBodyShort =
      '{n} Min frische Luft, Wasser trinken, kurz bewegen – dann läuft die nächste Session besser.';
  static const breakBodyLong =
      'Starke Leistung – Zeit für eine längere Pause ({n} Min). Dein Kopf braucht sie nach mehreren Sessions wirklich.';
  static const breakStart = 'Pause starten';
  static const breakRunning = 'Pause läuft …';
  static const breakSkip = 'Ohne Pause weiter';
  static const breakDone = 'Pause vorbei 🌱';

  // Benachrichtigungen: Lernplan & Pause
  static const notifStudyTitle = 'Zeit zum Lernen 📚';
  static const notifStudyBody = '{fach}: {art} {wann} – eine Fokus-Session jetzt zahlt sich aus!';
  static const notifExamTodayTitle = 'Heute: {art} in {fach}';
  static const notifExamTodayBody = 'Viel Erfolg! 🍀 Du hast dafür gelernt.';
  static const notifBreakOverTitle = 'Pause vorbei 🌱';
  static const notifBreakOverBody =
      'Frisch erholt? Starte deine nächste Fokus-Session.';

  static const weekdayShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  static const monthNames = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
  ];

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

  /// Kurzes deutsches Datum „15.07." – für Chips, Plan und Dialoge.
  static String shortDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.';
}
