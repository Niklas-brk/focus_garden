# Backlog — Ideen & offene Entscheidungen (bewusst NICHT im aktuellen Scope)

Gesammelt bei der Phase-2/3-Fertigstellung am 2026-07-12. Nichts davon ist für
den v1.0-Release nötig.

## Offene Entscheidungen (bei Gelegenheit klären)

- **Strenger Modus per Prozess-Kill umgehbar:** Wer die App während einer
  strengen Session wegwischt und erst nach Ablauf wieder öffnet, bekommt vollen
  Erfolg statt Verwelken, weil `_pausedAt` nicht persistiert wird
  (`lib/state/session_provider.dart`, `_recover()`). Aktuell „im Zweifel für den
  Nutzer". Fix wäre: Verlassen-Zeitpunkt mit in Hive persistieren.
- **Flex-Card „Zuletzt gepflanzt":** nutzt die (ggf. manuell umsortierte)
  Garten-Reihenfolge, nicht zwingend die 6 zuletzt gesammelten Pflanzen
  (`flex_card_screen.dart` → `history.garden.take(6)`).
- **Onboarding-Skip auf Seite 3 ausgeblendet** — dort übernimmt der
  Start-Button. Falls „jederzeit überspringbar" gewünscht: Skip auch auf der
  letzten Seite zeigen.
- **Start-Tab nach App-Start ist „Noten"**, nicht „Fokus" (Konzept sah Fokus
  als Start-Tab vor). Prüfen, ob gewollt.

## Kleinkram / Code-Hygiene

- Veraltete Kommentare in `lib/models/plant.dart` (spricht noch von
  Platzhalter-Sprites und p01–p08; tatsächlich echte PNGs und p01–p10).
- Ungenutzte Felder `foliage`/`bloom` im `Plant`-Modell (Relikt der
  programmatischen Sprites).
- `SoundService.dispose()` wird nie aufgerufen (App-lebenslanger Service —
  unkritisch).
- `catch (_)` in `flex_card_screen._share()` verschluckt Fehlerdetails.

## Feature-Ideen (v1.1+)

- p09 Lavendel & p10 Tulpe sind bereits als Premium-Bonuspflanzen drin (über
  das Konzept hinaus) — im Store-Listing als „8+ Pflanzen" verkaufen oder für
  ein späteres Update zurückhalten.
- Homescreen-Widget (laut Konzept wichtigstes v1.1-Feature).
- Berlin-Skin-Pack als zweiter IAP (v1.1).
- Fokus-Sounds/Ambience (v1.2).
- Tags/Kategorien für Sessions (v1.2).
