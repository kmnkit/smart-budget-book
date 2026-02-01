import 'package:zan/core/constants/enums.dart';
import 'package:zan/domain/entities/feature_access.dart';
import 'package:zan/domain/entities/subscription.dart';
import 'package:zan/domain/entities/usage_quota.dart';

class CheckFeatureAccessUseCase {
  const CheckFeatureAccessUseCase();

  FeatureAccess call({
    required FeatureType feature,
    required Subscription subscription,
    required UsageQuota quota,
  }) {
    // Premium users (trialing or active) have full access
    if (subscription.status == SubscriptionStatus.trialing ||
        subscription.status == SubscriptionStatus.active) {
      return FeatureAccess.granted;
    }

    // Free tier checks
    return switch (feature) {
      FeatureType.createAccount => _checkLimit(
          current: quota.accountCount,
          limit: quota.accountsLimit,
          reason: 'アカウント数が上限に達しました',
        ),
      FeatureType.createTransaction => _checkLimit(
          current: quota.transactionsThisMonth,
          limit: quota.transactionsLimit,
          reason: '今月の取引数が上限に達しました',
        ),
      FeatureType.aiInput => _checkLimit(
          current: quota.aiInputsThisMonth,
          limit: quota.aiInputsLimit,
          reason: '今月のAI入力回数が上限に達しました',
        ),
      FeatureType.ocrScan => _checkLimit(
          current: quota.ocrScansThisMonth,
          limit: quota.ocrScansLimit,
          reason: '今月のOCRスキャン回数が上限に達しました',
        ),
      FeatureType.exportPdf || FeatureType.exportJson => const FeatureAccess(
          allowed: false,
          reason: 'PDF・JSONエクスポートはプレミアム機能です',
        ),
      FeatureType.multiCurrency => const FeatureAccess(
          allowed: false,
          reason: '複数通貨はプレミアム機能です',
        ),
      FeatureType.fullHistory => const FeatureAccess(
          allowed: false,
          reason: '6ヶ月以前のデータはプレミアム機能です',
        ),
    };
  }

  FeatureAccess _checkLimit({
    required int current,
    required int limit,
    required String reason,
  }) {
    if (limit < 0) return FeatureAccess.granted; // unlimited
    if (current < limit) {
      return FeatureAccess(
        allowed: true,
        remaining: limit - current,
        limit: limit,
      );
    }
    return FeatureAccess(
      allowed: false,
      reason: reason,
      remaining: 0,
      limit: limit,
    );
  }
}
