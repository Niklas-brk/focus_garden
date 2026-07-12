# Focus Garden – CHECKLISTE für den Play-Store-Release

Stand: **2026-07-12** · App-Version **1.0.0 (versionCode 1)** · Ziel-API **36**, min-API **23**
Monetarisierung: **nur Premium-Einmalkauf** (`premium_unlock`) – **keine Werbung, kein Tracking**.

Diese Liste ist für einen Anfänger geschrieben. Arbeite sie von oben nach unten ab.
**[erledigt]** = ist schon im Code/Repo passiert. **[du]** = machst du in der Play Console / im Browser.

---

## 0. Das WICHTIGSTE zuerst – Schlüssel sichern  [du]

Ohne den Signierschlüssel kannst du die App **nie wieder aktualisieren**. Sichere BEIDES
an einem sicheren Ort (Passwort-Manager **und** ein Cloud-Backup):

- Datei: `focus_garden/android/upload-keystore.jks`
- Passwort (Store **und** Key): steht in `focus_garden/android/key.properties`
  (die Datei ist absichtlich **git-ignoriert** – zusätzlich in den Passwort-Manager!)
- Alias: `upload`
- Zertifikat-Fingerabdruck (SHA-256):
  `40:C8:24:C1:F8:AD:70:56:62:76:24:64:42:F2:77:68:1F:D8:B8:30:4B:DE:B0:22:EB:6B:0F:9D:1D:4A:FB:13`

> `key.properties` und der Keystore enthalten Geheimnisse im Klartext und gehören
> **niemals in ein Git-Repo** und nie in einen Chat/Screenshot.
> Backup beider Dateien liegt in `OneDrive\Projekte\focus_garden\android\`.

---

## 1. Bereits erledigt  [erledigt]

- ✅ **Werbung komplett entfernt** (kein google_mobile_ads, kein AdMob, keine Banner).
- ✅ **App-Icon** (klassisch + adaptiv), **Splash** (dunkel, auch Android 12+), **Version 1.0.0+1**.
- ✅ **Release-Signierung** (Upload-Keystore, Alias `upload`) + **R8/Minify + Ressourcen-Shrinking**,
  Dart-Obfuscation beim Build.
- ✅ **Hive-Daten AES-256-verschlüsselt** (Schlüssel im Android Keystore).
- ✅ **Zweisprachig**: Deutsch + Englisch vollständig (folgt der Gerätesprache;
  Test `l10n_completeness_test.dart` wacht über Vollständigkeit).
- ✅ **IAP `premium_unlock`**: lokalisierter Store-Preis (kein Hardcode), „Käufe
  wiederherstellen" in den Einstellungen, Fehlerfälle (Abbruch/offline/pending/bereits
  gekauft), Store-Abgleich beim App-Start.
- ✅ **Release-AAB gebaut**: `build/app/outputs/bundle/release/app-release.aab`
  (Ordner `build/symbols` pro Release aufbewahren – für entschlüsselbare Crash-Stacktraces).
- ✅ **Store-Grafiken** in `store/`: `icon_512.png`, `feature_graphic_1024x500.png`.
- ✅ **6 frische Screenshots** (aktuelle App, 1350×2400, 9:16) in `store/screenshots/`.
- ✅ **Datenschutzerklärung DE+EN** als HTML im Pages-Repo
  (`Niklas-brk.github.io/focus-garden/datenschutz.html` + `privacy.html`).
- ✅ **Data-Safety-Antworten** vorbereitet: `store/DATA_SAFETY_NOTIZEN.md`.

> Änderst du noch Code: **vor jedem neuen Upload** Build-Nummer erhöhen
> (`pubspec.yaml`, z. B. `1.0.1+2`) und neu bauen:
> ```
> flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
> ```

---

## 2. Play-Entwicklerkonto anlegen  [du]

1. https://play.google.com/console → mit Google-Konto anmelden.
2. **Entwicklerkonto erstellen** (Typ: Privatperson), einmalig **25 US-$**.
3. Identitätsprüfung (Ausweis/Adresse) durchführen – dauert 1–2 Tage, **früh starten**.

---

## 3. App anlegen & Store-Eintrag  [du]

1. Console → **App erstellen**: Name `Focus Garden`, Standardsprache **Deutsch**,
   Typ **App**, **kostenlos**. Erklärungen bestätigen.
2. **Hauptsprache Deutsch** ausfüllen (Texte in Abschnitt 7), dann unter
   „Übersetzungen verwalten" **Englisch (en-US)** hinzufügen (Texte in Abschnitt 8).
3. Hochladen: App-Icon `store/icon_512.png`, Feature-Grafik
   `store/feature_graphic_1024x500.png`, alle 6 Screenshots aus `store/screenshots/`
   (Reihenfolge = Dateiname).
4. Kategorie **Produktivität**, Kontakt-E-Mail: niklasbaericke@gmail.com.
5. Datenschutzerklärung-URL: `https://niklas-brk.github.io/focus-garden/datenschutz.html`

