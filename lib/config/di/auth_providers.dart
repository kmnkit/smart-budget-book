import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/data/datasources/remote/auth_remote_datasource.dart';
import 'package:zan/data/datasources/remote/supabase_providers.dart';
import 'package:zan/data/repositories/auth_repository_impl.dart';
import 'package:zan/domain/repositories/auth_repository.dart';
import 'package:zan/domain/usecases/sign_in_usecase.dart';
import 'package:zan/domain/usecases/sign_out_usecase.dart';
import 'package:zan/domain/usecases/sign_up_usecase.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSource(ref.watch(supabaseAuthProvider));
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
}

@riverpod
SignInUseCase signInUseCase(Ref ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
SignUpUseCase signUpUseCase(Ref ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
SignOutUseCase signOutUseCase(Ref ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
}
