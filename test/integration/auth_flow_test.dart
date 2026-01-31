import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zan/config/di/auth_providers.dart';
import 'package:zan/presentation/providers/sign_in_provider.dart';

import '../helpers/test_helpers.dart';

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
    group('Google SignIn 플로우', () {
      test('성공: DataSource → Repository → UseCase → Notifier 전체 체인 검증',
          () async {
        // arrange
        when(() => mockAuthDS.signInWithGoogle())
            .thenAnswer((_) async => FakeAuthResponse());

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier =
            container.read(socialSignInNotifierProvider.notifier);

        // act
        await notifier.signInWithGoogle();

        // assert
        final state = container.read(socialSignInNotifierProvider);
        expect(state, isA<AsyncData<void>>());
        verify(() => mockAuthDS.signInWithGoogle()).called(1);
      });

      test('실패: DataSource 예외 → AuthFailure → AsyncError 전파 검증', () async {
        // arrange
        when(() => mockAuthDS.signInWithGoogle())
            .thenThrow(Exception('Google sign-in was cancelled'));

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier =
            container.read(socialSignInNotifierProvider.notifier);

        // act
        await notifier.signInWithGoogle();

        // assert
        final state = container.read(socialSignInNotifierProvider);
        expect(state, isA<AsyncError<void>>());
      });
    });

    group('Apple SignIn 플로우', () {
      test('성공: DataSource → Repository → UseCase → Notifier 전체 체인 검증',
          () async {
        // arrange
        when(() => mockAuthDS.signInWithApple())
            .thenAnswer((_) async => FakeAuthResponse());

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier =
            container.read(socialSignInNotifierProvider.notifier);

        // act
        await notifier.signInWithApple();

        // assert
        final state = container.read(socialSignInNotifierProvider);
        expect(state, isA<AsyncData<void>>());
        verify(() => mockAuthDS.signInWithApple()).called(1);
      });

      test('실패: DataSource 예외 → AuthFailure → AsyncError 전파 검증', () async {
        // arrange
        when(() => mockAuthDS.signInWithApple())
            .thenThrow(Exception('Apple sign-in failed'));

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier =
            container.read(socialSignInNotifierProvider.notifier);

        // act
        await notifier.signInWithApple();

        // assert
        final state = container.read(socialSignInNotifierProvider);
        expect(state, isA<AsyncError<void>>());
      });
    });
  });
}
