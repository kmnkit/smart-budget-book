import 'package:zan/core/usecase/result.dart';

abstract class AuthRepository {
  Future<Result<void>> signInWithGoogle();
  Future<Result<void>> signInWithApple();
  Future<Result<void>> signOut();
  Future<Result<void>> deleteAccount();
  Stream<bool> get authStateChanges;
}
