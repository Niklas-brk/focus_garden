import 'dart:io';

/// Zentrale Stelle für die Werbe-IDs (Konzept Abschnitt 7).
///
/// Bewusst NUR die offiziellen Google-Test-IDs. Erst kurz vor dem Launch
/// (Phase 4) durch die echten AdMob-IDs ersetzen – vorher würde echtes
/// Ausliefern von Anzeigen gegen die AdMob-Richtlinien verstoßen.
class AdIds {
  /// Test-Banner-Einheit von Google (funktioniert im Emulator).
  static String get banner {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    // iOS-Test-Banner (für später, App ist iOS-fähig gehalten).
    return 'ca-app-pub-3940256099942544/2934735716';
  }
}
