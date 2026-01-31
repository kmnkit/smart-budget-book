import 'package:zan/core/usecase/result.dart';
import 'package:zan/core/usecase/usecase.dart';
import 'package:zan/domain/repositories/auth_repository.dart';

class DeleteAccountUseCase implements UseCase<void, NoParams> {
  const DeleteAccountUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.deleteAccount();
  }
}
