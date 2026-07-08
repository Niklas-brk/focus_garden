import 'dart:math';

import 'package:flutter/material.dart';

/// Prozedural gezeichnete Pixel-Wiese als Hintergrund der Garten-Szene
/// (Phase 3, Wallpaper). Bewusst selbst gemalt statt Stock-Bild – so bleibt
/// die App 100 % eigenständig und passt zum Cozy-Look.
///
/// Der Look ist deterministisch (fester Zufalls-Seed), damit sich beim
/// Neu-Zeichnen und beim Export nichts verändert.
class MeadowBackground extends StatelessWidget {
  const MeadowBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _MeadowPainter(), size: Size.infinite);
  }
}

class _MeadowPainter extends CustomPainter {
  const _MeadowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizon = h * 0.40;

    // --- Himmel -------------------------------------------------------------
    final skyRect = Rect.fromLTWH(0, 0, w, horizon + 1);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8FD3F0), Color(0xFFD9F1E6)],
        ).createShader(skyRect),
    );

    // --- Sonne (weicher Schein) --------------------------------------------
    final sun = Offset(w * 0.80, h * 0.12);
    canvas.drawCircle(sun, w * 0.17, Paint()..color = const Color(0x30FFF3C4));
    canvas.drawCircle(sun, w * 0.11, Paint()..color = const Color(0x55FFEFB0));
    canvas.drawCircle(sun, w * 0.065, Paint()..color = const Color(0xFFFFF3C9));

    // --- Wolken -------------------------------------------------------------
    final cloud = Paint()..color = const Color(0xF0FFFFFF);
    _cloud(canvas, Offset(w * 0.24, h * 0.11), w * 0.055, cloud);
    _cloud(canvas, Offset(w * 0.52, h * 0.19), w * 0.042, cloud);

    // --- Wiese (Grundfläche) ------------------------------------------------
    final grassRect = Rect.fromLTWH(0, horizon, w, h - horizon);
    canvas.drawRect(
      grassRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF88CC6D), Color(0xFF4C9B50)],
        ).createShader(grassRect),
    );

    // --- Sanfte Hügel für Tiefe --------------------------------------------
    _hill(canvas, Offset(w * 0.28, horizon), w * 0.62, h * 0.09,
        const Color(0xFF7BC061));
    _hill(canvas, Offset(w * 0.82, horizon), w * 0.55, h * 0.07,
        const Color(0xFF72B95A));

    // --- Grashalme (dunkle & helle Tupfer) ---------------------------------
    final rnd = Random(20240707);
    final bladeDark = Paint()
      ..color = const Color(0x3324611F)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final bladeLight = Paint()
      ..color = const Color(0x33D6F5B0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 170; i++) {
      final gx = rnd.nextDouble() * w;
      final gy = horizon + rnd.nextDouble() * (h - horizon);
      // Halme weiter unten (näher) etwas größer.
      final depth = (gy - horizon) / (h - horizon);
      final len = (2 + depth * 6) + rnd.nextDouble() * 3;
      final lean = (rnd.nextDouble() - 0.5) * 3;
      final p = rnd.nextBool() ? bladeDark : bladeLight;
      p.strokeWidth = 1 + depth * 1.5;
      canvas.drawLine(Offset(gx, gy), Offset(gx + lean, gy - len), p);
    }

    // --- Blümchen (Gänseblümchen + bunte Tupfer) ---------------------------
    for (var i = 0; i < 46; i++) {
      final fx = rnd.nextDouble() * w;
      final fy = horizon + h * 0.04 + rnd.nextDouble() * (h - horizon - h * 0.04);
      final depth = (fy - horizon) / (h - horizon);
      final r = (2.0 + depth * 3.0);
      final roll = rnd.nextDouble();
      if (roll < 0.6) {
        _daisy(canvas, Offset(fx, fy), r, Colors.white,
            const Color(0xFFF6C544));
      } else if (roll < 0.8) {
        _daisy(canvas, Offset(fx, fy), r, const Color(0xFFF6A6C8),
            const Color(0xFFF6C544));
      } else {
        // kleiner bunter Tupfer (Butterblume / Mohn)
        canvas.drawCircle(
          Offset(fx, fy),
          r * 0.7,
          Paint()
            ..color =
                rnd.nextBool() ? const Color(0xFFF7D14B) : const Color(0xFFE9583E),
        );
      }
    }
  }

  void _cloud(Canvas canvas, Offset c, double r, Paint p) {
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c + Offset(r * 0.9, r * 0.2), r * 0.8, p);
    canvas.drawCircle(c + Offset(-r * 0.9, r * 0.25), r * 0.72, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - r * 1.5, c.dy + r * 0.1, r * 3, r * 0.9),
        Radius.circular(r),
      ),
      p,
    );
  }

  void _hill(Canvas canvas, Offset center, double width, double height,
      Color color) {
    final rect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + height * 0.4),
      width: width,
      height: height * 2,
    );
    canvas.drawOval(rect, Paint()..color = color);
  }

  void _daisy(Canvas canvas, Offset c, double r, Color petal, Color center) {
    final pp = Paint()..color = petal;
    for (var k = 0; k < 5; k++) {
      final a = (k / 5) * 2 * pi - pi / 2;
      canvas.drawCircle(c + Offset(cos(a) * r, sin(a) * r), r * 0.7, pp);
    }
    canvas.drawCircle(c, r * 0.7, Paint()..color = center);
  }

  @override
  bool shouldRepaint(covariant _MeadowPainter oldDelegate) => false;
}
