import '../l10n/app_strings.dart';

/// Wachstumsstufen einer Pflanze während einer Session
/// (Konzept Abschnitt 2: Samen → Spross → Pflanze → Blüte).
class Growth {
  static const int stageCount = 4;

  /// Ordnet den Fortschritt (0.0–1.0) einer sichtbaren Stufe 1–4 zu.
  static int stageForProgress(double progress) {
    if (progress <= 0) return 1;
    final stage = (progress * stageCount).floor() + 1;
    return stage.clamp(1, stageCount);
  }

  static String stageName(int stage) {
    switch (stage) {
      case 1:
        return S.stageSeed;
      case 2:
        return S.stageSprout;
      case 3:
        return S.stagePlant;
      default:
        return S.stageBloom;
    }
  }
}
