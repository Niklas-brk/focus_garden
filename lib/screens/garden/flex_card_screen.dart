import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_strings.dart';
import '../../models/plant_catalog.dart';
import '../../state/history_provider.dart';
import '../../state/settings_provider.dart';
import '../../widgets/flex_card.dart';
import '../premium/premium_screen.dart';

/// Vorschau + Teilen der Flex-Card (Konzept Abschnitt 6). Rendert die Karte
/// über eine RepaintBoundary zu einem 1080×1920-PNG und öffnet das
/// System-Teilen-Menü.
class FlexCardScreen extends StatefulWidget {
  const FlexCardScreen({super.key});

  @override
  State<FlexCardScreen> createState() => _FlexCardScreenState();
}

class _FlexCardScreenState extends State<FlexCardScreen> {
  final GlobalKey _cardKey = GlobalKey();
  FlexCardStyle _style = FlexCardStyle.dark;
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // pixelRatio 3 -> 360×640 (Logik) wird zu 1080×1920 (Story-Format).
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/focus_garden_flexcard.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)], text: S.flexShareText);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(S.flexShareError)),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  String _styleLabel(FlexCardStyle s) {
    switch (s) {
      case FlexCardStyle.dark:
        return S.flexStyleDark;
      case FlexCardStyle.cozy:
        return S.flexStyleCozy;
      case FlexCardStyle.neon:
        return S.flexStyleNeon;
    }
  }

  String _periodLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: today.weekday - 1));
    String month(int m) => S.monthNames[m - 1];
    if (start.month == today.month) {
      return '${start.day}.–${today.day}. ${month(today.month)}';
    }
    return '${start.day}. ${month(start.month)} – ${today.day}. ${month(today.month)}';
  }

  /// Nur der Dunkel-Stil ist gratis; Cozy & Neon gehören zu Premium
  /// (Konzept Abschnitt 7).
  bool _isLocked(FlexCardStyle s, bool premium) =>
      !premium && s != FlexCardStyle.dark;

  void _openPremium() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final premium = context.watch<SettingsProvider>().premium;
    final stats = history.stats;
    final plants =
        history.garden.take(6).map((s) => PlantCatalog.byId(s.plantId)).toList();

    // Falls Premium (z. B. im Debug) wieder deaktiviert wurde, auf den freien
    // Stil zurückfallen, damit keine gesperrte Karte gezeigt wird.
    final activeStyle = _isLocked(_style, premium) ? FlexCardStyle.dark : _style;

    return Scaffold(
      appBar: AppBar(title: const Text(S.flexTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FittedBox(
                    child: RepaintBoundary(
                      key: _cardKey,
                      child: FlexCard(
                        weekMinutes: stats.weekMinutes,
                        weekPlants: stats.weekBlooms,
                        streak: stats.streak,
                        periodLabel: _periodLabel(),
                        plants: plants,
                        style: activeStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final s in FlexCardStyle.values)
                    _StyleChip(
                      label: _styleLabel(s),
                      selected: activeStyle == s,
                      locked: _isLocked(s, premium),
                      onTap: _isLocked(s, premium)
                          ? _openPremium
                          : () => setState(() => _style = s),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _sharing ? null : _share,
                  icon: _sharing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.ios_share_rounded),
                  label: const Text(S.flexShare),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  const _StyleChip({
    required this.label,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Material(
        color: selected ? scheme.primary : scheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (locked) ...[
                  Icon(Icons.lock_rounded,
                      size: 13,
                      color: scheme.onSurface.withValues(alpha: 0.6)),
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
