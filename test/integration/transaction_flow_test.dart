import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zan/config/di/transaction_providers.dart';
import 'package:zan/presentation/providers/auth_provider.dart';
import 'package:zan/presentation/providers/transaction_list_provider.dart';

import '../../test/helpers/test_helpers.dart';

void main() {
  late MockTransactionRemoteDataSource mockTransactionDS;

  setUp(() {
    mockTransactionDS = MockTransactionRemoteDataSource();
  });

  ProviderContainer createContainer({String? userId = testUserId}) {
    return ProviderContainer(
      overrides: [
        transactionRemoteDataSourceProvider
            .overrideWith((ref) => mockTransactionDS),
        currentUserIdProvider.overrideWith((ref) => userId),
      ],
    );
  }

  group('Transaction Flow Integration', () {
    group('transactionList', () {
      test('DataSource → Repository → Provider 전체 체인 데이터 로드 검증', () async {
        // arrange
        final transactions = [
          createTestTransaction(id: 'txn-1', amount: 5000, description: '점심'),
          createTestTransaction(id: 'txn-2', amount: 3000, description: '커피'),
        ];
        when(() => mockTransactionDS.getTransactions(
              userId: testUserId,
              startDate: null,
              endDate: null,
              accountId: null,
              searchQuery: null,
              limit: 50,
              offset: 0,
            )).thenAnswer((_) async => transactions);

        final container = createContainer();
        addTearDown(container.dispose);

        // act
        final result = await container.read(transactionListProvider.future);

        // assert
        expect(result, hasLength(2));
        expect(result[0].description, '점심');
        expect(result[1].amount, 3000);
        verify(() => mockTransactionDS.getTransactions(
              userId: testUserId,
              startDate: null,
              endDate: null,
              accountId: null,
              searchQuery: null,
              limit: 50,
              offset: 0,
            )).called(1);
      });

      test('DataSource 에러 → Repository Fail → Provider 빈 리스트 반환 검증', () async {
        // arrange
        when(() => mockTransactionDS.getTransactions(
              userId: testUserId,
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              accountId: any(named: 'accountId'),
              searchQuery: any(named: 'searchQuery'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenThrow(Exception('Database error'));

        final container = createContainer();
        addTearDown(container.dispose);

        // act
        final result = await container.read(transactionListProvider.future);

        // assert
        expect(result, isEmpty);
      });

      test('userId가 null이면 DataSource 호출 없이 빈 리스트 반환', () async {
        // arrange
        final container = createContainer(userId: null);
        addTearDown(container.dispose);

        // act
        final result = await container.read(transactionListProvider.future);

        // assert
        expect(result, isEmpty);
        verifyNever(() => mockTransactionDS.getTransactions(
              userId: any(named: 'userId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              accountId: any(named: 'accountId'),
              searchQuery: any(named: 'searchQuery'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ));
      });
    });

    group('recentTransactions', () {
      test('DataSource → Repository → Provider 전체 체인 데이터 로드 검증', () async {
        // arrange
        final transactions = [
          createTestTransaction(id: 'recent-1', amount: 10000),
          createTestTransaction(id: 'recent-2', amount: 20000),
          createTestTransaction(id: 'recent-3', amount: 30000),
        ];
        when(() => mockTransactionDS.getRecentTransactions(testUserId,
            limit: 3)).thenAnswer((_) async => transactions);

        final container = createContainer();
        addTearDown(container.dispose);

        // act
        final result =
            await container.read(recentTransactionsProvider.future);

        // assert
        expect(result, hasLength(3));
        verify(() => mockTransactionDS.getRecentTransactions(testUserId,
            limit: 3)).called(1);
      });
    });
  });
}
