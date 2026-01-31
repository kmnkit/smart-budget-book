import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/di/auth_providers.dart';
import 'package:zan/core/usecase/usecase.dart';

part 'sign_in_provider.g.dart';

@riverpod
class SocialSignInNotifier extends _$SocialSignInNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final result =
        await ref.read(signInWithGoogleUseCaseProvider).call(const NoParams());
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    final result =
        await ref.read(signInWithAppleUseCaseProvider).call(const NoParams());
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }
}
