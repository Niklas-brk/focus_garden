import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_strings.dart';
import '../../models/focus_session.dart';
import '../../models/plant_catalog.dart';
import '../../models/scene_background.dart';
import '../../models/scene_decoration.dart';
import '../../state/history_provider.dart';
import '../../state/settings_provider.dart';
import '../../services/wallpaper_service.dart';
import '../../widgets/meadow_scene.dart';
import '../../widgets/plant_sprite.dart';

/// Garten-Szene: Pflanzen und Deko frei auf einer wählbaren Hintergrund-Szene
/// (Wiese/Gewächshaus/Häuschen/Wald, je Tag/Sonnenuntergang/Nacht) anordnen und
/// als Bild teilen oder als Handy-Hintergrund setzen (Phase 3).
///
/// Feste logische Größe 360×800; Export über RepaintBoundary → 1080×2400-PNG.
class GardenSceneScreen extends StatefulWidget {
  const GardenSceneScreen({super.key});

  @override
  State<GardenSceneScreen> createState() => _GardenSceneScreenState();
}

class _GardenSceneScreenState extends State<GardenSceneScreen> {
  static const double _sceneW = 360;
  static const double _sceneH = 800; // 9:20 -> 1080×2400
  static const double _spriteSize = 96;

  static const List<String> _decoEmojis = [
    '🍄', '🦋', '🌸', '🌷', '🌻', '🌼', '🍀', '🌿',
    '🪨', '🕯️', '🏮', '⭐', '🌙', '🐞', '🐝', '🐌',
    '🐰', '🦔', '🍁', '🍂', '🐚', '✨', '💧', '🌈',
  ];

  final GlobalKey _sceneKey = GlobalKey();
  final WallpaperService _wallpaper = WallpaperService();
  final Set<String> _precached = {};

