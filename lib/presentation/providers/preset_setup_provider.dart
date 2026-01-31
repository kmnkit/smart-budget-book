import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/di/account_providers.dart';
import 'package:zan/core/constants/country_presets.dart';
import 'package:zan/domain/entities/account.dart';
import 'package:zan/presentation/providers/auth_provider.dart';
import 'package:zan/presentation/providers/dashboard_provider.dart';

part 'preset_setup_provider.g.dart';

class PresetSetupState {
  const PresetSetupState({
    this.currentStep = 0,
    this.selectedPresetIndices = const {},
    this.initialBalances = const {},
    this.isLoading = false,
    this.error,
  });

  final int currentStep;
  final Set<int> selectedPresetIndices;
  final Map<int, int> initialBalances;
  final bool isLoading;
  final String? error;

  PresetSetupState copyWith({
    int? currentStep,
    Set<int>? selectedPresetIndices,
    Map<int, int>? initialBalances,
    bool? isLoading,
    String? error,
  }) {
    return PresetSetupState(
      currentStep: currentStep ?? this.currentStep,
      selectedPresetIndices: selectedPresetIndices ?? this.selectedPresetIndices,
      initialBalances: initialBalances ?? this.initialBalances,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class PresetSetupNotifier extends _$PresetSetupNotifier {
  @override
  PresetSetupState build() => const PresetSetupState();

  void initWithCountry(CountryPreset country) {
    final indices = Set<int>.from(
      List.generate(country.accounts.length, (i) => i),
    );
    state = state.copyWith(
      selectedPresetIndices: indices,
      initialBalances: {},
      currentStep: 0,
    );
  }

  void togglePresetAccount(int index) {
    final newSet = Set<int>.from(state.selectedPresetIndices);
    if (newSet.contains(index)) {
      newSet.remove(index);
    } else {
      newSet.add(index);
    }
    state = state.copyWith(selectedPresetIndices: newSet);
  }

  void setInitialBalance(int index, int amount) {
    final newBalances = Map<int, int>.from(state.initialBalances);
    newBalances[index] = amount;
    state = state.copyWith(initialBalances: newBalances);
  }

  void nextStep() {
    if (state.currentStep < 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<bool> createPresetAccounts(CountryPreset country) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final now = DateTime.now();
      final accounts = <Account>[];
      for (final index in state.selectedPresetIndices) {
        final preset = country.accounts[index];
        final initialBalance = state.initialBalances[index] ?? 0;
        accounts.add(
          Account(
            id: '',
            userId: userId,
            name: preset.name,
            type: preset.type,
            category: preset.category,
            icon: preset.icon,
            color: preset.color,
            initialBalance: initialBalance,
            currency: country.currency,
            displayOrder: index,
            isArchived: false,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      final accountRepo = ref.read(accountRepositoryProvider);
      final result = await accountRepo.createAccounts(accounts);
      if (result.isFailure) {
        state = state.copyWith(isLoading: false, error: 'Failed to create accounts');
        return false;
      }

      // Invalidate dashboard providers so home screen refreshes
      ref.invalidate(accountBalancesProvider);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