---

## 4. App-Inhalte (Policy-Formulare)  [du]

Alle Antworten stehen fertig in **`store/DATA_SAFETY_NOTIZEN.md`** – Kurzfassung:

- **Datensicherheit**: „Erhebt oder teilt deine App Nutzerdaten?" → **Nein**
  (alles lokal, verschlüsselt; Play Billing zählt nicht als Erhebung).
- **Werbe-ID**: **Nein**. · **Anzeigen**: **Nein**.
- **Inhaltsklassifizierung**: Fragebogen → i. d. R. USK 0 / PEGI 3.
- **Zielgruppe**: **13+** (nicht „unter 13" wählen).

---

## 5. In-App-Produkt `premium_unlock` anlegen  [du]

1. Console → **Monetarisierung → Produkte → In-App-Produkte** → **Produkt erstellen**.
2. Produkt-ID **exakt**: `premium_unlock` (Einmalkauf / Non-Consumable).
3. Name: „Focus Garden Premium". Beschreibung z. B. „Alle Pflanzen, Flex-Card-Stile
   und Garten-Themes – einmalig, für immer."
4. **Basispreis: 2,99 €** festlegen → Preise für alle Länder automatisch berechnen lassen.
5. Produkt **aktivieren**.

> Solange das Produkt nicht angelegt/aktiv ist (oder die App nicht über Play
> installiert wurde), zeigt der Kaufscreen „Store nicht verfügbar" bzw.
> „Preis wird geladen …". Das ist erwartetes Verhalten, kein Bug.

### Launch-Sale 1,99 € einrichten (nach dem Produktions-Release)

1. Console → **Monetarisierung → Produkte → In-App-Produkte** → `premium_unlock` öffnen.
2. **Preisänderung/Angebot**: neuen Preis **1,99 €** mit Start- und Enddatum anlegen
   (z. B. 2 Wochen „Launch-Sale"). Danach springt der Preis automatisch auf 2,99 € zurück.
3. Der Sale-Preis erscheint in der App automatisch – sie zeigt IMMER den vom Store
   gelieferten lokalisierten Preis an, nichts ist hardcodiert.

---

## 6. Geschlossener Test → Produktion  [du]

1. Console → **Test → Geschlossener Test** → **Neuen Release erstellen**.
2. AAB hochladen: `focus_garden/build/app/outputs/bundle/release/app-release.aab`.
3. **Play App-Signierung** akzeptieren (Google verwaltet den finalen Schlüssel;
   dein `upload-keystore.jks` ist nur der Upload-Schlüssel).
4. Release-Notes (kurz, DE reicht), speichern, **zur Prüfung freigeben**.
5. **Tester einladen**: E-Mail-Liste oder Google-Gruppe anlegen, Opt-in-Link teilen.
   Google verlangt für neue Privatkonten: **mind. 12 Tester, 14 Tage ununterbrochen**
   im geschlossenen Test, bevor Produktion beantragt werden kann.
6. **Lizenz-Tester** für kostenlose Testkäufe: Console (oberste Ebene) →
   **Einstellungen → Lizenz-Tests** → deine + Tester-Gmail-Adressen eintragen.
   Diese können den IAP durchspielen, ohne echtes Geld zu zahlen.
7. Nach 14 Tagen + Kriterien erfüllt: **Produktion → Release erstellen** (gleiches AAB
   oder neuer Build) → ausrollen. Danach den **Launch-Sale** (Abschnitt 5) schalten.

---

## 7. Store-Texte DEUTSCH (Copy-Paste)  [du]

**Titel (≤30 Zeichen):**
```
Focus Garden – Fokus Timer
```

**Kurzbeschreibung (≤80 Zeichen):**
```
Lernen. Pflanze wachsen lassen. Flexen. Ohne Abo, ohne Werbung.
```

**Ausführliche Beschreibung:**
```
Focus Garden ist dein cozy Fokus-Timer – ohne Abo, ohne Werbung, ohne Konto, komplett offline.

So funktioniert's:
🌱 Fach wählen, Dauer festlegen (25/45/60/90 Min oder frei) und losfokussieren.
⏳ Während du dranbleibst, wächst deine Pixel-Pflanze Stufe für Stufe.
📵 Verlässt du die App, verwelkt sie – das hält dich ehrlich beim Lernen.
🌸 Erblühte Pflanzen wandern in deinen Garten.
🔥 Streak, Statistik und eine teilbare Flex-Card für deine Story.
📚 Noten & Prüfungen: Trage Termine ein und lass dir einen Lernplan bauen.

Warum Focus Garden?
• Einmalkauf statt Abo-Falle
• Keine Werbung, kein Tracking, keine Datensammlung
• 100 % offline – deine Daten bleiben auf deinem Gerät
• Cozy Pixel-Art, gemacht zum Angeben
• Kein aggressives App-Blocking, nur ein ehrlicher kleiner Fokus-Druck

Premium (Einmalkauf): 6 zusätzliche Pflanzen, alle Flex-Card-Stile, alle Garten-Themes.

Perfekt für Klausurenphase, Hausaufgaben, Deep Work und alle, die beim Lernen
gern das Handy weglegen. Fokus Timer, Pomodoro-Alternative und Lern-Timer in einem.
```

---

## 8. Store-Texte ENGLISCH (Copy-Paste)  [du]

**Title (≤30 chars):**
```
Focus Garden – Focus Timer
```

**Short description (≤80 chars):**
```
Study. Grow a plant. Flex. No subscription, no ads.
```

**Full description:**
```
Focus Garden is your cozy focus timer – no subscription, no ads, no account, fully offline.

How it works:
🌱 Pick a subject, set a duration (25/45/60/90 min or custom) and start focusing.
⏳ While you stay on task, your pixel plant grows stage by stage.
📵 Leave the app and it wilts – keeping you honest while you study.
🌸 Bloomed plants join your garden.
🔥 Streaks, stats, and a shareable Flex Card for your story.
📚 Grades & exams: add your dates and get a personal study plan.

Why Focus Garden?
• One-time purchase instead of a subscription trap
• No ads, no tracking, no data collection
• 100% offline – your data stays on your device
• Cozy pixel art, made to show off
• No aggressive app blocking, just honest gentle focus pressure

Premium (one-time purchase): 6 extra plants, all Flex Card styles, all garden themes.

Perfect for exam season, homework, deep work, and anyone who wants to put
their phone away while studying. Focus timer, pomodoro alternative, and study
timer in one.
```

---

## 9. Screenshots (bereit zum Hochladen)  [erledigt]

6 frische Screenshots der **aktuellen** App (ohne Werbung, mit Noten-Tab), Demo-Daten,
1350×2400 (9:16), in `focus_garden/store/screenshots/`:

1. `01_fokus.png` – Fokus-Tab (Fach, Dauer-Auswahl, Starten)
2. `02_session.png` – laufende Session (Timer-Ring + Pflanze)
3. `03_garten.png` – Garten mit 8 gesammelten Pflanzen
4. `04_statistik.png` – Streak, Kennzahlen, 7-Tage-Diagramm
5. `05_flexcard_neon.png` – Flex-Card im Neon-Stil
6. `06_flexcard_cozy.png` – Flex-Card im Cozy-Stil

> Die Screenshots zeigen Demo-Daten (Debug-Werkzeug „Beispieldaten laden"),
> die nicht Teil eines echten Nutzerprofils sind.

---

## 10. Manuelle To-dos (nicht delegierbar)  [du]

- [ ] Play-Entwicklerkonto (25 $) + Identitätsprüfung
- [ ] Pages-Repo gepusht? Datenschutz-URLs im Browser prüfen (DE + EN erreichbar)
- [ ] 1–2 h auf **echtem Gerät** testen: Verwelk-Logik (Handy weglegen, Anruf
      simulieren, Neustart), Sounds/Haptik, Notifications
- [ ] IAP auf echtem Gerät testen (App über geschlossenen Test installieren,
      Lizenz-Tester: Kauf, Abbruch, „Käufe wiederherstellen", Neuinstallation)
- [ ] 12 Tester organisieren (Freunde + Reddit-Testing-Communities)
- [ ] Nach Produktions-Freigabe: Launch-Sale 1,99 € schalten (Abschnitt 5)
- [ ] Reels/Marketing (Skripte kann Claude liefern)
