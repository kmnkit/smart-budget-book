import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/data/models/subscription_dto.dart';
import 'package:zan/domain/entities/subscription.dart';
import 'package:zan/domain/entities/usage_quota.dart';

class SubscriptionRemoteDataSource {
  const SubscriptionRemoteDataSource(this._client);
  final SupabaseClient _client;

  Future<Subscription> getSubscription(String userId) async {
    final data = await _client
        .from('subscriptions')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) {
      // Return a default free subscription if none exists
      return Subscription(
        id: '',
        userId: userId,
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.none,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return SubscriptionDto.fromJson(data);
  }

  Future<UsageQuota> getUsageQuota(String userId) async {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    // Fetch all counts in parallel
    final results = await Future.wait([
      _client.rpc<int>('get_monthly_transaction_count', params: {
        'p_user_id': userId,
        'p_year': year,
        'p_month': month,
      }),
      _client.rpc<int>('get_monthly_usage_count', params: {
        'p_user_id': userId,
        'p_usage_type': UsageType.aiInput.dbValue,
        'p_year': year,
        'p_month': month,
      }),
      _client.rpc<int>('get_monthly_usage_count', params: {
        'p_user_id': userId,
        'p_usage_type': UsageType.ocrScan.dbValue,
        'p_year': year,
        'p_month': month,
      }),
      _client.rpc<int>('get_account_count', params: {
        'p_user_id': userId,
      }),
      _client.rpc<bool>('has_premium_access', params: {
        'p_user_id': userId,
      }),
    ]);

    final isPremium = results[4] as bool;

    return UsageQuota(
      userId: userId,
      transactionsThisMonth: results[0] as int,
      transactionsLimit: isPremium ? -1 : 50,
      aiInputsThisMonth: results[1] as int,
      aiInputsLimit: isPremium ? -1 : 5,
      ocrScansThisMonth: results[2] as int,
      ocrScansLimit: isPremium ? -1 : 3,
      accountCount: results[3] as int,
      accountsLimit: isPremium ? -1 : 5,
      periodStart: DateTime(year, month),
      periodEnd: DateTime(year, month + 1),
    );
  }

  Future<void> recordUsageEvent(String userId, String usageType) async {
    await _client.from('usage_events').insert({
      'user_id': userId,
      'usage_type': usageType,
    });
  }
}
