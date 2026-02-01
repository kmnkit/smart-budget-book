import 'package:zan/core/usecase/result.dart';

abstract class PurchaseRepository {
  Future<Result<bool>> purchaseSubscription(String productId);
  Future<Result<bool>> restorePurchases();
  Future<Result<List<ProductInfo>>> getProducts();
}

class ProductInfo {
  const ProductInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rawPrice,
    required this.currencyCode,
  });

  final String id;
  final String title;
  final String description;
  final String price;
  final double rawPrice;
  final String currencyCode;
}
