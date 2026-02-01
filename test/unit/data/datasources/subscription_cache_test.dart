import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/data/datasources/local/subscription_cache.dart';

void main() {
  late SubscriptionCache cache;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cache = SubscriptionCache();
  });

  group('cache and getCached', () {
    test('should store and retrieve subscription data', () async {
      final expiresAt = DateTime.now().add(const Duration(days: 30));
      await cache.cache(
        tier: SubscriptionTier.premium,
        status: SubscriptionStatus.active,
        expiresAt: expiresAt,
      );

      final cached = await cache.getCached();
      expect(cached, isNotNull);
      expect(cached!.tier, SubscriptionTier.premium);
      expect(cached.status, SubscriptionStatus.active);
      expect(cached.expiresAt, isNotNull);
      expect(cached.lastVerifiedAt, isNotNull);
    });

    test('should return null when nothing cached', () async {
      final cached = await cache.getCached();
      expect(cached, isNull);
    });
  });

  group('hasValidPremium', () {
    test('should return true for active premium with future expiry', () async {
      await cache.cache(
        tier: SubscriptionTier.premium,
        status: SubscriptionStatus.active,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      expect(await cache.hasValidPremium(), isTrue);
    });

    test('should return true for trialing premium without expiry', () async {
      await cache.cache(
        tier: SubscriptionTier.premium,
        status: SubscriptionStatus.trialing,
      );

      expect(await cache.hasValidPremium(), isTrue);
    });

    test('should return false for free tier', () async {
      await cache.cache(
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.none,
      );

      expect(await cache.hasValidPremium(), isFalse);
    });

    test('should return true within grace period (3 days after expiry)', () async {
      await cache.cache(
        tier: SubscriptionTier.premium,
        status: SubscriptionStatus.active,
        expiresAt: DateTime.now().subtract(const Duration(days: 2)),
      );

      expect(await cache.hasValidPremium(), isTrue);
    });

    test('should return false after grace period', () async {
      await cache.cache(
        tier: SubscriptionTier.premium,
        status: SubscriptionStatus.active,
        expiresAt: DateTime.now().subtract(const Duration(days: 4)),
      );

      expect(await cache.hasValidPremium(), isFalse);
    });

    test('should return false when nothing cached', () async {
      expect(await cache.hasValidPremium(), isFalse);
    });
  });

  group('clear', () {
    test('should clear all cached data', () async {
      await cache.cache(
        tier: SubscriptionTier.premium,
        status: SubscriptionStatus.active,
      );

      await cache.clear();

      final cached = await cache.getCached();
      expect(cached, isNull);
    });
  });
}
