import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/env/env.dart';
import 'package:zan/data/datasources/remote/auth_remote_datasource.dart';
import 'package:zan/data/datasources/remote/supabase_providers.dart';
import 'package:zan/data/repositories/auth_repository_impl.dart';
import 'package:zan/domain/repositories/auth_repository.dart';
import 'package:zan/domain/usecases/delete_account_usecase.dart';
import 'package:zan/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:zan/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:zan/domain/usecases/sign_out_usecase.dart';

part 'auth_providers.g.dart';

@riverpod
GoogleSignIn googleSignIn(Ref ref) {
  return GoogleSignIn(
    // Android: clientId 불필요 (패키지명+SHA1로 자동 매칭)
    // iOS: clientId 필수
    clientId: Platform.isIOS ? Env.googleIosClientId : null,
    serverClientId: Env.googleWebClientId,
  );
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSource(
    ref.watch(supabaseAuthProvider),
    ref.watch(supabaseClientProvider),
    ref.watch(googleSignInProvider),
  );
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
}

@riverpod
SignInWithGoogleUseCase signInWithGoogleUseCase(Ref ref) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
SignInWithAppleUseCase signInWithAppleUseCase(Ref ref) {
  return SignInWithAppleUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
SignOutUseCase signOutUseCase(Ref ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
DeleteAccountUseCase deleteAccountUseCase(Ref ref) {
  return DeleteAccountUseCase(ref.watch(authRepositoryProvider));
}
