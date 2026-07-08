import 'package:audioplayers/audioplayers.dart';

/// Spielt die drei kurzen UI-Sounds (Konzept Abschnitt 9: Start, Erfolg,
/// Verwelken – leise, abschaltbar).
///
/// Die An/Aus-Entscheidung trifft der Aufrufer (SessionProvider prüft
/// `settings.soundsOn`), damit die Logik an einer Stelle bleibt. Fehler beim
/// Abspielen werden bewusst verschluckt – ein fehlender Sound darf die App nie
/// stören.
class SoundService {
  final AudioPlayer _player = AudioPlayer(playerId: 'fx');

  Future<void> _play(String file, {double volume = 0.9}) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$file'), volume: volume);
    } catch (_) {
      // Sound ist optional – niemals eine Exception nach oben durchreichen.
    }
  }

  Future<void> playStart() => _play('start.wav');
  Future<void> playSuccess() => _play('success.wav');
  Future<void> playWilt() => _play('wilt.wav');

  Future<void> dispose() => _player.dispose();
}
