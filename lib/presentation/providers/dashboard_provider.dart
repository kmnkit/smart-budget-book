import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/di/balance_providers.dart';
import 'package:zan/domain/entities/account_balance.dart';
import 'package:zan/domain/entities/monthly_summary.dart';
import 'package:zan/presentation/providers/auth_provider.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<List<AccountBalance>> accountBalances(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final datasource = ref.watch(balanceRemoteDataSourceProvider);
  return datasource.getUserBalances(userId);
}

@riverpod
Future<MonthlySummary> currentMonthSummary(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const MonthlySummary(
      totalIncome: 0,
      totalExpense: 0,
      netIncome: 0,
      transactionCount: 0,
    );
  }
  final now = DateTime.now();
  final datasource = ref.watch(balanceRemoteDataSourceProvider);
  return datasource.getMonthlySummary(
    userId: userId,
    year: now.year,
    month: now.month,
  );
}

@riverpod
int netWorth(Ref ref) {
  final balancesAsync = ref.watch(accountBalancesProvider);
  return balancesAsync.when(
    data: (balances) {
      int totalAssets = 0;
      int totalLiabilities = 0;
      for (final b in balances) {
        if (b.type.name == 'asset') {
          totalAssets += b.balance;
        } else if (b.type.name == 'liability') {
          totalLiabilities += b.balance;
        }
      }
      return totalAssets - totalLiabilities;
    },
    loading: () => 0,
    error: (_, _) => 0,
  );
}
