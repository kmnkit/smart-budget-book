import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/core/usecase/usecase.dart';
import 'package:zan/domain/usecases/sign_in_usecase.dart';
import 'package:zan/domain/usecases/sign_out_usecase.dart';
import 'package:zan/domain/usecases/sign_up_usecase.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('SignInUseCase', () {
    late SignInUseCase useCase;

    setUp(() {
      useCase = SignInUseCase(mockRepository);
    });

    test('성공 시 Success(null) 반환', () async {
      // arrange
      const params = SignInParams(
        email: 'test@example.com',
        password: 'password123',
      );
      when(() => mockRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Success(null));

      // act
      final result = await useCase(params);

      // assert
      expect(result, isA<Success<void>>());
      verify(() => mockRepository.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    test('실패 시 Fail(AuthFailure) 반환', () async {
      // arrange
      const params = SignInParams(
        email: 'test@example.com',
        password: 'wrong_password',
      );
      when(() => mockRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Fail(AuthFailure()));

      // act
      final result = await useCase(params);

      // assert
      expect(result, isA<Fail<void>>());
      final failure = (result as Fail<void>).failure;
      expect(failure, isA<AuthFailure>());
      verify(() => mockRepository.signIn(
            email: 'test@example.com',
            password: 'wrong_password',
          )).called(1);
    });

    test('파라미터 전달 검증 (email, password)', () async {
      // arrange
      const params = SignInParams(
        email: 'user@test.com',
        password: 'secure_pass',
      );
      when(() => mockRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Success(null));

      // act
      await useCase(params);

      // assert
      verify(() => mockRepository.signIn(
            email: 'user@test.com',
            password: 'secure_pass',
          )).called(1);
    });
  });

  group('SignUpUseCase', () {
    late SignUpUseCase useCase;

    setUp(() {
      useCase = SignUpUseCase(mockRepository);
    });

    test('성공 시 Success(null) 반환', () async {
      // arrange
      const params = SignUpParams(
        email: 'newuser@example.com',
        password: 'password123',
      );
      when(() => mockRepository.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => const Success(null));

      // act
      final result = await useCase(params);

      // assert
      expect(result, isA<Success<void>>());
      verify(() => mockRepository.signUp(
            email: 'newuser@example.com',
            password: 'password123',
            displayName: null,
          )).called(1);
    });

    test('displayName 포함 시 전달 검증', () async {
      // arrange
      const params = SignUpParams(
        email: 'newuser@example.com',
        password: 'password123',
        displayName: 'Test User',
      );
      when(() => mockRepository.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => const Success(null));

      // act
      await useCase(params);

      // assert
      verify(() => mockRepository.signUp(
            email: 'newuser@example.com',
            password: 'password123',
            displayName: 'Test User',
          )).called(1);
    });

    test('실패 시 Fail(AuthFailure) 반환', () async {
      // arrange
      const params = SignUpParams(
        email: 'invalid@example.com',
        password: 'weak',
      );
      when(() => mockRepository.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer(
          (_) async => const Fail(AuthFailure('Password too weak')));

      // act
      final result = await useCase(params);

      // assert
      expect(result, isA<Fail<void>>());
      final failure = (result as Fail<void>).failure;
      expect(failure, isA<AuthFailure>());
      verify(() => mockRepository.signUp(
            email: 'invalid@example.com',
            password: 'weak',
            displayName: null,
          )).called(1);
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
}
