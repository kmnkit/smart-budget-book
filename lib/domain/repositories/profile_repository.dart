import 'package:zan/core/usecase/result.dart';
import 'package:zan/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<Result<Profile>> getProfile(String userId);
  Future<Result<void>> updateProfile(Profile profile);
  Future<Result<void>> completeOnboarding({
    required String userId,
    required String country,
    required String currency,
  });
}
