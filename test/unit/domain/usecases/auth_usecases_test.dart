import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/core/usecase/usecase.dart';
import 'package:zan/domain/usecases/delete_account_usecase.dart';
import 'package:zan/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:zan/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:zan/domain/usecases/sign_out_usecase.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('SignInWithGoogleUseCase', () {
    late SignInWithGoogleUseCase useCase;

    setUp(() {
      useCase = SignInWithGoogleUseCase(mockRepository);
    });

    test('성공 시 Success(null) 반환', () async {
      // arrange
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => const Success(null));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, isA<Success<void>>());
      verify(() => mockRepository.signInWithGoogle()).called(1);
    });

    test('실패 시 Fail(AuthFailure) 반환', () async {
      // arrange
      when(() => mockRepository.signInWithGoogle()).thenAnswer(
          (_) async => const Fail(AuthFailure('Google sign-in cancelled')));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, isA<Fail<void>>());
      final failure = (result as Fail<void>).failure;
      expect(failure, isA<AuthFailure>());
      verify(() => mockRepository.signInWithGoogle()).called(1);
    });
  });

  group('SignInWithAppleUseCase', () {
    late SignInWithAppleUseCase useCase;

    setUp(() {
      useCase = SignInWithAppleUseCase(mockRepository);
    });

    test('성공 시 Success(null) 반환', () async {
      // arrange
      when(() => mockRepository.signInWithApple())
          .thenAnswer((_) async => const Success(null));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, isA<Success<void>>());
      verify(() => mockRepository.signInWithApple()).called(1);
    });

    test('실패 시 Fail(AuthFailure) 반환', () async {
      // arrange
      when(() => mockRepository.signInWithApple()).thenAnswer(
          (_) async => const Fail(AuthFailure('Apple sign-in failed')));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, isA<Fail<void>>());
      final failure = (result as Fail<void>).failure;
      expect(failure, isA<AuthFailure>());
      verify(() => mockRepository.signInWithApple()).called(1);
    });
  });

  group('SignOutUseCase', () {
    late SignOutUseCase useCase;

    setUp(() {
      useCase = SignOutUseCase(mockRepository);
    });

    test('성공 시 Success(null) 반환', () async {
      // arrange
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Success(null));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, isA<Success<void>>());
      verify(() => mockRepository.signOut()).called(1);
    });

    test('실패 시 Fail(AuthFailure) 반환', () async {
      // arrange
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Fail(AuthFailure('Session expired')));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, isA<Fail<void>>());
      final failure = (result as Fail<void>).failure;
      expect(failure, isA<AuthFailure>());
      verify(() => mockRepository.signOut()).called(1);
    });
  });

  group('DeleteAccountUseCase', () {
    late DeleteAccountUseCase useCase;

    setUp(() {
      useCase = DeleteAccountUseCase(mockRepository);
    });

    test('성공 시 Success(null) 반환', () async {
      // arrange
      when(() => mockRepository.deleteAccount())
          .thenAnswer((_) async => const Success(null));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, isA<Success<void>>());
      verify(() => mockRepository.deleteAccount()).called(1);
    });

    test('실패 시 Fail(AuthFailure) 반환', () async {
      // arrange
      when(() => mockRepository.deleteAccount())
          .thenAnswer((_) async => const Fail(AuthFailure('Delete failed')));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, isA<Fail<void>>());
      final failure = (result as Fail<void>).failure;
      expect(failure, isA<AuthFailure>());
      verify(() => mockRepository.deleteAccount()).called(1);
    });
  });
}
