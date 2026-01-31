import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zan/config/router/route_names.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/core/utils/currency_formatter.dart';
import 'package:zan/domain/entities/account_balance.dart';
import 'package:zan/generated/l10n/app_localizations.dart';
import 'package:zan/presentation/providers/dashboard_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final balancesAsync = ref.watch(accountBalancesProvider);
    final summaryAsync = ref.watch(currentMonthSummaryProvider);
    final netWorthValue = ref.watch(netWorthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountBalancesProvider);
          ref.invalidate(currentMonthSummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Net Worth Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      l10n.netWorth,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(netWorthValue),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Monthly Summary
            summaryAsync.when(
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (summary) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              l10n.monthlyIncome,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(summary.totalIncome),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              l10n.monthlyExpense,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(summary.totalExpense),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Account Balances
            balancesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SizedBox.shrink(),
              data: (balances) {
                if (balances.isEmpty) {
                  return _HomeEmptyState();
                }

                final assets =
                    balances.where((b) => b.type == AccountType.asset).toList();
                final liabilities = balances
                    .where((b) => b.type == AccountType.liability)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (assets.isNotEmpty) ...[
                      _SectionHeader(title: l10n.totalAssets),
                      ...assets.map((b) => _BalanceTile(balance: b)),
                      const SizedBox(height: 16),
                    ],
                    if (liabilities.isNotEmpty) ...[
                      _SectionHeader(title: l10n.totalLiabilities),
                      ...liabilities.map((b) => _BalanceTile(balance: b)),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({required this.balance});
  final AccountBalance balance;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(
            int.parse(balance.color.replaceFirst('#', '0xFF')),
          ),
          radius: 18,
          child: const Icon(Icons.account_balance_wallet,
              size: 18, color: Colors.white),
        ),
        title: Text(balance.name),
        trailing: Text(
          CurrencyFormatter.format(balance.balance, currency: balance.currency),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.homeEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeEmptySubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push(RoutePaths.presetSetup),
            icon: const Icon(Icons.playlist_add),
            label: Text(l10n.presetSetupButton),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push(RoutePaths.accountForm),
            child: Text(l10n.addManually),
          ),
        ],
      ),
    );
  }
}
