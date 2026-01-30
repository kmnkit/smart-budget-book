import 'package:zan/core/usecase/result.dart';

abstract class AuthRepository {
  Future<Result<void>> signIn({
    required String email,
    required String password,
  });
  Future<Result<void>> signUp({
    required String email,
    required String password,
    String? displayName,
  });
  Future<Result<void>> signOut();
  Stream<bool> get authStateChanges;
}
