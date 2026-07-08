import 'package:flutter/services.dart';

/// Steuert das „Fokus-Schild": ein Vollbild-Overlay, das sich im Lernmodus über
/// andere Apps legt, wenn der Nutzer Focus Garden verlässt.
///
/// Das Overlay selbst ist NATIV (Kotlin, `MainActivity` + WindowManager) umgesetzt
/// – das ist deutlich robuster als ein Flutter-Overlay-Paket. Diese Klasse spricht
/// nur über einen MethodChannel mit der nativen Seite. Alle Aufrufe sind
/// fehlertolerant; klappt etwas nicht, greift einfach die normale Verwelk-Mechanik.
class BlockerService {
  static const MethodChannel _channel = MethodChannel('focus_garden/blocker');

  /// Verknüpft den „Notfall-Abbruch"-Knopf im Overlay mit der App-Logik.
  /// Die native Seite ruft `onAbort` auf, wenn der Nutzer im Overlay abbricht.
  void setAbortHandler(VoidCallback onAbort) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onAbort') onAbort();
      return null;
    });
  }

  Future<bool> hasPermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Öffnet die System-Einstellung „Über anderen Apps anzeigen". Liefert direkt
  /// zurück, ob das Recht (schon) erteilt ist – der Nutzer erteilt es ggf. danach.
  Future<bool> requestPermission() async {
    try {
      return await _channel.invokeMethod<bool>('requestPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> showShield() async {
    try {
      await _channel.invokeMethod('showShield');
    } catch (_) {}
  }

  Future<void> hideShield() async {
    try {
      await _channel.invokeMethod('hideShield');
    } catch (_) {}
  }

  /// Holt die App wieder in den Vordergrund (für den „Zurück"-Knopf im Overlay).
  Future<void> bringAppToFront() async {
    try {
      await _channel.invokeMethod('bringToForeground');
    } catch (_) {}
  }
}
