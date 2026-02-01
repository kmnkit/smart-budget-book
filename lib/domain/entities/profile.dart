import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zan/core/constants/enums.dart';

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
    @Default(SubscriptionTier.free) SubscriptionTier subscriptionTier,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Profile;
}
