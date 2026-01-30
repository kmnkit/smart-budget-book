import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

@Freezed()
sealed class Profile with _$Profile {
  const factory Profile({
    required String id,
    String? displayName,
    required String defaultCurrency,
    required String country,
    String? defaultDebitAccountId,
    required bool onboardingCompleted,
    @Default({}) Map<String, dynamic> settings,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Profile;
}
