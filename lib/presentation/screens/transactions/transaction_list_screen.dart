import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zan/config/router/route_names.dart';
import 'package:zan/core/extensions/date_extensions.dart';
import 'package:zan/core/utils/currency_formatter.dart';
import 'package:zan/domain/entities/account.dart';
import 'package:zan/domain/entities/transaction.dart';
import 'package:zan/generated/l10n/app_localizations.dart';
import 'package:zan/presentation/providers/account_provider.dart';
import 'package:zan/presentation/providers/transaction_list_provider.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactionsAsync = ref.watch(transactionListProvider);
    final accountsAsync = ref.watch(accountListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactions),
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(context, ref),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(child: Text(l10n.noTransactions));
          }

          final accounts = accountsAsync.valueOrNull ?? [];
          final grouped = _groupByDate(transactions);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final entry = grouped.entries.elementAt(index);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _formatDateHeader(entry.key, l10n),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
                  ...entry.value.map(
                    (t) => _TransactionTile(
                      transaction: t,
                      accounts: accounts,
                      onTap: () async {
                        final result = await context.push<bool>(
                          '${RoutePaths.transactionInput}?id=${t.id}',
                        );
                        if (result == true) {
                          ref.invalidate(transactionListProvider);
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<DateTime, List<Transaction>> _groupByDate(
      List<Transaction> transactions) {
    final grouped = <DateTime, List<Transaction>>{};
    for (final t in transactions) {
      final dateKey = t.date.dateOnly;
      grouped.putIfAbsent(dateKey, () => []).add(t);
    }
    return grouped;
  }

  String _formatDateHeader(DateTime date, AppLocalizations l10n) {
    if (date.isToday) return l10n.today;
    if (date.isYesterday) return l10n.yesterday;
    return date.yMd;
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).filter,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: Text(AppLocalizations.of(context).all),
              onTap: () {
                ref.read(transactionFilterProvider.notifier).state =
                    const TransactionFilter();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.accounts,
    required this.onTap,
  });

  final Transaction transaction;
  final List<Account> accounts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final debitAccount =
        accounts.where((a) => a.id == transaction.debitAccountId).firstOrNull;
    final creditAccount =
        accounts.where((a) => a.id == transaction.creditAccountId).firstOrNull;

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          transaction.description ??
              '${debitAccount?.name ?? '?'} → ${creditAccount?.name ?? '?'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${debitAccount?.name ?? '?'} → ${creditAccount?.name ?? '?'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          CurrencyFormatter.format(transaction.amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
