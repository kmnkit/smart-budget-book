import 'package:zan/core/usecase/result.dart';
import 'package:zan/domain/entities/usage_quota.dart';
import 'package:zan/domain/repositories/subscription_repository.dart';

class GetUsageQuotaUseCase {
  const GetUsageQuotaUseCase(this._repository);
  final SubscriptionRepository _repository;

  Future<Result<UsageQuota>> call(String userId) {
    return _repository.getUsageQuota(userId);
  }
}
