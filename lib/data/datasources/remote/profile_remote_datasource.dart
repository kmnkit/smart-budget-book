import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zan/data/models/profile_dto.dart';
import 'package:zan/domain/entities/profile.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._client);
  final SupabaseClient _client;

  Future<Profile> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return ProfileDto.fromJson(data);
  }

  Future<void> updateProfile(Profile profile) async {
    await _client
        .from('profiles')
        .update(ProfileDto.toJson(profile))
        .eq('id', profile.id);
  }

  Future<void> completeOnboarding({
    required String userId,
    required String country,
    required String currency,
  }) async {
    await _client.from('profiles').update({
      'country': country,
      'default_currency': currency,
      'onboarding_completed': true,
    }).eq('id', userId);
  }
}
