import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/datasources/remote/subscription_remote_datasource.dart';
import 'package:zan/data/repositories/subscription_repository_impl.dart';
import 'package:zan/domain/entities/subscription.dart';
import 'package:zan/domain/entities/usage_quota.dart';

class MockSubscriptionRemoteDataSource extends Mock
    implements SubscriptionRemoteDataSource {}

void main() {
  late SubscriptionRepositoryImpl repository;
  late MockSubscriptionRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockSubscriptionRemoteDataSource();
    repository = SubscriptionRepositoryImpl(mockDataSource);
  });

  final testSubscription = Subscription(
    id: 'sub-1',
    userId: 'user-1',
    tier: SubscriptionTier.premium,
    status: SubscriptionStatus.active,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final testQuota = UsageQuota(
    userId: 'user-1',
    transactionsThisMonth: 10,
    transactionsLimit: 50,
    aiInputsThisMonth: 2,
    aiInputsLimit: 5,
    ocrScansThisMonth: 1,
    ocrScansLimit: 3,
    accountCount: 3,
    accountsLimit: 5,
    periodStart: DateTime(2026, 1),
    periodEnd: DateTime(2026, 2),
  );

  group('getSubscription', () {
    test('should return subscription on success', () async {
      when(() => mockDataSource.getSubscription('user-1'))
          .thenAnswer((_) async => testSubscription);

      final result = await repository.getSubscription('user-1');

      expect(result, isA<Success<Subscription>>());
      expect((result as Success<Subscription>).data.tier, SubscriptionTier.premium);
      verify(() => mockDataSource.getSubscription('user-1')).called(1);
    });

    test('should return SubscriptionFailure on error', () async {
      when(() => mockDataSource.getSubscription('user-1'))
          .thenThrow(Exception('Network error'));

      final result = await repository.getSubscription('user-1');

      expect(result, isA<Fail<Subscription>>());
      expect((result as Fail<Subscription>).failure, isA<SubscriptionFailure>());
    });
  });

  group('getUsageQuota', () {
    test('should return quota on success', () async {
      when(() => mockDataSource.getUsageQuota('user-1'))
          .thenAnswer((_) async => testQuota);

      final result = await repository.getUsageQuota('user-1');

      expect(result, isA<Success<UsageQuota>>());
      final data = (result as Success<UsageQuota>).data;
      expect(data.transactionsThisMonth, 10);
      expect(data.transactionsLimit, 50);
    });

    test('should return ServerFailure on error', () async {
      when(() => mockDataSource.getUsageQuota('user-1'))
          .thenThrow(Exception('DB error'));

      final result = await repository.getUsageQuota('user-1');

      expect(result, isA<Fail<UsageQuota>>());
      expect((result as Fail<UsageQuota>).failure, isA<ServerFailure>());
    });
  });

  group('recordUsageEvent', () {
    test('should return Success on success', () async {
      when(() => mockDataSource.recordUsageEvent('user-1', 'ai_input'))
          .thenAnswer((_) async {});

      final result = await repository.recordUsageEvent('user-1', 'ai_input');

      expect(result, isA<Success<void>>());
      verify(() => mockDataSource.recordUsageEvent('user-1', 'ai_input')).called(1);
    });

    test('should return ServerFailure on error', () async {
      when(() => mockDataSource.recordUsageEvent('user-1', 'ai_input'))
          .thenThrow(Exception('Insert failed'));

      final result = await repository.recordUsageEvent('user-1', 'ai_input');

      expect(result, isA<Fail<void>>());
    });
  });
}
