import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/repositories/profile_repository_impl.dart';
import 'package:zan/domain/entities/profile.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(mockRemoteDataSource);
  });

  group('ProfileRepositoryImpl', () {
    group('getProfile', () {
      test('성공 시 Success<Profile>을 반환해야 한다', () async {
        // Arrange
        final testProfile = createTestProfile();
        when(() => mockRemoteDataSource.getProfile(testUserId))
            .thenAnswer((_) async => testProfile);

        // Act
        final result = await repository.getProfile(testUserId);

        // Assert
        expect(result, isA<Success<Profile>>());
        expect((result as Success<Profile>).data, equals(testProfile));
        verify(() => mockRemoteDataSource.getProfile(testUserId)).called(1);
      });

      test('실패 시 Fail(ServerFailure)을 반환해야 한다', () async {
        // Arrange
        const errorMessage = 'Profile not found';
        when(() => mockRemoteDataSource.getProfile(testUserId))
            .thenThrow(Exception(errorMessage));

        // Act
        final result = await repository.getProfile(testUserId);

        // Assert
        expect(result, isA<Fail<Profile>>());
        expect((result as Fail<Profile>).failure, isA<ServerFailure>());
        verify(() => mockRemoteDataSource.getProfile(testUserId)).called(1);
      });
    });

    group('updateProfile', () {
      test('성공 시 Success(null)을 반환해야 한다', () async {
        // Arrange
        final testProfile = createTestProfile();
        when(() => mockRemoteDataSource.updateProfile(testProfile))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.updateProfile(testProfile);

        // Assert
        expect(result, isA<Success<void>>());
        verify(() => mockRemoteDataSource.updateProfile(testProfile)).called(1);
      });

      test('실패 시 Fail(ServerFailure)을 반환해야 한다', () async {
        // Arrange
        final testProfile = createTestProfile();
        const errorMessage = 'Update failed';
        when(() => mockRemoteDataSource.updateProfile(testProfile))
            .thenThrow(Exception(errorMessage));

        // Act
        final result = await repository.updateProfile(testProfile);

        // Assert
        expect(result, isA<Fail<void>>());
        expect((result as Fail<void>).failure, isA<ServerFailure>());
        verify(() => mockRemoteDataSource.updateProfile(testProfile)).called(1);
      });
    });

    group('completeOnboarding', () {
      const country = 'KR';
      const currency = 'KRW';

      test('성공 시 Success(null)을 반환해야 한다', () async {
        // Arrange
        when(() => mockRemoteDataSource.completeOnboarding(
              userId: testUserId,
              country: country,
              currency: currency,
            )).thenAnswer((_) async => {});

        // Act
        final result = await repository.completeOnboarding(
          userId: testUserId,
          country: country,
          currency: currency,
        );

        // Assert
        expect(result, isA<Success<void>>());
        verify(() => mockRemoteDataSource.completeOnboarding(
              userId: testUserId,
              country: country,
              currency: currency,
            )).called(1);
      });

      test('파라미터(country, currency)가 정확히 전달되어야 한다', () async {
        // Arrange
        when(() => mockRemoteDataSource.completeOnboarding(
              userId: testUserId,
              country: country,
              currency: currency,
            )).thenAnswer((_) async => {});

        // Act
        await repository.completeOnboarding(
          userId: testUserId,
          country: country,
          currency: currency,
        );

        // Assert
        verify(() => mockRemoteDataSource.completeOnboarding(
              userId: testUserId,
              country: country,
              currency: currency,
            )).called(1);
      });

      test('실패 시 Fail(ServerFailure)을 반환해야 한다', () async {
        // Arrange
        const errorMessage = 'Onboarding completion failed';
        when(() => mockRemoteDataSource.completeOnboarding(
              userId: testUserId,
              country: country,
              currency: currency,
            )).thenThrow(Exception(errorMessage));

        // Act
        final result = await repository.completeOnboarding(
          userId: testUserId,
          country: country,
          currency: currency,
        );

        // Assert
        expect(result, isA<Fail<void>>());
        expect((result as Fail<void>).failure, isA<ServerFailure>());
        verify(() => mockRemoteDataSource.completeOnboarding(
              userId: testUserId,
              country: country,
              currency: currency,
            )).called(1);
      });
    });
  });
}
