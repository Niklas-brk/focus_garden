import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Kapselt den In-App-Kauf des einmaligen Premium-Upgrades (Konzept
/// Abschnitt 7). Non-Consumable-Produkt-ID: `premium_unlock`.
///
/// Die eigentliche Freischaltung passiert nicht hier, sondern über den
/// Callback [onPremiumUnlocked] (setzt das Premium-Flag in den Einstellungen),
/// damit dieser Dienst nichts über den Rest der App wissen muss.
class PurchaseService extends ChangeNotifier {
  static const String productId = 'premium_unlock';

  final InAppPurchase _iap = InAppPurchase.instance;
  final VoidCallback onPremiumUnlocked;

  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool _storeAvailable = false;
  bool _pending = false;
  ProductDetails? _product;
  String? _lastError;

  PurchaseService({required this.onPremiumUnlocked});

  /// Ob der Store (Play Billing) grundsätzlich erreichbar ist.
  bool get storeAvailable => _storeAvailable;

  /// Ob gerade ein Kauf/eine Wiederherstellung läuft.
  bool get purchasePending => _pending;

  /// Das gefundene Produkt (null, wenn im Store noch nicht angelegt).
  ProductDetails? get product => _product;

  /// Lokalisierter Preis vom Store (z. B. "1,99 €"), sonst null.
  String? get price => _product?.price;

  String? get lastError => _lastError;

  Future<void> init() async {
    _storeAvailable = await _iap.isAvailable();
    if (!_storeAvailable) {
      notifyListeners();
      return;
    }
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onDone: () => _sub?.cancel(),
      onError: (Object e) {
        _lastError = e.toString();
        notifyListeners();
      },
    );
    await _loadProduct();
  }

  Future<void> _loadProduct() async {
    final resp = await _iap.queryProductDetails({productId});
    if (resp.productDetails.isNotEmpty) {
      _product = resp.productDetails.first;
    }
    notifyListeners();
  }

  /// Startet den Kauf. Das Ergebnis kommt asynchron über den Stream.
  Future<void> buy() async {
    final product = _product;
    if (product == null) return;
    _pending = true;
    _lastError = null;
    notifyListeners();
    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (e) {
      _pending = false;
      _lastError = e.toString();
      notifyListeners();
    }
  }

  /// Stellt frühere Käufe wieder her (Pflicht laut Konzept Abschnitt 7).
  Future<void> restore() async {
    _lastError = null;
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          _pending = true;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (p.productID == productId) onPremiumUnlocked();
          _pending = false;
        case PurchaseStatus.error:
          _pending = false;
          _lastError = p.error?.message;
        case PurchaseStatus.canceled:
          _pending = false;
      }
      // Pflicht: jeden abgeschlossenen/fehlgeschlagenen Kauf bestätigen,
      // sonst liefert der Store ihn immer wieder aus.
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
