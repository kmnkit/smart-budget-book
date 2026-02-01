import 'package:zan/core/usecase/result.dart';
import 'package:zan/domain/entities/subscription.dart';
import 'package:zan/domain/repositories/subscription_repository.dart';

class GetSubscriptionUseCase {
  const GetSubscriptionUseCase(this._repository);
  final SubscriptionRepository _repository;

  Future<Result<Subscription>> call(String userId) {
    return _repository.getSubscription(userId);
  }
}
