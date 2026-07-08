import 'package:flutter/foundation.dart';

/// Tageszeit einer Hintergrund-Szene. `name` ergibt exakt den Dateinamen-Teil
/// (`day`/`sunset`/`night`), passend zu `assets/backgrounds/<scene>_<time>.png`.
enum SceneTime { day, sunset, night }

SceneTime sceneTimeFromString(String s) => SceneTime.values
    .firstWhere((t) => t.name == s, orElse: () => SceneTime.day);

/// Eine wählbare Hintergrund-Szene der Garten-Szene (Wallpaper).
///
/// `procedural` = selbst gezeichnete Wiese (nutzt `MeadowBackground`, hat keine
/// Bilder und keine Tageszeiten). Die übrigen Szenen laden je Tageszeit ein
/// fertiges 1080×2400-PNG aus `assets/backgrounds/`.
@immutable
class SceneBackground {
  final String id;
  final String name;
  final bool procedural;

  const SceneBackground({
    required this.id,
    required this.name,
    this.procedural = false,
  });

  /// Asset-Pfad des Hintergrundbilds für die gegebene Tageszeit.
  String assetFor(SceneTime time) => 'assets/backgrounds/${id}_${time.name}.png';
}

/// Fester Katalog der Hintergrund-Szenen (gezeichnete Wiese gratis + 3 Bild-
/// Szenen). Die Bilder liefert der Nutzer (Fable-5-generiert) unter
/// `assets/backgrounds/`.
class SceneBackgrounds {
  static const meadow =
      SceneBackground(id: 'meadow', name: 'Wiese', procedural: true);
  static const greenhouse =
      SceneBackground(id: 'greenhouse', name: 'Gewächshaus');
  static const cottage = SceneBackground(id: 'cottage', name: 'Häuschen');
  static const forest = SceneBackground(id: 'forest', name: 'Wald');

  static const List<SceneBackground> all = [
    meadow,
    greenhouse,
    cottage,
    forest,
  ];

  static SceneBackground byId(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => greenhouse);
}
