import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

@riverpod
GoTrueClient supabaseAuth(Ref ref) {
  return ref.watch(supabaseClientProvider).auth;
}

@riverpod
SupabaseQueryBuilder accountsTable(Ref ref) {
  return ref.watch(supabaseClientProvider).from('accounts');
}

@riverpod
SupabaseQueryBuilder transactionsTable(Ref ref) {
  return ref.watch(supabaseClientProvider).from('transactions');
}

@riverpod
SupabaseQueryBuilder profilesTable(Ref ref) {
  return ref.watch(supabaseClientProvider).from('profiles');
}
