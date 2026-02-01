import 'package:flutter/material.dart';
import 'package:zan/core/constants/country_presets.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/generated/l10n/app_localizations.dart';

class BalanceInputView extends StatelessWidget {
  const BalanceInputView({
    super.key,
    required this.country,
    required this.selectedIndices,
    required this.balances,
    required this.onBalanceChanged,
  });

  final CountryPreset country;
  final Set<int> selectedIndices;
  final Map<int, int> balances;
  final void Function(int, int) onBalanceChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final balanceAccounts = selectedIndices
        .where((i) {
          final type = country.accounts[i].type;
          return type == AccountType.asset || type == AccountType.liability;
        })
        .toList()
      ..sort();

    if (balanceAccounts.isEmpty) {
      return Center(child: Text(l10n.noInitialBalanceNeeded));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: balanceAccounts.length,
      itemBuilder: (context, index) {
        final accountIndex = balanceAccounts[index];
        final account = country.accounts[accountIndex];
        final isLiability = account.type == AccountType.liability;
        final balanceLabel = isLiability ? l10n.outstandingBalance : l10n.initialBalance;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: account.localizedName(locale),
              helperText: balanceLabel,
              suffixText: country.currency,
              prefixIcon: Icon(
                Icons.circle,
                color: Color(int.parse(account.color.replaceFirst('#', '0xFF'))),
                size: 20,
              ),
            ),
            keyboardType: TextInputType.number,
            initialValue: balances[accountIndex]?.toString() ?? '',
            onChanged: (value) {
              final amount = int.tryParse(value) ?? 0;
              onBalanceChanged(accountIndex, amount);
            },
          ),
        );
      },
    );
  }
}
