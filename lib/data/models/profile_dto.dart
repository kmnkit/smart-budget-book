import 'package:zan/core/constants/enums.dart';
import 'package:zan/domain/entities/profile.dart';

class ProfileDto {
  const ProfileDto._();

  static Profile fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      defaultCurrency: json['default_currency'] as String? ?? 'JPY',
      country: json['country'] as String? ?? 'JP',
      defaultDebitAccountId: json['default_debit_account_id'] as String?,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      settings: (json['settings'] as Map<String, dynamic>?) ?? {},
      subscriptionTier: json['subscription_tier'] != null
          ? SubscriptionTier.fromDbValue(json['subscription_tier'] as String)
          : SubscriptionTier.free,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static Map<String, dynamic> toJson(Profile profile) {
    return {
      'id': profile.id,
      'display_name': profile.displayName,
      'default_currency': profile.defaultCurrency,
      'country': profile.country,
      'default_debit_account_id': profile.defaultDebitAccountId,
      'onboarding_completed': profile.onboardingCompleted,
      'settings': profile.settings,
    };
  }
}
