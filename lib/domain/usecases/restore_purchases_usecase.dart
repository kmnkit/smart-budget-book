import 'package:zan/core/usecase/result.dart';
import 'package:zan/domain/repositories/purchase_repository.dart';

class RestorePurchasesUseCase {
  const RestorePurchasesUseCase(this._repository);
  final PurchaseRepository _repository;

  Future<Result<bool>> call() {
    return _repository.restorePurchases();
  }
}
