import 'package:zan/core/usecase/result.dart';
import 'package:zan/core/usecase/usecase.dart';
import 'package:zan/domain/repositories/auth_repository.dart';

class SignInParams {
  const SignInParams({required this.email, required this.password});
  final String email;
  final String password;
}

class SignInUseCase implements UseCase<void, SignInParams> {
  const SignInUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<void>> call(SignInParams params) {
    return _repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}
