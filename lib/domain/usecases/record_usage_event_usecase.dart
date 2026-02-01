import 'package:zan/core/constants/enums.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/domain/repositories/subscription_repository.dart';

class RecordUsageEventUseCase {
  const RecordUsageEventUseCase(this._repository);
  final SubscriptionRepository _repository;

  Future<Result<void>> call(String userId, UsageType usageType) {
    return _repository.recordUsageEvent(userId, usageType.dbValue);
  }
}
