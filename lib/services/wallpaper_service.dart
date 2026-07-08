import 'package:flutter/services.dart';

/// Setzt ein gerendertes Szenen-Bild als Handy-Hintergrund (Start- & Sperr-
/// bildschirm). Die eigentliche Arbeit macht die native Seite (`MainActivity`,
/// `WallpaperManager`) über den MethodChannel `focus_garden/wallpaper`.
///
/// Alle Aufrufe sind fehlertolerant: klappt es nicht, liefert die Methode
/// einfach `false`, und die UI zeigt einen freundlichen Hinweis.
class WallpaperService {
  static const MethodChannel _channel =
      MethodChannel('focus_garden/wallpaper');

  /// Legt die PNG-Datei unter [filePath] als System-Hintergrund fest.
  Future<bool> setWallpaper(String filePath) async {
    try {
      final ok = await _channel
          .invokeMethod<bool>('setWallpaper', {'path': filePath});
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }
}
