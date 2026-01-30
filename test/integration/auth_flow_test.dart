import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zan/config/di/auth_providers.dart';
import 'package:zan/presentation/providers/sign_in_provider.dart';
import 'package:zan/presentation/providers/sign_up_provider.dart';

import '../../test/helpers/test_helpers.dart';

void main() {
  late MockAuthRemoteDataSource mockAuthDS;

  setUp(() {
    mockAuthDS = MockAuthRemoteDataSource();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        authRemoteDataSourceProvider.overrideWith((ref) => mockAuthDS),
      ],
    );
  }

  group('Auth Flow Integration', () {
    group('SignIn 플로우', () {
      test('성공: DataSource → Repository → UseCase → Notifier 전체 체인 검증', () async {
        // arrange
        when(() => mockAuthDS.signIn(
              email: 'test@example.com',
              password: 'password123',
            )).thenAnswer((_) async => FakeAuthResponse());

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(signInNotifierProvider.notifier);

        // act
        await notifier.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        // assert
        final state = container.read(signInNotifierProvider);
        expect(state, isA<AsyncData<void>>());
        verify(() => mockAuthDS.signIn(
              email: 'test@example.com',
              password: 'password123',
            )).called(1);
      });

      test('실패: DataSource 예외 → AuthFailure → AsyncError 전파 검증', () async {
        // arrange
        when(() => mockAuthDS.signIn(
              email: 'test@example.com',
              password: 'wrong',
            )).thenThrow(Exception('Invalid credentials'));

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(signInNotifierProvider.notifier);

        // act
        await notifier.signIn(
          email: 'test@example.com',
          password: 'wrong',
        );

        // assert
        final state = container.read(signInNotifierProvider);
        expect(state, isA<AsyncError<void>>());
      });
    });

    group('SignUp 플로우', () {
      test('성공: DataSource → Repository → UseCase → Notifier 전체 체인 검증', () async {
        // arrange
        when(() => mockAuthDS.signUp(
              email: 'new@example.com',
              password: 'password123',
              displayName: null,
            )).thenAnswer((_) async => FakeAuthResponse());

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(signUpNotifierProvider.notifier);

        // act
        await notifier.signUp(
          email: 'new@example.com',
          password: 'password123',
        );

        // assert
        final state = container.read(signUpNotifierProvider);
        expect(state, isA<AsyncData<void>>());
        verify(() => mockAuthDS.signUp(
              email: 'new@example.com',
              password: 'password123',
              displayName: null,
            )).called(1);
      });

      test('실패: DataSource 예외 → AuthFailure → AsyncError 전파 검증', () async {
        // arrange
        when(() => mockAuthDS.signUp(
              email: 'existing@example.com',
              password: 'password123',
              displayName: null,
            )).thenThrow(Exception('Email already exists'));

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(signUpNotifierProvider.notifier);

        // act
        await notifier.signUp(
          email: 'existing@example.com',
          password: 'password123',
        );

        // assert
        final state = container.read(signUpNotifierProvider);
        expect(state, isA<AsyncError<void>>());
      });

      test('displayName 파라미터가 DataSource까지 정확히 전파되는지 검증', () async {
        // arrange
        when(() => mockAuthDS.signUp(
              email: 'new@example.com',
              password: 'password123',
              displayName: 'Test User',
            )).thenAnswer((_) async => FakeAuthResponse());

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(signUpNotifierProvider.notifier);

        // act
        await notifier.signUp(
          email: 'new@example.com',
          password: 'password123',
          displayName: 'Test User',
        );

        // assert
        verify(() => mockAuthDS.signUp(
              email: 'new@example.com',
              password: 'password123',
              displayName: 'Test User',
            )).called(1);
      });
    });
  });
}
