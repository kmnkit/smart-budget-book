import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zan/config/router/route_names.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/core/extensions/enum_l10n_extensions.dart';
import 'package:zan/domain/entities/account.dart';
import 'package:zan/generated/l10n/app_localizations.dart';
import 'package:zan/presentation/providers/account_provider.dart';

class AccountListScreen extends ConsumerWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(allAccountListProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accounts),
        actions: [
          IconButton(
            onPressed: () => context.push(RoutePaths.accountForm),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(child: Text(l10n.noAccounts));
          }

          final grouped = <AccountType, List<Account>>{};
          for (final account in accounts) {
            grouped.putIfAbsent(account.type, () => []).add(account);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.key.label(l10n),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ...entry.value.map(
                    (account) => _AccountTile(account: account),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account});
  final Account account;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(
            int.parse(account.color.replaceFirst('#', '0xFF')),
          ),
          child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
        ),
        title: Text(account.name),
        subtitle: Text(account.category.label(AppLocalizations.of(context))),
        trailing: account.isArchived
            ? Chip(
                label: Text(AppLocalizations.of(context).archived),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              )
            : null,
        onTap: () => context.push('${RoutePaths.accountForm}?id=${account.id}'),
      ),
    );
  }
}
