import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../services/purchase_service.dart';
import '../../state/settings_provider.dart';

/// Premium-Kaufscreen (modal), Konzept Abschnitt 7. Zeigt die Vorteile, den
/// Preis (vom Store), den Kauf-Button und „Käufe wiederherstellen".
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<SettingsProvider>().premium;
    return Scaffold(
      appBar: AppBar(title: const Text(S.premiumTitle)),
      body: SafeArea(
        child: premium ? const _ActiveView() : const _PurchaseView(),
      ),
    );
  }
}

/// Zustand, wenn Premium bereits freigeschaltet ist.
class _ActiveView extends StatelessWidget {
  const _ActiveView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, size: 72, color: scheme.primary),
            const SizedBox(height: 16),
            const Text(
              S.premiumActiveTitle,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              S.premiumActiveBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(S.premiumClose),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseView extends StatefulWidget {
  const _PurchaseView();

  @override
  State<_PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<_PurchaseView> {
  PurchaseService? _service;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = context.read<PurchaseService>();
    if (!identical(service, _service)) {
      _service?.removeListener(_onPurchaseEvent);
      _service = service..addListener(_onPurchaseEvent);
    }
  }

  @override
  void dispose() {
    _service?.removeListener(_onPurchaseEvent);
    super.dispose();
  }

  /// Meldet Kauf-Ereignisse (Abbruch, Fehler, Wiederherstellung) als SnackBar.
  void _onPurchaseEvent() {
    final feedback = _service?.takeFeedback();
    if (feedback == null || !mounted) return;
    final text = switch (feedback) {
      PurchaseFeedback.canceled => S.premiumCanceled,
      PurchaseFeedback.restored => S.premiumRestored,
      PurchaseFeedback.error => S.premiumError,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final purchases = context.watch<PurchaseService>();
    // Preis kommt IMMER lokalisiert vom Store – nie hardcoden. Solange er
    // nicht geladen ist, bleibt der Kauf-Button deaktiviert.
    final price = purchases.price;
    final canBuy = purchases.product != null && !purchases.purchasePending;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 8),
        Center(
          child: Text('🌿', style: TextStyle(fontSize: 56, color: scheme.primary)),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            S.premiumTitle,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            S.premiumSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const _Benefit(icon: Icons.local_florist_rounded, text: S.premiumBenefitPlants),
        const _Benefit(icon: Icons.style_rounded, text: S.premiumBenefitStyles),
        const _Benefit(icon: Icons.palette_rounded, text: S.premiumBenefitThemes),
        const SizedBox(height: 28),
        if (!purchases.storeAvailable)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              S.premiumUnavailable,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: scheme.error),
            ),
          ),
        FilledButton(
          onPressed: canBuy ? () => purchases.buy() : null,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: purchases.purchasePending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  price != null ? '${S.premiumBuy} · $price' : S.premiumPriceLoading,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: purchases.purchasePending
              ? null
              : () {
                  purchases.restore();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(S.premiumRestoreStarted)),
                  );
                },
          child: const Text(S.premiumRestore),
        ),
        // Nur im Debug-Build: Premium ohne echten Kauf testen. Im Release
        // ist dieser Zweig komplett wegkompiliert.
        if (kDebugMode) ...[
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () =>
                context.read<SettingsProvider>().debugTogglePremium(),
            child: const Text(S.debugTogglePremium),
          ),
        ],
      ],
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Benefit({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
