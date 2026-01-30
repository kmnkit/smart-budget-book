import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zan/data/datasources/remote/supabase_providers.dart';

part 'auth_provider.g.dart';

@riverpod
Stream<AuthState> authState(Ref ref) {
  final auth = ref.watch(supabaseAuthProvider);
  return auth.onAuthStateChange;
}

@riverpod
User? currentUser(Ref ref) {
  final auth = ref.watch(supabaseAuthProvider);
  return auth.currentUser;
}

@riverpod
String? currentUserId(Ref ref) {
  return ref.watch(currentUserProvider)?.id;
}
