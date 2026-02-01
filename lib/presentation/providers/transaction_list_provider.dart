import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/di/transaction_providers.dart';
import 'package:zan/domain/entities/transaction.dart';
import 'package:zan/presentation/providers/auth_provider.dart';
import 'package:zan/presentation/providers/dashboard_provider.dart';
import 'package:zan/presentation/providers/report_provider.dart';
import 'package:zan/presentation/providers/subscription_provider.dart';

part 'transaction_list_provider.g.dart';

class TransactionFilter {
  const TransactionFilter({
    this.startDate,
    this.endDate,
    this.accountId,
    this.searchQuery,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String? accountId;
  final String? searchQuery;
}

final transactionFilterProvider = StateProvider<TransactionFilter>(
  (ref) => const TransactionFilter(),
);

@riverpod
Future<List<Transaction>> transactionList(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final filter = ref.watch(transactionFilterProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  final result = await repo.getTransactions(
    userId: userId,
    startDate: filter.startDate,
    endDate: filter.endDate,
    accountId: filter.accountId,
    searchQuery: filter.searchQuery,
  );
  return result.when(
    success: (transactions) => transactions,
    failure: (_) => [],
  );
}

@riverpod
Future<List<Transaction>> recentTransactions(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final repo = ref.watch(transactionRepositoryProvider);
  final result = await repo.getRecentTransactions(userId);
  return result.when(
    success: (transactions) => transactions,
    failure: (_) => [],
  );
}

@riverpod
Future<bool> deleteTransaction(Ref ref, {required String transactionId}) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final result = await repo.deleteTransaction(transactionId);
  return result.when(
    success: (_) {
      ref.invalidate(transactionListProvider);
      ref.invalidate(recentTransactionsProvider);
      ref.invalidate(accountBalancesProvider);
      ref.invalidate(currentMonthSummaryProvider);
      ref.invalidate(monthlyReportProvider);
      ref.invalidate(categoryBreakdownProvider);
      ref.invalidate(previousMonthSummaryProvider);
      ref.invalidate(usageQuotaProvider);
      return true;
    },
    failure: (_) => false,
  );
}
