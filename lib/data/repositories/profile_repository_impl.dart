import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/datasources/remote/profile_remote_datasource.dart';
import 'package:zan/domain/entities/profile.dart';
import 'package:zan/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);
  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Result<Profile>> getProfile(String userId) async {
    try {
      final profile = await _remoteDataSource.getProfile(userId);
      return Success(profile);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateProfile(Profile profile) async {
    try {
      await _remoteDataSource.updateProfile(profile);
      return const Success(null);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> completeOnboarding({
    required String userId,
    required String country,
    required String currency,
  }) async {
    try {
      await _remoteDataSource.completeOnboarding(
        userId: userId,
        country: country,
        currency: currency,
      );
      return const Success(null);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }
}
