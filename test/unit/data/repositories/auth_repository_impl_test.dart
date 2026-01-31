import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/repositories/auth_repository_impl.dart';

import '../../../helpers/test_helpers.dart';

class _FakeAuthResponse extends Fake implements AuthResponse {}

class _FakeSession extends Fake implements Session {}

class _FakeAuthState extends Fake implements AuthState {
  _FakeAuthState({this.session});
  @override
  final Session? session;
}

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  group('AuthRepositoryImpl', () {
    group('signInWithGoogle', () {
      test('성공 시 Success(null) 반환', () async {
        // arrange
        when(() => mockDataSource.signInWithGoogle())
            .thenAnswer((_) async => _FakeAuthResponse());

        // act
        final result = await repository.signInWithGoogle();

        // assert
        expect(result, isA<Success<void>>());
        verify(() => mockDataSource.signInWithGoogle()).called(1);
      });

      test('실패 시 Fail(AuthFailure) 반환', () async {
        // arrange
        when(() => mockDataSource.signInWithGoogle())
            .thenThrow(Exception('Google sign-in was cancelled'));

        // act
        final result = await repository.signInWithGoogle();

        // assert
        expect(result, isA<Fail<void>>());
        expect((result as Fail<void>).failure, isA<AuthFailure>());
        expect(result.failure.message, contains('Google sign-in was cancelled'));
      });
    });

    group('signInWithApple', () {
      test('성공 시 Success(null) 반환', () async {
        // arrange
        when(() => mockDataSource.signInWithApple())
            .thenAnswer((_) async => _FakeAuthResponse());

        // act
        final result = await repository.signInWithApple();

        // assert
        expect(result, isA<Success<void>>());
        verify(() => mockDataSource.signInWithApple()).called(1);
      });

      test('실패 시 Fail(AuthFailure) 반환', () async {
        // arrange
        when(() => mockDataSource.signInWithApple())
            .thenThrow(Exception('Apple sign-in failed'));

        // act
        final result = await repository.signInWithApple();

        // assert
        expect(result, isA<Fail<void>>());
        expect((result as Fail<void>).failure, isA<AuthFailure>());
        expect(result.failure.message, contains('Apple sign-in failed'));
      });
    });

    group('signOut', () {
      test('성공 시 Success(null) 반환', () async {
        // arrange
        when(() => mockDataSource.signOut()).thenAnswer((_) async {});

        // act
        final result = await repository.signOut();

        // assert
        expect(result, isA<Success<void>>());
        verify(() => mockDataSource.signOut()).called(1);
      });

      test('실패 시 Fail(AuthFailure) 반환', () async {
        // arrange
        when(() => mockDataSource.signOut())
            .thenThrow(Exception('Sign out failed'));

        // act
        final result = await repository.signOut();

        // assert
        expect(result, isA<Fail<void>>());
        expect((result as Fail<void>).failure, isA<AuthFailure>());
      });
    });

    group('deleteAccount', () {
      test('성공 시 Success(null) 반환', () async {
        // arrange
        when(() => mockDataSource.deleteAccount()).thenAnswer((_) async {});

        // act
        final result = await repository.deleteAccount();

        // assert
        expect(result, isA<Success<void>>());
        verify(() => mockDataSource.deleteAccount()).called(1);
      });

      test('실패 시 Fail(AuthFailure) 반환', () async {
        // arrange
        when(() => mockDataSource.deleteAccount())
            .thenThrow(Exception('Delete failed'));

        // act
        final result = await repository.deleteAccount();

        // assert
        expect(result, isA<Fail<void>>());
        expect((result as Fail<void>).failure, isA<AuthFailure>());
      });
    });

    group('authStateChanges', () {
      test('session이 있을 때 true를 emit', () async {
        // arrange
        final session = _FakeSession();
        when(() => mockDataSource.onAuthStateChange)
            .thenAnswer((_) => Stream.value(_FakeAuthState(session: session)));

        // act & assert
        expect(await repository.authStateChanges.first, true);
      });

      test('session이 null일 때 false를 emit', () async {
        // arrange
        when(() => mockDataSource.onAuthStateChange)
            .thenAnswer((_) => Stream.value(_FakeAuthState(session: null)));

        // act & assert
        expect(await repository.authStateChanges.first, false);
      });

      test('여러 상태 변화를 올바르게 매핑', () {
        // arrange
        final session = _FakeSession();
        when(() => mockDataSource.onAuthStateChange).thenAnswer(
          (_) => Stream.fromIterable([
            _FakeAuthState(session: null),
            _FakeAuthState(session: session),
            _FakeAuthState(session: null),
          ]),
        );

        // act & assert
        expect(
          repository.authStateChanges,
          emitsInOrder([false, true, false]),
        );
      });
    });
  });
}
