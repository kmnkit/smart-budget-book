import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zan/core/constants/enums.dart';

part 'subscription.freezed.dart';

@Freezed()
sealed class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required SubscriptionTier tier,
    required SubscriptionStatus status,
    SubscriptionPeriod? period,
    String? storeProductId,
    String? storeTransactionId,
    String? platform,
    DateTime? trialStartAt,
    DateTime? trialEndAt,
    DateTime? currentPeriodStartAt,
    DateTime? currentPeriodEndAt,
    DateTime? canceledAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Subscription;
}
