import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zan/core/constants/country_presets.dart';
import 'package:zan/generated/l10n/app_localizations.dart';
import 'package:zan/presentation/providers/preset_setup_provider.dart';
import 'package:zan/presentation/providers/settings_provider.dart';
import 'package:zan/presentation/widgets/balance_input_view.dart';
import 'package:zan/presentation/widgets/preset_selection_view.dart';

class PresetSetupScreen extends ConsumerStatefulWidget {
  const PresetSetupScreen({super.key});

  @override
  ConsumerState<PresetSetupScreen> createState() => _PresetSetupScreenState();
}

class _PresetSetupScreenState extends ConsumerState<PresetSetupScreen> {
  CountryPreset? _country;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCountry();
    });
  }

  void _initCountry() {
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile != null) {
      final country = countryPresets.where((c) => c.code == profile.country).firstOrNull;
      if (country != null) {
        setState(() => _country = country);
        ref.read(presetSetupNotifierProvider.notifier).initWithCountry(country);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(presetSetupNotifierProvider);
    final notifier = ref.read(presetSetupNotifierProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final country = _country;

    if (country == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.presetSetupTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.currentStep == 0
              ? l10n.presetSelectAccounts
              : l10n.presetSetBalances,
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: List.generate(2, (index) {
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
            child: state.currentStep == 0
                ? PresetSelectionView(
                    country: country,
                    selectedIndices: state.selectedPresetIndices,
                    onToggle: notifier.togglePresetAccount,
                  )
                : BalanceInputView(
                    country: country,
                    selectedIndices: state.selectedPresetIndices,
                    balances: state.initialBalances,
                    onBalanceChanged: notifier.setInitialBalance,
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
                            if (state.currentStep < 1) {
                              notifier.nextStep();
                            } else {
                              final locale = Localizations.localeOf(context).languageCode;
                              final success =
                                  await notifier.createPresetAccounts(country, locale);
                              if (success && context.mounted) {
                                context.pop();
                              }
                            }
                          },
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            state.currentStep < 1 ? l10n.next : l10n.complete,
                          ),
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
