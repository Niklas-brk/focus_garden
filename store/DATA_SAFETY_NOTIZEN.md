# Data-Safety-Formular (Play Console) – Antworten zum Abtippen

Stand: 2026-07-12 · Gilt für die werbefreie Version (kein AdMob, kein Tracking).

Play Console → **App-Inhalte → Datensicherheit**. So beantwortest du das Formular:

## Kernfragen

| Frage | Antwort |
|---|---|
| Erhebt oder teilt deine App die erforderlichen Nutzerdatentypen? | **Nein** |
| Werden Daten bei der Übertragung verschlüsselt? | Frage entfällt (keine Erhebung); falls doch gefragt: **Ja** |
| Können Nutzer die Löschung ihrer Daten beantragen? | Frage entfällt (keine Erhebung) |

**Begründung (falls Google nachfragt / für dich als Merkhilfe):**
- Alle App-Daten (Sessions, Pflanzen, Statistik, Noten, Einstellungen) liegen
  ausschließlich lokal auf dem Gerät, AES-verschlüsselt in Hive.
- Kein Konto, kein Server, keine Analyse-/Tracking-SDKs, keine Werbung.
- Die einzige Netzverbindung ist die Kaufabwicklung durch **Google Play Billing**
  selbst. Zahlungen wickelt Google als eigenständiger Verantwortlicher ab – das
  zählt im Data-Safety-Formular NICHT als Datenerhebung durch die App
  (offizielle Google-Ausnahme für Play Billing).

## Weitere Formulare unter „App-Inhalte"

| Formular | Antwort |
|---|---|
| Werbe-ID (Advertising ID) | **Nein**, die App verwendet keine Werbe-ID |
| Anzeigen (Ads) | **Nein**, die App enthält keine Anzeigen |
| Datenschutzerklärung | DE: https://niklas-brk.github.io/focus-garden/datenschutz.html · EN: https://niklas-brk.github.io/focus-garden/privacy.html |
| Inhaltsklassifizierung | Fragebogen ehrlich ausfüllen (Produktivität, keine bedenklichen Inhalte) → ergibt i. d. R. USK 0 / PEGI 3 |
| Zielgruppe | **13+** wählen (App richtet sich nicht an Kinder unter 13) |
| News-App? | Nein |
| Covid-Tracing/-Status? | Nein |
| Datenschutz-/Sicherheitspraktiken (Konto löschen) | Entfällt – es gibt keine Konten |

> Wichtig: Da `in_app_purchase` die Play-Billing-Library nutzt, KEINE
> Werbe-ID-Deklaration nötig. Sollte Google beim Review wegen der
> INTERNET-Berechtigung nachfragen: „Ausschließlich für Google Play Billing
> (Premium-Einmalkauf), keine weitere Netzwerkkommunikation."
