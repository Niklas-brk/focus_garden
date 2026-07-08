import 'dart:math';

import 'package:flutter/material.dart';

/// Selbst gezeichnete Konfetti-Explosion für den Erfolgs-Moment
/// (Konzept Abschnitt 9: „Erfolgs-Moment mit Konfetti-Partikeln + Haptik").
///
/// Bewusst ohne Zusatzpaket: Die Partikel fliegen aus der Bildmitte nach oben
/// auseinander und fallen mit „Schwerkraft" zurück. Die Animation läuft genau
/// einmal beim Einblenden (also beim Erblühen). Die passende Haptik löst der
/// [SessionProvider] aus, damit sie an das echte Ereignis gekoppelt ist.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    this.pieceCount = 90,
    this.duration = const Duration(milliseconds: 2400),
  });

  final int pieceCount;
  final Duration duration;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    _pieces = List.generate(widget.pieceCount, (_) => _Piece.random(rnd));
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Festliche Palette: App-Farben plus ein paar warme Party-Töne.
    final palette = <Color>[
      scheme.primary,
      scheme.secondary,
      const Color(0xFFF6C445), // Gold
      const Color(0xFFEF6F9B), // Pink
      const Color(0xFF6FC3EF), // Blau
      const Color(0xFFF2F0EB), // Creme
    ];

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            progress: _controller.value,
            seconds: widget.duration.inMilliseconds / 1000,
            pieces: _pieces,
            palette: palette,
          ),
        ),
      ),
    );
  }
}

/// Ein einzelnes Konfetti-Teilchen. Alle Werte sind normiert bzw. relativ zur
/// Fläche, damit die Animation auf jeder Bildschirmgröße gleich aussieht.
class _Piece {
  final double originDx; // 0..1 der Breite (Startpunkt der Explosion)
  final double originDy; // 0..1 der Höhe
  final double angle; // Abschusswinkel (-pi..0 = obere Hälfte)
  final double speed; // Anfangstempo (Höhenanteil pro Sekunde)
  final double size; // Kantenlänge in px
  final double startRotation;
  final double rotationSpeed;
  final double colorSeed; // 0..1 -> Index in der Palette
  final double delay; // 0..0.18 leichter Versatz
  final bool rect; // Rechteck (Band) oder Kreis

  const _Piece({
    required this.originDx,
    required this.originDy,
    required this.angle,
    required this.speed,
    required this.size,
    required this.startRotation,
    required this.rotationSpeed,
    required this.colorSeed,
    required this.delay,
    required this.rect,
  });

  factory _Piece.random(Random r) {
    return _Piece(
      // Explosion aus einem Band um die Bildmitte (dort steht die Pflanze).
      originDx: 0.4 + r.nextDouble() * 0.2,
      originDy: 0.38 + r.nextDouble() * 0.08,
      // Nach oben und zur Seite auseinander.
      angle: -pi / 2 + (r.nextDouble() - 0.5) * pi * 1.1,
      speed: 0.55 + r.nextDouble() * 0.95,
      size: 7 + r.nextDouble() * 6,
      startRotation: r.nextDouble() * pi * 2,
      rotationSpeed: (r.nextDouble() - 0.5) * 14,
      colorSeed: r.nextDouble(),
      delay: r.nextDouble() * 0.18,
      rect: r.nextBool(),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress; // 0..1 Fortschritt des Controllers
  final double seconds; // Gesamtdauer in Sekunden
  final List<_Piece> pieces;
  final List<Color> palette;

  _ConfettiPainter({
    required this.progress,
    required this.seconds,
    required this.pieces,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;
    final gravity = 2.3 * h; // px/s²

    for (final p in pieces) {
      final t = (progress - p.delay) / (1 - p.delay);
      if (t <= 0) continue;
      final s = t * seconds; // vergangene „Flugsekunden"

      final v = p.speed * h;
      final vx = cos(p.angle) * v * 0.7;
      final vy = sin(p.angle) * v;

      final x = p.originDx * w + vx * s;
      final y = p.originDy * h + vy * s + 0.5 * gravity * s * s;
      if (y > h + 40) continue;

      // Ein-/Ausblenden.
      double opacity;
      if (t < 0.05) {
        opacity = t / 0.05;
      } else if (t > 0.75) {
        opacity = (1 - t) / 0.25;
      } else {
        opacity = 1;
      }
      opacity = opacity.clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final color = palette[(p.colorSeed * palette.length).floor() %
          palette.length];
      paint.color = color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.startRotation + p.rotationSpeed * s);
      if (p.rect) {
        // Flatterndes Band: Breite pulsiert für einen 3D-Eindruck.
        final wobble = 0.35 + 0.65 * (0.5 + 0.5 * sin(s * 9 + p.startRotation));
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size * wobble,
            height: p.size * 0.5,
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}
