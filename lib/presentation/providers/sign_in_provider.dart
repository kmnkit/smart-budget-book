import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/di/auth_providers.dart';
import 'package:zan/domain/usecases/sign_in_usecase.dart';

part 'sign_in_provider.g.dart';

@riverpod
class SignInNotifier extends _$SignInNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(signInUseCaseProvider).call(
          SignInParams(email: email, password: password),
        );
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }
}
