import 'package:zan/core/usecase/result.dart';
import 'package:zan/domain/repositories/purchase_repository.dart';

class PurchaseSubscriptionUseCase {
  const PurchaseSubscriptionUseCase(this._repository);
  final PurchaseRepository _repository;

  Future<Result<bool>> call(String productId) {
    return _repository.purchaseSubscription(productId);
  }
}
