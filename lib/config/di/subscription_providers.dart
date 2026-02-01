import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/data/datasources/remote/subscription_remote_datasource.dart';
import 'package:zan/data/datasources/remote/supabase_providers.dart';
import 'package:zan/data/repositories/subscription_repository_impl.dart';
import 'package:zan/domain/repositories/subscription_repository.dart';
import 'package:zan/domain/usecases/check_feature_access_usecase.dart';
import 'package:zan/domain/usecases/get_subscription_usecase.dart';
import 'package:zan/domain/usecases/get_usage_quota_usecase.dart';
import 'package:zan/domain/usecases/record_usage_event_usecase.dart';

part 'subscription_providers.g.dart';

@riverpod
SubscriptionRemoteDataSource subscriptionRemoteDataSource(Ref ref) {
  return SubscriptionRemoteDataSource(ref.watch(supabaseClientProvider));
}

@riverpod
SubscriptionRepository subscriptionRepository(Ref ref) {
  return SubscriptionRepositoryImpl(
    ref.watch(subscriptionRemoteDataSourceProvider),
  );
}

@riverpod
GetSubscriptionUseCase getSubscriptionUseCase(Ref ref) {
  return GetSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
}

@riverpod
GetUsageQuotaUseCase getUsageQuotaUseCase(Ref ref) {
  return GetUsageQuotaUseCase(ref.watch(subscriptionRepositoryProvider));
}

@riverpod
CheckFeatureAccessUseCase checkFeatureAccessUseCase(Ref ref) {
  return const CheckFeatureAccessUseCase();
}

@riverpod
RecordUsageEventUseCase recordUsageEventUseCase(Ref ref) {
  return RecordUsageEventUseCase(ref.watch(subscriptionRepositoryProvider));
}
