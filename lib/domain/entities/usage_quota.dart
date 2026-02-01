import 'package:freezed_annotation/freezed_annotation.dart';

part 'usage_quota.freezed.dart';

@Freezed()
sealed class UsageQuota with _$UsageQuota {
  const factory UsageQuota({
    required String userId,
    required int transactionsThisMonth,
    required int transactionsLimit,
    required int aiInputsThisMonth,
    required int aiInputsLimit,
    required int ocrScansThisMonth,
    required int ocrScansLimit,
    required int accountCount,
    required int accountsLimit,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) = _UsageQuota;
}
