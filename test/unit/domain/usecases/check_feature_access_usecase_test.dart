import 'package:flutter_test/flutter_test.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/domain/entities/feature_access.dart';
import 'package:zan/domain/entities/subscription.dart';
import 'package:zan/domain/entities/usage_quota.dart';
import 'package:zan/domain/usecases/check_feature_access_usecase.dart';

void main() {
  late CheckFeatureAccessUseCase useCase;

  setUp(() {
    useCase = const CheckFeatureAccessUseCase();
  });

  Subscription _premiumSubscription({
    SubscriptionStatus status = SubscriptionStatus.active,
  }) {
    return Subscription(
      id: 'sub-1',
      userId: 'user-1',
      tier: SubscriptionTier.premium,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Subscription _freeSubscription() {
    return Subscription(
      id: 'sub-1',
      userId: 'user-1',
      tier: SubscriptionTier.free,
      status: SubscriptionStatus.none,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  UsageQuota _quota({
    int transactions = 0,
    int accounts = 0,
    int aiInputs = 0,
    int ocrScans = 0,
  }) {
    final now = DateTime.now();
    return UsageQuota(
      userId: 'user-1',
      transactionsThisMonth: transactions,
      transactionsLimit: 50,
      aiInputsThisMonth: aiInputs,
      aiInputsLimit: 5,
      ocrScansThisMonth: ocrScans,
      ocrScansLimit: 3,
      accountCount: accounts,
      accountsLimit: 5,
      periodStart: DateTime(now.year, now.month),
      periodEnd: DateTime(now.year, now.month + 1),
    );
  }

  group('Premium user', () {
    test('should allow all features for active premium', () {
      final sub = _premiumSubscription();
      final quota = _quota();

      for (final feature in FeatureType.values) {
        final access = useCase.call(
          feature: feature,
          subscription: sub,
          quota: quota,
        );
        expect(access.allowed, isTrue, reason: 'Feature $feature should be allowed');
      }
    });

    test('should allow all features for trialing user', () {
      final sub = _premiumSubscription(status: SubscriptionStatus.trialing);
      final quota = _quota();

      for (final feature in FeatureType.values) {
        final access = useCase.call(
          feature: feature,
          subscription: sub,
          quota: quota,
        );
        expect(access.allowed, isTrue);
      }
    });
  });

  group('Free user - createTransaction', () {
    test('should allow when under limit', () {
      final access = useCase.call(
        feature: FeatureType.createTransaction,
        subscription: _freeSubscription(),
        quota: _quota(transactions: 30),
      );
      expect(access.allowed, isTrue);
      expect(access.remaining, equals(20));
      expect(access.limit, equals(50));
    });

    test('should deny when at limit', () {
      final access = useCase.call(
        feature: FeatureType.createTransaction,
        subscription: _freeSubscription(),
        quota: _quota(transactions: 50),
      );
      expect(access.allowed, isFalse);
      expect(access.remaining, equals(0));
    });

    test('should deny when over limit', () {
      final access = useCase.call(
        feature: FeatureType.createTransaction,
        subscription: _freeSubscription(),
        quota: _quota(transactions: 55),
      );
      expect(access.allowed, isFalse);
    });
  });

  group('Free user - createAccount', () {
    test('should allow when under limit', () {
      final access = useCase.call(
        feature: FeatureType.createAccount,
        subscription: _freeSubscription(),
        quota: _quota(accounts: 3),
      );
      expect(access.allowed, isTrue);
      expect(access.remaining, equals(2));
    });

    test('should deny at limit', () {
      final access = useCase.call(
        feature: FeatureType.createAccount,
        subscription: _freeSubscription(),
        quota: _quota(accounts: 5),
      );
      expect(access.allowed, isFalse);
      expect(access.remaining, equals(0));
      expect(access.limit, equals(5));
    });
  });

  group('Free user - aiInput', () {
    test('should allow when under limit', () {
      final access = useCase.call(
        feature: FeatureType.aiInput,
        subscription: _freeSubscription(),
        quota: _quota(aiInputs: 2),
      );
      expect(access.allowed, isTrue);
      expect(access.remaining, equals(3));
    });

    test('should deny at limit', () {
      final access = useCase.call(
        feature: FeatureType.aiInput,
        subscription: _freeSubscription(),
        quota: _quota(aiInputs: 5),
      );
      expect(access.allowed, isFalse);
    });
  });

  group('Free user - ocrScan', () {
    test('should allow when under limit', () {
      final access = useCase.call(
        feature: FeatureType.ocrScan,
        subscription: _freeSubscription(),
        quota: _quota(ocrScans: 1),
      );
      expect(access.allowed, isTrue);
      expect(access.remaining, equals(2));
    });

    test('should deny at limit', () {
      final access = useCase.call(
        feature: FeatureType.ocrScan,
        subscription: _freeSubscription(),
        quota: _quota(ocrScans: 3),
      );
      expect(access.allowed, isFalse);
    });
  });

  group('Free user - premium-only features', () {
    test('should deny exportPdf', () {
      final access = useCase.call(
        feature: FeatureType.exportPdf,
        subscription: _freeSubscription(),
        quota: _quota(),
      );
      expect(access.allowed, isFalse);
    });

    test('should deny exportJson', () {
      final access = useCase.call(
        feature: FeatureType.exportJson,
        subscription: _freeSubscription(),
        quota: _quota(),
      );
      expect(access.allowed, isFalse);
    });

    test('should deny multiCurrency', () {
      final access = useCase.call(
        feature: FeatureType.multiCurrency,
        subscription: _freeSubscription(),
        quota: _quota(),
      );
      expect(access.allowed, isFalse);
    });

    test('should deny fullHistory', () {
      final access = useCase.call(
        feature: FeatureType.fullHistory,
        subscription: _freeSubscription(),
        quota: _quota(),
      );
      expect(access.allowed, isFalse);
    });
  });

  group('Expired/Canceled user', () {
    test('should deny premium features for expired subscription', () {
      final sub = Subscription(
        id: 'sub-1',
        userId: 'user-1',
        tier: SubscriptionTier.premium,
        status: SubscriptionStatus.expired,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final access = useCase.call(
        feature: FeatureType.multiCurrency,
        subscription: sub,
        quota: _quota(),
      );
      expect(access.allowed, isFalse);
    });

    test('should apply free limits for canceled subscription', () {
      final sub = Subscription(
        id: 'sub-1',
        userId: 'user-1',
        tier: SubscriptionTier.premium,
        status: SubscriptionStatus.canceled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final access = useCase.call(
        feature: FeatureType.createTransaction,
        subscription: sub,
        quota: _quota(transactions: 50),
      );
      expect(access.allowed, isFalse);
    });
  });
}