  late List<FocusSession> _plants;
  final Map<String, Offset> _positions = {}; // Pflanzen, normalisiert 0..1
  late List<SceneDecoration> _decorations;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final history = context.read<HistoryProvider>();
    _plants = List.of(history.garden);
    _decorations = List.of(history.decorations);
    final saved = history.scenePositions;
    for (final s in _plants) {
      _positions[s.id] = saved[s.id] ?? _defaultPos(s.id);
    }
  }

  /// Stabile Streu-Position, falls eine Pflanze noch nie angeordnet wurde.
  Offset _defaultPos(String id) {
    final r = Random(id.hashCode);
    return Offset(0.14 + r.nextDouble() * 0.72, 0.55 + r.nextDouble() * 0.38);
  }

  void _persistPositions() {
    context.read<HistoryProvider>().setScenePositions(_positions);
  }

  void _persistDecorations() {
    context.read<HistoryProvider>().setDecorations(_decorations);
  }

  void _reset() {
    setState(() {
      for (final s in _plants) {
        _positions[s.id] = _defaultPos(s.id);
      }
    });
    _persistPositions();
  }

  void _precache(SceneBackground scene, SceneTime time) {
    if (scene.procedural) return;
    final path = scene.assetFor(time);
    if (_precached.add(path)) {
      precacheImage(AssetImage(path), context);
    }
  }

  // ---- Deko ----------------------------------------------------------------

  void _addDeco(String emoji) {
    final deco = SceneDecoration(
      id: 'd${DateTime.now().microsecondsSinceEpoch}',
      emoji: emoji,
      pos: const Offset(0.5, 0.42),
    );
    setState(() => _decorations.add(deco));
    _persistDecorations();
  }

  void _dragDeco(String id, double dxNorm, double dyNorm) {
    final i = _decorations.indexWhere((d) => d.id == id);
    if (i < 0) return;
    final cur = _decorations[i].pos;
    final np = Offset(
      (cur.dx + dxNorm).clamp(0.03, 0.97),
      (cur.dy + dyNorm).clamp(0.03, 0.97),
    );
    setState(() => _decorations[i] = _decorations[i].copyWith(pos: np));
  }

  void _removeDeco(String id) {
    setState(() => _decorations.removeWhere((d) => d.id == id));
    _persistDecorations();
    _toast(S.sceneDecoRemoved);
  }

  void _openDecoSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.sceneDecoTitle,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final e in _decoEmojis)
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _addDeco(e);
                        Navigator.of(sheetCtx).pop();
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Export --------------------------------------------------------------

  Future<File?> _renderToFile(SceneBackground scene, SceneTime time) async {
    // Sicherstellen, dass das Hintergrundbild dekodiert ist, bevor gerendert
    // wird – sonst könnte das PNG ohne Hintergrund exportiert werden.
    if (!scene.procedural) {
      await precacheImage(AssetImage(scene.assetFor(time)), context);
    }
    final boundary =
        _sceneKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final pixelRatio = 1080 / boundary.size.width;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    final bytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/focus_garden_scene.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _share() async {
    if (_busy) return;
    final settings = context.read<SettingsProvider>();
    final scene = SceneBackgrounds.byId(settings.sceneBackgroundId);
    setState(() => _busy = true);
    try {
      final file = await _renderToFile(scene, settings.sceneTime);
      if (file == null) throw Exception('render failed');
      await Share.shareXFiles([XFile(file.path)], text: S.sceneShareText);
    } catch (_) {
      _toast(S.sceneShareError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setAsWallpaper() async {
    if (_busy) return;
    final settings = context.read<SettingsProvider>();
    final scene = SceneBackgrounds.byId(settings.sceneBackgroundId);
    setState(() => _busy = true);
    try {
      final file = await _renderToFile(scene, settings.sceneTime);
      if (file == null) throw Exception('render failed');
      final ok = await _wallpaper.setWallpaper(file.path);
      _toast(ok ? S.sceneWallpaperSet : S.sceneWallpaperError);
    } catch (_) {
      _toast(S.sceneWallpaperError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final scene = SceneBackgrounds.byId(settings.sceneBackgroundId);
    final time = settings.sceneTime;

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.sceneTitle),
        actions: [
          if (_plants.isNotEmpty) ...[
            IconButton(
              tooltip: S.sceneAddDeco,
              onPressed: _busy ? null : _openDecoSheet,
              icon: const Icon(Icons.auto_awesome_rounded),
            ),
            IconButton(
              tooltip: S.sceneReset,
              onPressed: _busy ? null : _reset,
              icon: const Icon(Icons.shuffle_rounded),
            ),
          ],
        ],
      ),
      body: _plants.isEmpty
          ? _EmptyScene()
          : SafeArea(
              child: Column(
                children: [
                  _buildPickers(scene, time),
                  Expanded(child: _buildScene(scene, time, settings.gardenName)),
                  _buildActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildPickers(SceneBackground scene, SceneTime time) {
    final settings = context.read<SettingsProvider>();
    return Column(
      children: [
        // Szenen-Auswahl
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final s in SceneBackgrounds.all)
                _PickChip(
                  label: s.name,
                  selected: s.id == scene.id,
                  onTap: () {
                    settings.sceneBackgroundId = s.id;
                    _precache(s, time);
                  },
                ),
            ],
          ),
        ),
        // Tageszeit (nur bei Bild-Szenen)
        if (!scene.procedural)
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _PickChip(
                  label: S.sceneTimeDay,
                  icon: Icons.wb_sunny_rounded,
                  selected: time == SceneTime.day,
                  onTap: () {
                    settings.sceneTime = SceneTime.day;
                    _precache(scene, SceneTime.day);
                  },
                ),
                _PickChip(
                  label: S.sceneTimeSunset,
                  icon: Icons.wb_twilight_rounded,
                  selected: time == SceneTime.sunset,
                  onTap: () {
                    settings.sceneTime = SceneTime.sunset;
                    _precache(scene, SceneTime.sunset);
                  },
                ),
                _PickChip(
                  label: S.sceneTimeNight,
                  icon: Icons.nightlight_round,
                  selected: time == SceneTime.night,
                  onTap: () {
                    settings.sceneTime = SceneTime.night;
                    _precache(scene, SceneTime.night);
                  },
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
          child: Text(
            S.sceneHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  /// Skaliert die 360×800-Szene proportional in den verfügbaren Platz.
  Widget _buildScene(SceneBackground scene, SceneTime time, String gardenName) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var w = constraints.maxWidth;
        var h = w * (_sceneH / _sceneW);
        if (h > constraints.maxHeight) {
          h = constraints.maxHeight;
          w = h * (_sceneW / _sceneH);
        }
        final scale = w / _sceneW;

        // Pflanzen mit tieferer Position zuletzt zeichnen (stehen dann vorne).
        final ordered = List<FocusSession>.of(_plants)
          ..sort((a, b) =>
              _positions[a.id]!.dy.compareTo(_positions[b.id]!.dy));

        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24 * scale),
            child: SizedBox(
              width: w,
              height: h,
              child: RepaintBoundary(
                key: _sceneKey,
                child: Stack(
                  children: [
                    Positioned.fill(child: _background(scene, time)),
                    _Banner(name: gardenName, scale: scale),
                    for (final s in ordered) _buildPlant(s, w, h, scale),
                    for (final d in _decorations) _buildDeco(d, w, h, scale),
                    _Branding(scale: scale),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _background(SceneBackground scene, SceneTime time) {
    if (scene.procedural) return const MeadowBackground();
    return Image.asset(
      scene.assetFor(time),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      // Fehlt ein Bild, bleibt die gezeichnete Wiese als Fallback – kein Absturz.
      errorBuilder: (_, _, _) => const MeadowBackground(),
    );
  }

  Widget _buildPlant(FocusSession s, double w, double h, double scale) {
    final pos = _positions[s.id]!;
    final size = _spriteSize * scale;
    final plant = PlantCatalog.byId(s.plantId);
    return Positioned(
      left: pos.dx * w - size / 2,
      top: pos.dy * h - size / 2,
      width: size,
      height: size,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) {
          setState(() {
            final cur = _positions[s.id]!;
            final nx = (cur.dx + d.delta.dx / w).clamp(0.06, 0.94);
            final ny = (cur.dy + d.delta.dy / h).clamp(0.46, 0.96);
            _positions[s.id] = Offset(nx, ny);
          });
        },
        onPanEnd: (_) => _persistPositions(),
        child: PlantSprite(plant: plant, stage: 4, size: size),
      ),
    );
  }

  Widget _buildDeco(SceneDecoration d, double w, double h, double scale) {
    final size = 48 * scale;
    return Positioned(
      left: d.pos.dx * w - size / 2,
      top: d.pos.dy * h - size / 2,
      width: size,
      height: size,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (dd) => _dragDeco(d.id, dd.delta.dx / w, dd.delta.dy / h),
        onPanEnd: (_) => _persistDecorations(),
        onLongPress: () => _removeDeco(d.id),
        child: Center(
          child: Text(d.emoji, style: TextStyle(fontSize: 32 * scale)),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _share,
              icon: const Icon(Icons.ios_share_rounded, size: 20),
              label: const Text(S.sceneShare),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: _busy ? null : _setAsWallpaper,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wallpaper_rounded, size: 20),
              label: const Text(S.sceneSetWallpaper),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kompakter Auswahl-Chip für Szene/Tageszeit.
class _PickChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _PickChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? scheme.primary : scheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon,
                      size: 15,
                      color: selected ? scheme.onPrimary : scheme.onSurface),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? scheme.onPrimary : scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dezenter Name-Banner oben in der Szene.
class _Banner extends StatelessWidget {
  final String name;
  final double scale;
  const _Banner({required this.name, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 26 * scale,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 18 * scale, vertical: 8 * scale),
          decoration: BoxDecoration(
            color: const Color(0x33000000),
            borderRadius: BorderRadius.circular(20 * scale),
          ),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 20 * scale,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: const [
                Shadow(color: Color(0x66000000), blurRadius: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kleines Branding unten in der Szene.
class _Branding extends StatelessWidget {
  final double scale;
  const _Branding({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 18 * scale,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          S.sceneBranding,
          style: TextStyle(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.85),
            shadows: const [Shadow(color: Color(0x66000000), blurRadius: 3)],
          ),
        ),
      ),
    );
  }
}

class _EmptyScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined,
                size: 64, color: scheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              S.sceneEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
