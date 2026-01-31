import 'package:zan/core/usecase/result.dart';
import 'package:zan/core/usecase/usecase.dart';
import 'package:zan/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase implements UseCase<void, NoParams> {
  const SignInWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.signInWithGoogle();
  }
}
