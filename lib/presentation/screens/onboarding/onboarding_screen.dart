import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zan/config/router/route_names.dart';
import 'package:zan/core/constants/country_presets.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/generated/l10n/app_localizations.dart';
import 'package:zan/presentation/providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text([
          l10n.onboardingTitle1,
          l10n.onboardingTitle2,
          l10n.onboardingTitle3,
        ][state.currentStep]),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= state.currentStep
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Content
          Expanded(
            child: IndexedStack(
              index: state.currentStep,
              children: [
                _CountrySelection(
                  selectedCountry: state.selectedCountry,
                  onSelect: notifier.selectCountry,
                ),
                _PresetSelection(
                  country: state.selectedCountry,
                  selectedIndices: state.selectedPresetIndices,
                  onToggle: notifier.togglePresetAccount,
                ),
                _BalanceInput(
                  country: state.selectedCountry,
                  selectedIndices: state.selectedPresetIndices,
                  balances: state.initialBalances,
                  onBalanceChanged: notifier.setInitialBalance,
                ),
              ],
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (state.currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: notifier.previousStep,
                      child: Text(l10n.previous),
                    ),
                  ),
                if (state.currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            if (state.currentStep < 2) {
                              if (state.currentStep == 0 && state.selectedCountry == null) {
                                return;
                              }
                              notifier.nextStep();
                            } else {
                              final success = await notifier.completeOnboarding();
                              if (success && context.mounted) {
                                context.go(RoutePaths.home);
                              }
                            }
                          },
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(state.currentStep < 2 ? l10n.next : l10n.complete),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountrySelection extends StatelessWidget {
  const _CountrySelection({
    required this.selectedCountry,
    required this.onSelect,
  });

  final CountryPreset? selectedCountry;
  final void Function(CountryPreset) onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: countryPresets.length,
      itemBuilder: (context, index) {
        final preset = countryPresets[index];
        final isSelected = selectedCountry?.code == preset.code;
        return Card(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            leading: Text(preset.flag, style: const TextStyle(fontSize: 32)),
            title: Text(preset.name),
            subtitle: Text(preset.nameEn),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () => onSelect(preset),
          ),
        );
      },
    );
  }
}

class _PresetSelection extends StatelessWidget {
  const _PresetSelection({
    required this.country,
    required this.selectedIndices,
    required this.onToggle,
  });

  final CountryPreset? country;
  final Set<int> selectedIndices;
  final void Function(int) onToggle;

  @override
  Widget build(BuildContext context) {
    if (country == null) return const SizedBox.shrink();

    final groupedByType = <AccountType, List<MapEntry<int, PresetAccount>>>{};
    for (var i = 0; i < country!.accounts.length; i++) {
      final account = country!.accounts[i];
      groupedByType.putIfAbsent(account.type, () => []).add(MapEntry(i, account));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: groupedByType.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key.name.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...entry.value.map((mapEntry) {
              final index = mapEntry.key;
              final account = mapEntry.value;
              final isSelected = selectedIndices.contains(index);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (_) => onToggle(index),
                title: Text(account.name),
                subtitle: Text(account.nameEn),
                secondary: Icon(
                  Icons.circle,
                  color: Color(int.parse(account.color.replaceFirst('#', '0xFF'))),
                  size: 24,
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}

class _BalanceInput extends StatelessWidget {
  const _BalanceInput({
    required this.country,
    required this.selectedIndices,
    required this.balances,
    required this.onBalanceChanged,
  });

  final CountryPreset? country;
  final Set<int> selectedIndices;
  final Map<int, int> balances;
  final void Function(int, int) onBalanceChanged;

  @override
  Widget build(BuildContext context) {
    if (country == null) return const SizedBox.shrink();

    final balanceAccounts = selectedIndices
        .where((i) {
          final type = country!.accounts[i].type;
          return type == AccountType.asset || type == AccountType.liability;
        })
        .toList()
      ..sort();

    if (balanceAccounts.isEmpty) {
      return const Center(child: Text('No accounts need initial balances'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: balanceAccounts.length,
      itemBuilder: (context, index) {
        final accountIndex = balanceAccounts[index];
        final account = country!.accounts[accountIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: account.name,
              suffixText: country!.currency,
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
