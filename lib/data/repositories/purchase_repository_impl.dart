import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/datasources/local/purchase_service.dart';
import 'package:zan/data/datasources/local/subscription_cache.dart';
import 'package:zan/domain/repositories/purchase_repository.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl(this._purchaseService, this._client, this._cache);

  final PurchaseService _purchaseService;
  final SupabaseClient _client;
  final SubscriptionCache _cache;

  @override
  Future<Result<List<ProductInfo>>> getProducts() async {
    try {
      final products = await _purchaseService.getProducts();
      return Success(
        products
            .map(
              (p) => ProductInfo(
                id: p.id,
                title: p.title,
                description: p.description,
                price: p.price,
                rawPrice: p.rawPrice,
                currencyCode: p.currencyCode,
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Fail(PurchaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> purchaseSubscription(String productId) async {
    try {
      final initiated = await _purchaseService.buySubscription(productId);
      if (!initiated) return const Fail(PurchaseFailure('Purchase initiation failed'));

      // Wait for purchase completion from the stream
      final purchase = await _purchaseService.purchaseStream
          .where((p) => p.productID == productId)
          .timeout(const Duration(minutes: 5))
          .firstWhere(
            (p) =>
                p.status == PurchaseStatus.purchased ||
                p.status == PurchaseStatus.error ||
                p.status == PurchaseStatus.canceled,
          );

      if (purchase.status == PurchaseStatus.error) {
        return Fail(PurchaseFailure(purchase.error?.message ?? 'Purchase error'));
      }
      if (purchase.status == PurchaseStatus.canceled) {
        return const Fail(PurchaseFailure('Purchase canceled'));
      }

      // Verify on server
      final verified = await _verifyPurchase(purchase);
      return Success(verified);
    } on TimeoutException {
      return const Fail(PurchaseFailure('Purchase timed out'));
    } catch (e) {
      return Fail(PurchaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> restorePurchases() async {
    try {
      await _purchaseService.restorePurchases();

      // Listen for restored purchases
      final restoredPurchases = <PurchaseDetails>[];
      final completer = Completer<void>();

      final sub = _purchaseService.purchaseStream.listen((purchase) {
        if (purchase.status == PurchaseStatus.restored ||
            purchase.status == PurchaseStatus.purchased) {
          restoredPurchases.add(purchase);
        }
      });

      // Give some time for restore results
      await Future<void>.delayed(const Duration(seconds: 5));
      completer.complete();
      await sub.cancel();

      if (restoredPurchases.isEmpty) {
        return const Success(false);
      }

      // Verify the most recent purchase
      final latest = restoredPurchases.last;
      final verified = await _verifyPurchase(latest);
      return Success(verified);
    } catch (e) {
      return Fail(PurchaseFailure(e.toString()));
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      final receiptData = _purchaseService.getReceiptData(purchase);
      if (receiptData == null) return false;

      final response = await _client.functions.invoke(
        'verify-purchase',
        body: {
          'receipt_data': receiptData,
          'product_id': purchase.productID,
          'platform': _purchaseService.platform,
        },
      );

      if (response.status == 200) {
        // Cache subscription locally
        final data = response.data as Map<String, dynamic>?;
        if (data != null && data['success'] == true) {
          await _cache.cache(
            tier: SubscriptionTier.premium,
            status: SubscriptionStatus.active,
            expiresAt: data['expires_at'] != null
                ? DateTime.parse(data['expires_at'] as String)
                : null,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
