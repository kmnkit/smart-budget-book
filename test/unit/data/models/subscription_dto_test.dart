import 'package:flutter_test/flutter_test.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/data/models/subscription_dto.dart';

void main() {
  group('SubscriptionDto.fromJson', () {
    test('should parse full subscription JSON', () {
      final json = {
        'id': 'sub-123',
        'user_id': 'user-456',
        'tier': 'premium',
        'status': 'active',
        'period': 'monthly',
        'store_product_id': 'com.zan.premium.monthly',
        'store_transaction_id': 'txn-789',
        'platform': 'ios',
        'trial_start_at': '2026-01-01T00:00:00Z',
        'trial_end_at': '2026-01-08T00:00:00Z',
        'current_period_start_at': '2026-01-08T00:00:00Z',
        'current_period_end_at': '2026-02-08T00:00:00Z',
        'canceled_at': null,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-08T00:00:00Z',
      };

      final subscription = SubscriptionDto.fromJson(json);

      expect(subscription.id, 'sub-123');
      expect(subscription.userId, 'user-456');
      expect(subscription.tier, SubscriptionTier.premium);
      expect(subscription.status, SubscriptionStatus.active);
      expect(subscription.period, SubscriptionPeriod.monthly);
      expect(subscription.storeProductId, 'com.zan.premium.monthly');
      expect(subscription.platform, 'ios');
      expect(subscription.trialStartAt, isNotNull);
      expect(subscription.trialEndAt, isNotNull);
      expect(subscription.canceledAt, isNull);
    });

    test('should parse minimal subscription JSON', () {
      final json = {
        'id': 'sub-1',
        'user_id': 'user-1',
        'tier': 'free',
        'status': 'none',
        'period': null,
        'store_product_id': null,
        'store_transaction_id': null,
        'platform': null,
        'trial_start_at': null,
        'trial_end_at': null,
        'current_period_start_at': null,
        'current_period_end_at': null,
        'canceled_at': null,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
      };

      final subscription = SubscriptionDto.fromJson(json);

      expect(subscription.tier, SubscriptionTier.free);
      expect(subscription.status, SubscriptionStatus.none);
      expect(subscription.period, isNull);
      expect(subscription.storeProductId, isNull);
    });

    test('should parse past_due status', () {
      final json = {
        'id': 'sub-1',
        'user_id': 'user-1',
        'tier': 'premium',
        'status': 'past_due',
        'period': 'annual',
        'store_product_id': null,
        'store_transaction_id': null,
        'platform': null,
        'trial_start_at': null,
        'trial_end_at': null,
        'current_period_start_at': null,
        'current_period_end_at': null,
        'canceled_at': null,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
      };

      final subscription = SubscriptionDto.fromJson(json);
      expect(subscription.status, SubscriptionStatus.pastDue);
      expect(subscription.period, SubscriptionPeriod.annual);
    });
  });

  group('SubscriptionDto.toJson', () {
    test('should serialize to correct JSON', () {
      final subscription = SubscriptionDto.fromJson({
        'id': 'sub-1',
        'user_id': 'user-1',
        'tier': 'premium',
        'status': 'active',
        'period': 'monthly',
        'store_product_id': 'com.zan.premium.monthly',
        'store_transaction_id': 'txn-1',
        'platform': 'android',
        'trial_start_at': null,
        'trial_end_at': null,
        'current_period_start_at': '2026-01-01T00:00:00Z',
        'current_period_end_at': '2026-02-01T00:00:00Z',
        'canceled_at': null,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
      });

      final json = SubscriptionDto.toJson(subscription);

      expect(json['tier'], 'premium');
      expect(json['status'], 'active');
      expect(json['period'], 'monthly');
      expect(json['platform'], 'android');
      expect(json['store_product_id'], 'com.zan.premium.monthly');
    });
  });

  group('Enum dbValue roundtrip', () {
    test('SubscriptionTier roundtrip', () {
      for (final tier in SubscriptionTier.values) {
        expect(SubscriptionTier.fromDbValue(tier.dbValue), tier);
      }
    });

    test('SubscriptionStatus roundtrip', () {
      for (final status in SubscriptionStatus.values) {
        expect(SubscriptionStatus.fromDbValue(status.dbValue), status);
      }
    });

    test('SubscriptionPeriod roundtrip', () {
      for (final period in SubscriptionPeriod.values) {
        expect(SubscriptionPeriod.fromDbValue(period.dbValue), period);
      }
    });

    test('UsageType roundtrip', () {
      for (final type in UsageType.values) {
        expect(UsageType.fromDbValue(type.dbValue), type);
      }
    });
  });
}
