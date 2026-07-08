import 'package:flutter/material.dart';

/// Ein vom Nutzer platziertes Deko-Objekt in der Garten-Szene (z. B. 🍄 🦋 ⭐).
/// Als Emoji umgesetzt – bunt, ohne Extra-Bilder, funktioniert offline und
/// wird im exportierten Wallpaper mitgerendert.
@immutable
class SceneDecoration {
  final String id;
  final String emoji;
  final Offset pos; // normalisiert 0..1

  const SceneDecoration({
    required this.id,
    required this.emoji,
    required this.pos,
  });

  SceneDecoration copyWith({Offset? pos}) =>
      SceneDecoration(id: id, emoji: emoji, pos: pos ?? this.pos);

  Map<String, dynamic> toMap() =>
      {'id': id, 'emoji': emoji, 'x': pos.dx, 'y': pos.dy};

  factory SceneDecoration.fromMap(Map<String, dynamic> m) => SceneDecoration(
        id: m['id'] as String,
        emoji: m['emoji'] as String,
        pos: Offset((m['x'] as num).toDouble(), (m['y'] as num).toDouble()),
      );
}
