# Focus Garden – Release-Checkliste (Play Store)

Stand: 2026-07-06 · App-Version **1.0.0 (versionCode 1)** · Ziel-API **36**, min-API **24**

Diese Liste ist für einen Anfänger geschrieben. Arbeite sie von oben nach unten ab.
Was **[erledigt]** ist, habe ich (Claude) schon im Code gemacht. Was **[du]** markiert
ist, musst du selbst in der Play Console / im Browser tun.

---

## 0. Das WICHTIGSTE zuerst – Schlüssel sichern  [du]

Ohne den Signierschlüssel kannst du die App **nie wieder aktualisieren**. Sichere BEIDES
an einem sicheren Ort (Passwort-Manager **und** ein Cloud-Backup):

- Datei: `focus_garden/android/upload-keystore.jks`
- Passwort (Store **und** Key): steht in `focus_garden/android/key.properties`
  (die Datei ist absichtlich **git-ignoriert** – zusätzlich in den Passwort-Manager!)
- Alias: `upload`
- Zertifikat-Fingerabdruck (SHA-256): `40:C8:24:C1:F8:AD:70:56:62:76:24:64:42:F2:77:68:1F:D8:B8:30:4B:DE:B0:22:EB:6B:0F:9D:1D:4A:FB:13`

> `key.properties` und der Keystore enthalten Geheimnisse im Klartext und gehören
> **niemals in ein Git-Repo** (auch kein privates) und nie in einen Chat/Screenshot.
> Backup beider Dateien liegt in `OneDrive\Projekte\focus_garden\android\`.

---

## 1. Bereits im Code erledigt  [erledigt]

- ✅ **App-Icon** (klassisch + adaptives Icon) aus dem Pflanzen-Motiv erzeugt und eingebaut.
- ✅ **Startbildschirm (Splash)**: dunkler Hintergrund (#14181B) mit Pflanze, auch für Android 12+.
- ✅ **Versionsnummer** gesetzt: `1.0.0+1` (Name 1.0.0, Build/Code 1).
- ✅ **Release-Signierung** eingerichtet (Upload-Keystore, Alias `upload`).
- ✅ **Signiertes App-Bundle gebaut** – die Datei, die du hochlädst:
  `focus_garden/build/app/outputs/bundle/release/app-release.aab`
- ✅ **Ziel-API 36 / min-API 24** – erfüllt die aktuelle Play-Store-Vorgabe (mind. API 35).
- ✅ **Store-Grafiken** erzeugt (in `focus_garden/store/`):
  - `icon_512.png` – App-Icon für den Store-Eintrag (512×512, Pflicht)
  - `feature_graphic_1024x500.png` – Feature-Grafik (Pflicht)
- ✅ **Fokus-Schild** (optionales App-Blockieren im Lernmodus) eingebaut. Nutzt die
  Berechtigung **„Über anderen Apps anzeigen" (SYSTEM_ALERT_WINDOW)**. Das ist eine
  normale Berechtigung – **sammelt keine Daten** und braucht **keine Sonder-Deklaration**
  in der Play Console (anders als eine Bedienungshilfe). Data-Safety-Angaben unverändert.

- ✅ **Sicherheits-Härtung** (2026-07-08):
  - Alle lokalen Hive-Daten sind **AES-256-verschlüsselt**; der Schlüssel liegt im
    **Android Keystore** (via flutter_secure_storage). Alt-Daten bestehender
    Installationen werden beim ersten Start automatisch verlustfrei migriert.
  - **R8/Minify + Ressourcen-Shrinking** im Release-Build aktiv (`build.gradle.kts`),
    Dart-Code wird zusätzlich mit `--obfuscate` verschleiert.

> Wenn du am Code noch etwas änderst, **vor jedem neuen Upload** die Build-Nummer erhöhen
> (in `pubspec.yaml` z. B. `1.0.1+2`) und neu bauen mit:
> ```
> flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
> ```
> Der Ordner `build/symbols` enthält die Zuordnung für verschleierte Crash-Stacktraces –
> pro Release-Version aufbewahren (z. B. zippen und zum OneDrive-Backup legen).

---

## 2. Noch offen im Code – vor der ÖFFENTLICHEN Veröffentlichung  [du entscheidest, ich baue ein]

Für den **geschlossenen Test** (Schritt 5) kannst du so wie es ist hochladen. Für die
**öffentliche** Produktions-Veröffentlichung müssen noch die Test-IDs raus:

- ⚠️ **AdMob**: Aktuell steckt die offizielle Google-**Test**-Werbe-ID in der App
  (in `AndroidManifest.xml` und `lib/services/ads.dart`). Vor Produktion:
  1. AdMob-Konto anlegen, App + Banner-Werbeblock erstellen.
  2. Mir die echte **App-ID** (`ca-app-pub-…~…`) und **Banner-ID** (`ca-app-pub-…/…`) geben –
     ich tausche sie an beiden Stellen aus.
  > Echte Ad-IDs erst kurz vor Produktion einsetzen, sonst riskierst du eine AdMob-Sperre.
- ⚠️ **In-App-Kauf**: Das Produkt `premium_unlock` muss in der Play Console angelegt werden
  (Schritt 6), sonst zeigt der Kaufscreen dauerhaft „Store nicht verfügbar".

---

## 3. Play-Entwicklerkonto anlegen  [du]

1. Gehe zu https://play.google.com/console und melde dich mit deinem Google-Konto an.
2. **Entwicklerkonto erstellen** (Typ: Privatperson), einmalige Gebühr **25 US-$**.
3. Identitätsprüfung durchführen (Ausweis/Adresse). Das kann 1–2 Tage dauern – **früh starten**.

---

## 4. App in der Play Console anlegen  [du]

1. In der Console: **App erstellen**.
2. App-Name: `Focus Garden`, Sprache: Deutsch, Typ: **App**, kostenlos.
3. Erklärungen bestätigen (Richtlinien, US-Exportgesetze).

Dann links im Menü **„Store-Eintrag"** ausfüllen (fertige Texte in Abschnitt 8):
- Kurzbeschreibung + ausführliche Beschreibung (Abschnitt 8)
- **App-Icon**: `store/icon_512.png` hochladen
- **Feature-Grafik**: `store/feature_graphic_1024x500.png` hochladen
- **Screenshots** (mind. 2 Handy-Screenshots Pflicht, 4–6 empfohlen) – siehe Abschnitt 9
- Kategorie: **Produktivität**, Kontakt-E-Mail: deine E-Mail
- Link zur **Datenschutzerklärung** (Abschnitt 7)

---

## 5. Data Safety, Werbe-ID, Inhalte, Zielgruppe  [du]

Unter **„App-Inhalte"** (Policy) diese Formulare ausfüllen:

### a) Datensicherheit (Data Safety) – empfohlene Antworten
- Erhebt/teilt deine App Nutzerdaten? → **Ja** (wegen der Werbung/AdMob).
- Erhobener Datentyp: **Geräte- oder andere IDs → Werbe-ID (Advertising ID)**.
  - Erhoben: **Ja**, Geteilt: **Ja** (mit Google/AdMob).
  - Zweck: **Werbung/Marketing**.
  - Erhebung optional? **Nein** (nötig für die Gratis-Werbung).
- Werden Daten bei der Übertragung verschlüsselt? → **Ja**.
- Können Nutzer Löschung beantragen? → **Nein** (kein Konto, keine Server – alles bleibt lokal auf dem Gerät).
- **Deine eigene App sammelt sonst nichts** (alle Fokus-/Garten-Daten liegen nur lokal per Hive).

### b) Werbe-ID (Advertising ID)
- Nutzt deine App die Werbe-ID? → **Ja** (AdMob).

### c) Anzeigen
- Enthält deine App Anzeigen? → **Ja** (Banner in der Gratis-Version).

### d) Inhaltsklassifizierung (Fragebogen)
- Kategorie App/Produktivität, keine Gewalt/kein anstößiger Inhalt → ergibt i. d. R. **USK 0 / PEGI 3**.

### e) Zielgruppe
- Zielalter: **ab 13** (bzw. 16/18) auswählen – **keine Altersgruppe unter 13**.
  > Wichtig: Sobald „unter 13" dabei ist, verbietet Google die Werbe-ID → dann funktioniert AdMob nicht.

---

## 6. In-App-Kauf `premium_unlock` anlegen  [du]

1. Play Console → **Monetarisierung → Produkte → In-App-Produkte**.
2. **Produkt erstellen**, Produkt-ID exakt: `premium_unlock` (Non-Consumable / Einmalkauf).
3. Name z. B. „Focus Garden Premium", Preis **1,99 €**.
4. Produkt **aktivieren**.
> Zum echten Kaufen-Testen musst du die App über den **geschlossenen Test** installieren und
> Test-Käufer (Lizenz-Tester) in der Console hinterlegen.

---

## 7. Datenschutzerklärung hosten  [du]

Der fertige Text liegt in `focus_garden/store/PRIVACY_POLICY_de.md`. Er muss unter einer
öffentlichen URL erreichbar sein. Einfachste Gratis-Wege:
- **GitHub Pages** (kostenlos) – sag mir Bescheid, ich richte das Repo + die Seite mit dir ein.
- Oder ein kostenloser Dienst wie telegra.ph / Google Sites.

Die URL trägst du im Store-Eintrag und im Data-Safety-Formular ein.

---

## 8. Fertige Store-Texte (zum Kopieren)

**Titel (≤30 Zeichen):**
```
Focus Garden – Fokus Timer
```

**Kurzbeschreibung (≤80 Zeichen):**
```
Lernen. Pflanze wachsen lassen. Flexen. Ohne Abo.
```

**Ausführliche Beschreibung:**
```
Focus Garden ist dein cozy Fokus-Timer – ohne Abo, ohne Konto, komplett offline.

