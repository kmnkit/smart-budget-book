import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/di/account_providers.dart';
import 'package:zan/config/di/auth_providers.dart';
import 'package:zan/core/usecase/usecase.dart';
import 'package:zan/domain/entities/profile.dart';
import 'package:zan/presentation/providers/auth_provider.dart';

part 'settings_provider.g.dart';

@riverpod
Future<Profile?> userProfile(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  final repo = ref.watch(profileRepositoryProvider);
  final result = await repo.getProfile(userId);
  return result.when(
    success: (profile) => profile,
    failure: (_) => null,
  );
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signOut() async {
    state = const AsyncLoading();
    final result = await ref.read(signOutUseCaseProvider).call(const NoParams());
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    final result =
        await ref.read(deleteAccountUseCaseProvider).call(const NoParams());
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }

  Future<void> updateDefaultPaymentMethod(String accountId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final profileRepo = ref.read(profileRepositoryProvider);
    final profileResult = await profileRepo.getProfile(userId);
    await profileResult.when(
      success: (profile) async {
        final updated = profile.copyWith(defaultDebitAccountId: accountId);
        await profileRepo.updateProfile(updated);
        ref.invalidate(userProfileProvider);
      },
      failure: (_) async {},
    );
  }
}
