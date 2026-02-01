import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';

class PurchaseService {
  PurchaseService() : _iap = InAppPurchase.instance;

  final InAppPurchase _iap;
  final _logger = Logger();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final _purchaseController = StreamController<PurchaseDetails>.broadcast();

  Stream<PurchaseDetails> get purchaseStream => _purchaseController.stream;

  static const monthlyProductId = 'com.zan.premium.monthly';
  static const annualProductId = 'com.zan.premium.annual';
  static const _productIds = {monthlyProductId, annualProductId};

  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) {
      _logger.w('In-app purchases not available');
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error) {
        _logger.e('Purchase stream error', error: error);
      },
    );
  }

  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
  }

  Future<List<ProductDetails>> getProducts() async {
    final response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      _logger.e('Failed to load products', error: response.error);
      return [];
    }
    if (response.notFoundIDs.isNotEmpty) {
      _logger.w('Products not found: ${response.notFoundIDs}');
    }
    return response.productDetails;
  }

  Future<bool> buySubscription(String productId) async {
    final products = await getProducts();
    final product = products.where((p) => p.id == productId).firstOrNull;
    if (product == null) return false;

    final purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _purchaseController.add(purchase);
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  String? getReceiptData(PurchaseDetails purchase) {
    if (Platform.isIOS) {
      return purchase.verificationData.serverVerificationData;
    } else if (Platform.isAndroid) {
      return purchase.verificationData.serverVerificationData;
    }
    return null;
  }

  String get platform {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }
}
