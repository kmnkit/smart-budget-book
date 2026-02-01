import 'package:shared_preferences/shared_preferences.dart';
import 'package:zan/core/constants/enums.dart';

class SubscriptionCache {
  static const _keyTier = 'subscription_tier';
  static const _keyStatus = 'subscription_status';
  static const _keyExpiresAt = 'subscription_expires_at';
  static const _keyLastVerifiedAt = 'subscription_last_verified_at';

  static const _gracePeriodDays = 3;

  Future<void> cache({
    required SubscriptionTier tier,
    required SubscriptionStatus status,
    DateTime? expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTier, tier.dbValue);
    await prefs.setString(_keyStatus, status.dbValue);
    if (expiresAt != null) {
      await prefs.setString(_keyExpiresAt, expiresAt.toIso8601String());
    }
    await prefs.setString(
      _keyLastVerifiedAt,
      DateTime.now().toIso8601String(),
    );
  }

  Future<CachedSubscription?> getCached() async {
    final prefs = await SharedPreferences.getInstance();
    final tierStr = prefs.getString(_keyTier);
    final statusStr = prefs.getString(_keyStatus);
    if (tierStr == null || statusStr == null) return null;

    final tier = SubscriptionTier.fromDbValue(tierStr);
    final status = SubscriptionStatus.fromDbValue(statusStr);
    final expiresAtStr = prefs.getString(_keyExpiresAt);
    final lastVerifiedAtStr = prefs.getString(_keyLastVerifiedAt);

    final expiresAt =
        expiresAtStr != null ? DateTime.parse(expiresAtStr) : null;
    final lastVerifiedAt =
        lastVerifiedAtStr != null ? DateTime.parse(lastVerifiedAtStr) : null;

    return CachedSubscription(
      tier: tier,
      status: status,
      expiresAt: expiresAt,
      lastVerifiedAt: lastVerifiedAt,
    );
  }

  Future<bool> hasValidPremium() async {
    final cached = await getCached();
    if (cached == null) return false;
    if (cached.tier != SubscriptionTier.premium) return false;

    final now = DateTime.now();
    final expiresAt = cached.expiresAt;

    if (expiresAt == null) {
      return cached.status == SubscriptionStatus.trialing ||
          cached.status == SubscriptionStatus.active;
    }

    // Still within subscription period
    if (expiresAt.isAfter(now)) return true;

    // Grace period: 3 days after expiry
    final gracePeriodEnd =
        expiresAt.add(const Duration(days: _gracePeriodDays));
    if (gracePeriodEnd.isAfter(now)) return true;

    return false;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTier);
    await prefs.remove(_keyStatus);
    await prefs.remove(_keyExpiresAt);
    await prefs.remove(_keyLastVerifiedAt);
  }
}

class CachedSubscription {
  const CachedSubscription({
    required this.tier,
    required this.status,
    this.expiresAt,
    this.lastVerifiedAt,
  });

  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final DateTime? expiresAt;
  final DateTime? lastVerifiedAt;
}
