import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/datasources/remote/auth_remote_datasource.dart';
import 'package:zan/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);
  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Result<void>> signInWithGoogle() async {
    try {
      await _remoteDataSource.signInWithGoogle();
      return const Success(null);
    } catch (e) {
      return Fail(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signInWithApple() async {
    try {
      await _remoteDataSource.signInWithApple();
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
  Future<Result<void>> deleteAccount() async {
    try {
      await _remoteDataSource.deleteAccount();
      return const Success(null);
    } catch (e) {
      return Fail(AuthFailure(e.toString()));
    }
  }

  @override
  Stream<bool> get authStateChanges =>
      _remoteDataSource.onAuthStateChange.map((state) => state.session != null);
}
