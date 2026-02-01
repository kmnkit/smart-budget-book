import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/services/crashlytics_service.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/datasources/remote/auth_remote_datasource.dart';
import 'package:zan/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);
  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Result<void>> signInWithGoogle() async {
    try {
      final response = await _remoteDataSource.signInWithGoogle();
      _setCrashlyticsUser(response.user?.id);
      return const Success(null);
    } catch (e) {
      return Fail(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signInWithApple() async {
    try {
      final response = await _remoteDataSource.signInWithApple();
      _setCrashlyticsUser(response.user?.id);
      return const Success(null);
    } catch (e) {
      return Fail(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      _setCrashlyticsUser('');
      return const Success(null);
    } catch (e) {
      return Fail(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _remoteDataSource.deleteAccount();
      _setCrashlyticsUser('');
      return const Success(null);
    } catch (e) {
      return Fail(AuthFailure(e.toString()));
    }
  }

  void _setCrashlyticsUser(String? userId) {
    try {
      CrashlyticsService.instance.setUserIdentifier(userId ?? '');
    } catch (_) {
      // Crashlytics는 관측용이므로 실패해도 인증 흐름에 영향 없음
    }
  }

  @override
  Stream<bool> get authStateChanges =>
      _remoteDataSource.onAuthStateChange.map((state) => state.session != null);
}
