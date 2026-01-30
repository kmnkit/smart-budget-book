import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/di/auth_providers.dart';
import 'package:zan/domain/usecases/sign_up_usecase.dart';

part 'sign_up_provider.g.dart';

@riverpod
class SignUpNotifier extends _$SignUpNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(signUpUseCaseProvider).call(
          SignUpParams(
            email: email,
            password: password,
            displayName: displayName,
          ),
        );
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }
}