So funktioniert's:
🌱 Dauer wählen (25/45/60/90 Min oder frei) und eine Pflanze aussäen.
⏳ Während du fokussiert bleibst, wächst deine Pixel-Pflanze in vier Stufen.
📵 Verlässt du die App, verwelkt sie – das hält dich beim Lernen.
🌸 Erfolgreiche Sessions wandern in deinen Garten.
🔥 Streak, Statistik und eine teilbare Flex-Card für deine Story.

Warum Focus Garden?
• Einmalkauf statt Abo-Falle
• 100 % offline – deine Daten bleiben auf deinem Gerät
• Cozy Pixel-Art, gemacht zum Angeben
• Kein nerviges App-Blocking, nur ein ehrlicher kleiner Fokus-Druck

Premium (Einmalkauf): zusätzliche Pflanzen, alle Flex-Card-Stile, keine Werbung.

Perfekt für Klausurenphase, Hausaufgaben, Deep Work und alle, die beim Lernen
gern das Handy weglegen.
```

**ASO-Keywords (in Beschreibung/Titel unterbringen):** fokus timer, pomodoro deutsch,
lern timer, konzentration app, study timer, forest alternative, produktivität ohne abo

---

## 9. Screenshots  [erledigt – bereit zum Hochladen]

Play verlangt **mindestens 2** Handy-Screenshots (empfohlen 4–6). Ich habe **6 fertige
Screenshots** im Emulator aufgenommen und store-fertig aufbereitet (1350×2400, 9:16,
erfüllt die Play-Vorgabe). Sie liegen in `focus_garden/store/screenshots/`:

1. `01_fokus.png` – Startbildschirm (Pflanze wählen, Dauer, Starten)
2. `02_session.png` – laufende Session (Timer + wachsende Pflanze)
3. `03_garten.png` – Garten mit gesammelten Pflanzen
4. `04_statistik.png` – Streak, Wochenbilanz, 7-Tage-Diagramm
5. `05_flexcard_neon.png` – teilbare Flex-Card (Stil Neon)
6. `06_flexcard_cozy.png` – teilbare Flex-Card (Stil Cozy)

> Diese Screenshots zeigen **Demo-Daten** (ein voller Garten + Statistik), die ich nur
> zum Fotografieren erzeugt habe – sie sind nicht Teil der echten App. Lade beim
> Store-Eintrag einfach alle 6 Dateien hoch (Reihenfolge = Dateiname).

---

## 10. Release hochladen & ausrollen  [du]

1. Play Console → **Test → Geschlossener Test** (empfohlen zuerst, wegen der 12-Tester-Regel).
2. **Neuen Release erstellen** → App-Bundle hochladen:
   `focus_garden/build/app/outputs/bundle/release/app-release.aab`
3. **Play App-Signierung** akzeptieren (Google verwaltet den finalen Signierschlüssel; deine
   `upload-keystore.jks` ist dein „Upload-Schlüssel").
4. Release-Notes eintragen, speichern, **zur Prüfung freigeben**.
5. **12 Tester** über eine E-Mail-Liste oder Google-Gruppe einladen; Google verlangt für neue
   Privatkonten oft **14 Tage geschlossenen Test mit ≥12 Testern**, bevor Produktion möglich ist.
6. Danach: **Produktion** → gleicher Ablauf, aber vorher Abschnitt 2 (echte AdMob-IDs) erledigen.

---

## 11. Manuelle To-dos aus dem Konzept (nicht delegierbar)  [du]

- [ ] Play-Entwicklerkonto (25 $) + Identitätsprüfung
- [ ] AdMob-Konto, echte App-ID + Banner-ID (erst kurz vor Produktion)
- [ ] 1–2 h auf echtem Gerät testen (Verwelk-Logik, Anruf, Neustart)
- [ ] 12 Tester für den geschlossenen Test organisieren
- [ ] Datenschutzerklärung hosten (Text liegt bereit)
- [ ] Reels/Marketing (Skripte kann ich liefern)
