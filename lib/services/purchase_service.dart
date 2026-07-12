import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Kapselt den In-App-Kauf des einmaligen Premium-Upgrades (Konzept
/// Abschnitt 7). Non-Consumable-Produkt-ID: `premium_unlock`.
///
/// Die eigentliche Freischaltung passiert nicht hier, sondern über den
/// Callback [onPremiumUnlocked] (setzt das Premium-Flag in den Einstellungen),
/// damit dieser Dienst nichts über den Rest der App wissen muss.
/// Einmaliges Kauf-Ereignis, das die UI dem Nutzer melden soll (SnackBar).
/// Wird über [takeFeedback] abgeholt und dabei gelöscht, damit dieselbe
/// Meldung nicht mehrfach erscheint.
enum PurchaseFeedback { error, canceled, restored }

class PurchaseService extends ChangeNotifier {
  static const String productId = 'premium_unlock';

  final InAppPurchase _iap = InAppPurchase.instance;
  final VoidCallback onPremiumUnlocked;

  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool _storeAvailable = false;
  bool _pending = false;
  ProductDetails? _product;
  String? _lastError;
  PurchaseFeedback? _feedback;

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

  /// Holt das jüngste Kauf-Ereignis ab und löscht es dabei.
  PurchaseFeedback? takeFeedback() {
    final f = _feedback;
    _feedback = null;
    return f;
  }

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

    // Persistiertes Premium-Flag beim Start gegen den Store abgleichen:
    // liefert der Store einen früheren Kauf, kommt er als `restored` über den
    // Stream (deckt Neuinstallation/Gerätewechsel ab). Findet er nichts, wird
    // Premium bewusst NICHT entzogen – ein Offline-Start darf einen ehrlichen
    // Käufer nicht aussperren.
    try {
      await _iap.restorePurchases();
    } catch (_) {
      // Kein Nutzer-Feedback nötig: reiner Hintergrund-Abgleich beim Start.
    }
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
      _feedback = PurchaseFeedback.error;
      notifyListeners();
    }
  }

  /// Stellt frühere Käufe wieder her (Pflicht laut Konzept Abschnitt 7).
  Future<void> restore() async {
    _lastError = null;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      _lastError = e.toString();
      _feedback = PurchaseFeedback.error;
      notifyListeners();
    }
  }

  /// Play Billing meldet „bereits gekauft", wenn ein Käufer erneut auf Kaufen
  /// tippt (z. B. nach Neuinstallation, bevor der Start-Abgleich fertig war).
  /// Das ist kein Fehler, sondern ein Besitz-Nachweis.
  bool _isAlreadyOwned(IAPError? e) {
    final text = '${e?.code ?? ''} ${e?.message ?? ''}'.toLowerCase();
    return text.contains('already') && text.contains('own') ||
        text.contains('item_already_owned');
  }

  void _onPurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          _pending = true;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (p.productID == productId) {
            onPremiumUnlocked();
            if (p.status == PurchaseStatus.restored) {
              _feedback = PurchaseFeedback.restored;
            }
          }
          _pending = false;
        case PurchaseStatus.error:
          _pending = false;
          if (p.productID == productId && _isAlreadyOwned(p.error)) {
            onPremiumUnlocked();
            _feedback = PurchaseFeedback.restored;
          } else {
            _lastError = p.error?.message;
            _feedback = PurchaseFeedback.error;
          }
        case PurchaseStatus.canceled:
          _pending = false;
          _feedback = PurchaseFeedback.canceled;
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
