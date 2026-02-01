import 'package:zan/core/usecase/result.dart';
import 'package:zan/domain/entities/subscription.dart';
import 'package:zan/domain/entities/usage_quota.dart';

abstract class SubscriptionRepository {
  Future<Result<Subscription>> getSubscription(String userId);
  Future<Result<UsageQuota>> getUsageQuota(String userId);
  Future<Result<void>> recordUsageEvent(String userId, String usageType);
}
