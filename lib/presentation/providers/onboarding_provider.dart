import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/di/account_providers.dart';
import 'package:zan/core/constants/country_presets.dart';
import 'package:zan/presentation/providers/auth_provider.dart';

part 'onboarding_provider.g.dart';

class OnboardingState {
  const OnboardingState({
    this.selectedCountry,
    this.isLoading = false,
    this.error,
  });

  final CountryPreset? selectedCountry;
  final bool isLoading;
  final String? error;

  OnboardingState copyWith({
    CountryPreset? selectedCountry,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      selectedCountry: selectedCountry ?? this.selectedCountry,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() => const OnboardingState();

  void selectCountry(CountryPreset country) {
    state = state.copyWith(selectedCountry: country);
  }

  Future<bool> completeOnboarding() async {
    final country = state.selectedCountry;
    if (country == null) return false;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final profileResult = await profileRepo.completeOnboarding(
        userId: userId,
        country: country.code,
        currency: country.currency,
      );
      if (profileResult.isFailure) {
        state = state.copyWith(isLoading: false, error: 'Failed to update profile');
        return false;
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
