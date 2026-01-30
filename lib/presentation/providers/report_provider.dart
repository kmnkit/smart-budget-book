import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/di/balance_providers.dart';
import 'package:zan/config/di/transaction_providers.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/domain/entities/monthly_summary.dart';
import 'package:zan/presentation/providers/account_provider.dart';
import 'package:zan/presentation/providers/auth_provider.dart';

part 'report_provider.g.dart';

final selectedMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime(DateTime.now().year, DateTime.now().month),
);

@riverpod
Future<MonthlySummary> monthlyReport(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const MonthlySummary(
      totalIncome: 0,
      totalExpense: 0,
      netIncome: 0,
      transactionCount: 0,
    );
  }
  final month = ref.watch(selectedMonthProvider);
  final datasource = ref.watch(balanceRemoteDataSourceProvider);
  return datasource.getMonthlySummary(
    userId: userId,
    year: month.year,
    month: month.month,
  );
}

@riverpod
Future<Map<String, int>> categoryBreakdown(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return {};
  final month = ref.watch(selectedMonthProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  final accounts = await ref.watch(accountListProvider.future);

  final startDate = DateTime(month.year, month.month, 1);
  final endDate = DateTime(month.year, month.month + 1, 0);

  final result = await repo.getTransactions(
    userId: userId,
    startDate: startDate,
    endDate: endDate,
    limit: 500,
  );

  return result.when(
    success: (transactions) {
      final breakdown = <String, int>{};
      for (final t in transactions) {
        final debitAccount = accounts.where((a) => a.id == t.debitAccountId).firstOrNull;
        if (debitAccount != null && debitAccount.type == AccountType.expense) {
          final categoryName = debitAccount.name;
          breakdown[categoryName] = (breakdown[categoryName] ?? 0) + t.amount;
        }
      }
      return breakdown;
    },
    failure: (_) => {},
  );
}

@riverpod
Future<MonthlySummary> previousMonthSummary(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const MonthlySummary(
      totalIncome: 0,
      totalExpense: 0,
      netIncome: 0,
      transactionCount: 0,
    );
  }
  final month = ref.watch(selectedMonthProvider);
  final prevMonth = DateTime(month.year, month.month - 1);
  final datasource = ref.watch(balanceRemoteDataSourceProvider);
  return datasource.getMonthlySummary(
    userId: userId,
    year: prevMonth.year,
    month: prevMonth.month,
  );
}
