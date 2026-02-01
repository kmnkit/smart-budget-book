import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/datasources/remote/subscription_remote_datasource.dart';
import 'package:zan/domain/entities/subscription.dart';
import 'package:zan/domain/entities/usage_quota.dart';
import 'package:zan/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl(this._remoteDataSource);
  final SubscriptionRemoteDataSource _remoteDataSource;

  @override
  Future<Result<Subscription>> getSubscription(String userId) async {
    try {
      final subscription = await _remoteDataSource.getSubscription(userId);
      return Success(subscription);
    } catch (e) {
      return Fail(SubscriptionFailure(e.toString()));
    }
  }

  @override
  Future<Result<UsageQuota>> getUsageQuota(String userId) async {
    try {
      final quota = await _remoteDataSource.getUsageQuota(userId);
      return Success(quota);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> recordUsageEvent(String userId, String usageType) async {
    try {
      await _remoteDataSource.recordUsageEvent(userId, usageType);
      return const Success(null);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }
}
