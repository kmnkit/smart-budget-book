import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_summary.freezed.dart';

@Freezed()
sealed class MonthlySummary with _$MonthlySummary {
  const factory MonthlySummary({
    required int totalIncome,
    required int totalExpense,
    required int netIncome,
    required int transactionCount,
  }) = _MonthlySummary;
}
