import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/datasources/remote/auth_remote_datasource.dart';
import 'package:zan/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);
  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.signIn(email: email, password: password);
      return const Success(null);
    } catch (e) {
      return Fail(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      await _remoteDataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return const Success(null);
    } catch (e) {
      return Fail(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Success(null);
    } catch (e) {
      return Fail(AuthFailure(e.toString()));
    }
  }

  @override
  Stream<bool> get authStateChanges =>
      _remoteDataSource.onAuthStateChange.map((state) => state.session != null);
}
