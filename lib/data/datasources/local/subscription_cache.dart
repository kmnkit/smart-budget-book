import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zan/core/constants/enums.dart';

class SubscriptionCache {
  SubscriptionCache({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  final FlutterSecureStorage _storage;

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
    await _storage.write(key: _keyTier, value: tier.dbValue);
    await _storage.write(key: _keyStatus, value: status.dbValue);
    if (expiresAt != null) {
      await _storage.write(
        key: _keyExpiresAt,
        value: expiresAt.toIso8601String(),
      );
    }
    await _storage.write(
      key: _keyLastVerifiedAt,
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<CachedSubscription?> getCached() async {
    final tierStr = await _storage.read(key: _keyTier);
    final statusStr = await _storage.read(key: _keyStatus);
    if (tierStr == null || statusStr == null) return null;

    final tier = SubscriptionTier.fromDbValue(tierStr);
    final status = SubscriptionStatus.fromDbValue(statusStr);
    final expiresAtStr = await _storage.read(key: _keyExpiresAt);
    final lastVerifiedAtStr = await _storage.read(key: _keyLastVerifiedAt);

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
    await _storage.delete(key: _keyTier);
    await _storage.delete(key: _keyStatus);
    await _storage.delete(key: _keyExpiresAt);
    await _storage.delete(key: _keyLastVerifiedAt);
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
