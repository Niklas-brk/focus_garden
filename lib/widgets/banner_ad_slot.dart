import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../services/ads.dart';
import '../state/settings_provider.dart';

/// Dezenter Banner-Werbeplatz, nur in der Gratis-Version. Plätze: Statistik-Tab
/// (Konzept Abschnitt 4/7) und der laufende Fokus-Modus (dorthin schaut man
/// während der Session ohnehin nicht – stört also niemanden). Bei Premium
/// rendert das Widget nichts und lädt auch keine Anzeige.
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    // Premium-Status erst nach dem ersten Frame lesen (context.read braucht
    // einen fertigen Provider-Baum). Nicht-Premium -> Banner laden.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<SettingsProvider>().premium) return;
      _load();
    });
  }

  void _load() {
    final ad = BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Premium: kein Werbeplatz. Reagiert auch live, wenn während der Sitzung
    // gekauft wird.
    final premium = context.watch<SettingsProvider>().premium;
    if (premium) return const SizedBox.shrink();
    if (!_loaded || _ad == null) return const SizedBox.shrink();

    return Container(
      alignment: Alignment.center,
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      margin: const EdgeInsets.only(top: 16),
      child: AdWidget(ad: _ad!),
    );
  }
}
