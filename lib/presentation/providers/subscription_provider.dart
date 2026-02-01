import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/di/subscription_providers.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/domain/entities/feature_access.dart';
import 'package:zan/domain/entities/subscription.dart';
import 'package:zan/domain/entities/usage_quota.dart';
import 'package:zan/presentation/providers/auth_provider.dart';

part 'subscription_provider.g.dart';

@riverpod
Future<Subscription> subscription(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Subscription(
      id: '',
      userId: '',
      tier: SubscriptionTier.free,
      status: SubscriptionStatus.none,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  final result = await ref.watch(getSubscriptionUseCaseProvider).call(userId);
  return result.when(
    success: (data) => data,
    failure: (_) => Subscription(
      id: '',
      userId: userId,
      tier: SubscriptionTier.free,
      status: SubscriptionStatus.none,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );
}

@riverpod
Future<UsageQuota> usageQuota(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    final now = DateTime.now();
    return UsageQuota(
      userId: '',
      transactionsThisMonth: 0,
      transactionsLimit: 50,
      aiInputsThisMonth: 0,
      aiInputsLimit: 5,
      ocrScansThisMonth: 0,
      ocrScansLimit: 3,
      accountCount: 0,
      accountsLimit: 5,
      periodStart: DateTime(now.year, now.month),
      periodEnd: DateTime(now.year, now.month + 1),
    );
  }
  final result = await ref.watch(getUsageQuotaUseCaseProvider).call(userId);
  return result.when(
    success: (data) => data,
    failure: (_) {
      final now = DateTime.now();
      return UsageQuota(
        userId: userId,
        transactionsThisMonth: 0,
        transactionsLimit: 50,
        aiInputsThisMonth: 0,
        aiInputsLimit: 5,
        ocrScansThisMonth: 0,
        ocrScansLimit: 3,
        accountCount: 0,
        accountsLimit: 5,
        periodStart: DateTime(now.year, now.month),
        periodEnd: DateTime(now.year, now.month + 1),
      );
    },
  );
}

@riverpod
bool isPremium(Ref ref) {
  final sub = ref.watch(subscriptionProvider).valueOrNull;
  if (sub == null) return false;
  return sub.status == SubscriptionStatus.trialing ||
      sub.status == SubscriptionStatus.active;
}

@riverpod
FeatureAccess featureAccess(Ref ref, FeatureType feature) {
  final sub = ref.watch(subscriptionProvider).valueOrNull;
  final quota = ref.watch(usageQuotaProvider).valueOrNull;
  if (sub == null || quota == null) {
    return const FeatureAccess(allowed: false, reason: 'loading');
  }

  final useCase = ref.watch(checkFeatureAccessUseCaseProvider);
  return useCase.call(
    feature: feature,
    subscription: sub,
    quota: quota,
  );
}
