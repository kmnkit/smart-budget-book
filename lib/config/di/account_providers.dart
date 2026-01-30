import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/data/datasources/remote/account_remote_datasource.dart';
import 'package:zan/data/datasources/remote/profile_remote_datasource.dart';
import 'package:zan/data/datasources/remote/supabase_providers.dart';
import 'package:zan/data/repositories/account_repository_impl.dart';
import 'package:zan/data/repositories/profile_repository_impl.dart';
import 'package:zan/domain/repositories/account_repository.dart';
import 'package:zan/domain/repositories/profile_repository.dart';

part 'account_providers.g.dart';

@riverpod
AccountRemoteDataSource accountRemoteDataSource(Ref ref) {
  return AccountRemoteDataSource(ref.watch(supabaseClientProvider));
}

@riverpod
ProfileRemoteDataSource profileRemoteDataSource(Ref ref) {
  return ProfileRemoteDataSource(ref.watch(supabaseClientProvider));
}

@riverpod
AccountRepository accountRepository(Ref ref) {
  return AccountRepositoryImpl(ref.watch(accountRemoteDataSourceProvider));
}

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
}
