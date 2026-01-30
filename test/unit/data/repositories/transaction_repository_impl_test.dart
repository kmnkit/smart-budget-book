import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/repositories/transaction_repository_impl.dart';
import 'package:zan/domain/entities/transaction.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockTransactionRemoteDataSource mockDataSource;
  late TransactionRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockTransactionRemoteDataSource();
    repository = TransactionRepositoryImpl(mockDataSource);
  });

  group('TransactionRepositoryImpl', () {
    group('getTransactions', () {
      test('성공 시 Success<List<Transaction>> 반환', () async {
        // arrange
        final transactions = [
          createTestTransaction(id: 'tx-1', description: 'Lunch'),
          createTestTransaction(id: 'tx-2', description: 'Coffee'),
        ];
        when(() => mockDataSource.getTransactions(
              userId: testUserId,
              startDate: null,
              endDate: null,
              accountId: null,
              searchQuery: null,
              limit: 50,
              offset: 0,
            )).thenAnswer((_) async => transactions);

        // act
        final result = await repository.getTransactions(userId: testUserId);

        // assert
        expect(result, isA<Success<List<Transaction>>>());
        final data = (result as Success<List<Transaction>>).data;
        expect(data, hasLength(2));
        expect(data[0].description, 'Lunch');
        expect(data[1].description, 'Coffee');
      });

      test('에러 시 Fail(ServerFailure) 반환', () async {
        // arrange
        when(() => mockDataSource.getTransactions(
              userId: testUserId,
              startDate: null,
              endDate: null,
              accountId: null,
              searchQuery: null,
              limit: 50,
              offset: 0,
            )).thenThrow(Exception('Query failed'));

        // act
        final result = await repository.getTransactions(userId: testUserId);

        // assert
        expect(result, isA<Fail<List<Transaction>>>());
        final failure = (result as Fail<List<Transaction>>).failure;
        expect(failure, isA<ServerFailure>());
      });
    });

    group('createTransaction', () {
      test('성공 시 Success<Transaction> 반환', () async {
        // arrange
        final transaction = createTestTransaction();
        when(() => mockDataSource.createTransaction(transaction))
            .thenAnswer((_) async => transaction);

        // act
        final result = await repository.createTransaction(transaction);

        // assert
        expect(result, isA<Success<Transaction>>());
        expect((result as Success<Transaction>).data.id, transaction.id);
      });

      test('에러 시 Fail(ServerFailure) 반환', () async {
        // arrange
        final transaction = createTestTransaction();
        when(() => mockDataSource.createTransaction(transaction))
            .thenThrow(Exception('Insert error'));

        // act
        final result = await repository.createTransaction(transaction);

        // assert
        expect(result, isA<Fail<Transaction>>());
      });
    });

    group('updateTransaction', () {
      test('성공 시 Success<Transaction> 반환', () async {
        // arrange
        final transaction = createTestTransaction(description: 'Updated');
        when(() => mockDataSource.updateTransaction(transaction))
            .thenAnswer((_) async => transaction);

        // act
        final result = await repository.updateTransaction(transaction);

        // assert
        expect(result, isA<Success<Transaction>>());
        expect((result as Success<Transaction>).data.description, 'Updated');
      });

      test('에러 시 Fail(ServerFailure) 반환', () async {
        // arrange
        final transaction = createTestTransaction();
        when(() => mockDataSource.updateTransaction(transaction))
            .thenThrow(Exception('Update error'));

        // act
        final result = await repository.updateTransaction(transaction);

        // assert
        expect(result, isA<Fail<Transaction>>());
      });
    });

    group('deleteTransaction', () {
      test('성공 시 Success(null) 반환 — 소프트 삭제', () async {
        // arrange
        when(() => mockDataSource.deleteTransaction(testTransactionId))
            .thenAnswer((_) async {});

        // act
        final result = await repository.deleteTransaction(testTransactionId);

        // assert
        expect(result, isA<Success<void>>());
        verify(() => mockDataSource.deleteTransaction(testTransactionId)).called(1);
      });

      test('에러 시 Fail(ServerFailure) 반환', () async {
        // arrange
        when(() => mockDataSource.deleteTransaction(testTransactionId))
            .thenThrow(Exception('Delete error'));

        // act
        final result = await repository.deleteTransaction(testTransactionId);

        // assert
        expect(result, isA<Fail<void>>());
      });
    });

    group('getRecentTransactions', () {
      test('성공 시 Success<List<Transaction>> 반환', () async {
        // arrange
        final transactions = [
          createTestTransaction(id: 'tx-1'),
          createTestTransaction(id: 'tx-2'),
          createTestTransaction(id: 'tx-3'),
        ];
        when(() => mockDataSource.getRecentTransactions(testUserId, limit: 3))
            .thenAnswer((_) async => transactions);

        // act
        final result = await repository.getRecentTransactions(testUserId);

        // assert
        expect(result, isA<Success<List<Transaction>>>());
        final data = (result as Success<List<Transaction>>).data;
        expect(data, hasLength(3));
      });

      test('에러 시 Fail(ServerFailure) 반환', () async {
        // arrange
        when(() => mockDataSource.getRecentTransactions(testUserId, limit: 3))
            .thenThrow(Exception('Recent error'));

        // act
        final result = await repository.getRecentTransactions(testUserId);

        // assert
        expect(result, isA<Fail<List<Transaction>>>());
      });
    });

    group('getTransaction', () {
      test('성공 시 Success<Transaction> 반환', () async {
        // arrange
        final transaction = createTestTransaction();
        when(() => mockDataSource.getTransaction(testTransactionId))
            .thenAnswer((_) async => transaction);

        // act
        final result = await repository.getTransaction(testTransactionId);

        // assert
        expect(result, isA<Success<Transaction>>());
        expect((result as Success<Transaction>).data.id, testTransactionId);
      });

      test('에러 시 Fail(ServerFailure) 반환', () async {
        // arrange
        when(() => mockDataSource.getTransaction(testTransactionId))
            .thenThrow(Exception('Not found'));

        // act
        final result = await repository.getTransaction(testTransactionId);

        // assert
        expect(result, isA<Fail<Transaction>>());
      });
    });
  });
}
