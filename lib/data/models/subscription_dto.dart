import 'package:zan/core/constants/enums.dart';
import 'package:zan/domain/entities/subscription.dart';

class SubscriptionDto {
  const SubscriptionDto._();

  static Subscription fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tier: SubscriptionTier.fromDbValue(json['tier'] as String),
      status: SubscriptionStatus.fromDbValue(json['status'] as String),
      period: json['period'] != null
          ? SubscriptionPeriod.fromDbValue(json['period'] as String)
          : null,
      storeProductId: json['store_product_id'] as String?,
      storeTransactionId: json['store_transaction_id'] as String?,
      platform: json['platform'] as String?,
      trialStartAt: json['trial_start_at'] != null
          ? DateTime.parse(json['trial_start_at'] as String)
          : null,
      trialEndAt: json['trial_end_at'] != null
          ? DateTime.parse(json['trial_end_at'] as String)
          : null,
      currentPeriodStartAt: json['current_period_start_at'] != null
          ? DateTime.parse(json['current_period_start_at'] as String)
          : null,
      currentPeriodEndAt: json['current_period_end_at'] != null
          ? DateTime.parse(json['current_period_end_at'] as String)
          : null,
      canceledAt: json['canceled_at'] != null
          ? DateTime.parse(json['canceled_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static Map<String, dynamic> toJson(Subscription subscription) {
    return {
      'id': subscription.id,
      'user_id': subscription.userId,
      'tier': subscription.tier.dbValue,
      'status': subscription.status.dbValue,
      'period': subscription.period?.dbValue,
      'store_product_id': subscription.storeProductId,
      'store_transaction_id': subscription.storeTransactionId,
      'platform': subscription.platform,
      'trial_start_at': subscription.trialStartAt?.toIso8601String(),
      'trial_end_at': subscription.trialEndAt?.toIso8601String(),
      'current_period_start_at':
          subscription.currentPeriodStartAt?.toIso8601String(),
      'current_period_end_at':
          subscription.currentPeriodEndAt?.toIso8601String(),
      'canceled_at': subscription.canceledAt?.toIso8601String(),
    };
  }
}
