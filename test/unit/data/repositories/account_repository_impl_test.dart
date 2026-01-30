import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/repositories/account_repository_impl.dart';
import 'package:zan/domain/entities/account.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockAccountRemoteDataSource mockDataSource;
  late AccountRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAccountRemoteDataSource();
    repository = AccountRepositoryImpl(mockDataSource);
  });

  group('AccountRepositoryImpl', () {
    group('getAccounts', () {
      test('성공 시 Success<List<Account>> 반환', () async {
        // arrange
        final accounts = [
          createTestAccount(id: 'acc-1', name: 'Wallet'),
          createTestAccount(id: 'acc-2', name: 'Bank'),
        ];
        when(() => mockDataSource.getAccounts(testUserId))
            .thenAnswer((_) async => accounts);

        // act
        final result = await repository.getAccounts(testUserId);

        // assert
        expect(result, isA<Success<List<Account>>>());
        final data = (result as Success<List<Account>>).data;
        expect(data, hasLength(2));
        expect(data[0].name, 'Wallet');
        expect(data[1].name, 'Bank');
        verify(() => mockDataSource.getAccounts(testUserId)).called(1);
      });

      test('에러 시 Fail(ServerFailure) 반환', () async {
        // arrange
        when(() => mockDataSource.getAccounts(testUserId))
            .thenThrow(Exception('DB error'));

        // act
        final result = await repository.getAccounts(testUserId);

        // assert
        expect(result, isA<Fail<List<Account>>>());
        final failure = (result as Fail<List<Account>>).failure;
        expect(failure, isA<ServerFailure>());
      });
    });

    group('createAccount', () {
      test('성공 시 Success<Account> 반환', () async {
        // arrange
        final account = createTestAccount();
        when(() => mockDataSource.createAccount(account))
            .thenAnswer((_) async => account);

        // act
        final result = await repository.createAccount(account);

        // assert
        expect(result, isA<Success<Account>>());
        expect((result as Success<Account>).data.id, account.id);
      });

      test('에러 시 Fail(ServerFailure) 반환', () async {
        // arrange
        final account = createTestAccount();
        when(() => mockDataSource.createAccount(account))
            .thenThrow(Exception('Insert error'));

        // act
        final result = await repository.createAccount(account);

        // assert
        expect(result, isA<Fail<Account>>());
      });
    });

    group('createAccounts', () {
      test('성공 시 Success(null) 반환', () async {
        // arrange
        final accounts = [createTestAccount()];
        when(() => mockDataSource.createAccounts(accounts))
            .thenAnswer((_) async {});

        // act
        final result = await repository.createAccounts(accounts);

        // assert
        expect(result, isA<Success<void>>());
      });
    });

    group('updateAccount', () {
      test('성공 시 Success<Account> 반환', () async {
        // arrange
        final account = createTestAccount(name: 'Updated');
        when(() => mockDataSource.updateAccount(account))
            .thenAnswer((_) async => account);

        // act
        final result = await repository.updateAccount(account);

        // assert
        expect(result, isA<Success<Account>>());
        expect((result as Success<Account>).data.name, 'Updated');
      });

      test('에러 시 Fail(ServerFailure) 반환', () async {
        // arrange
        final account = createTestAccount();
        when(() => mockDataSource.updateAccount(account))
            .thenThrow(Exception('Update error'));

        // act
        final result = await repository.updateAccount(account);

        // assert
        expect(result, isA<Fail<Account>>());
      });
    });

    group('archiveAccount', () {
      test('성공 시 Success(null) 반환', () async {
        // arrange
        when(() => mockDataSource.archiveAccount(testAccountId))
            .thenAnswer((_) async {});

        // act
        final result = await repository.archiveAccount(testAccountId);

        // assert
        expect(result, isA<Success<void>>());
      });

      test('에러 시 Fail(ServerFailure) 반환', () async {
        // arrange
        when(() => mockDataSource.archiveAccount(testAccountId))
            .thenThrow(Exception('Archive error'));

        // act
        final result = await repository.archiveAccount(testAccountId);

        // assert
        expect(result, isA<Fail<void>>());
      });
    });

    group('unarchiveAccount', () {
      test('성공 시 Success(null) 반환', () async {
        // arrange
        when(() => mockDataSource.unarchiveAccount(testAccountId))
            .thenAnswer((_) async {});

        // act
        final result = await repository.unarchiveAccount(testAccountId);

        // assert
        expect(result, isA<Success<void>>());
      });

      test('에러 시 Fail(ServerFailure) 반환', () async {
        // arrange
        when(() => mockDataSource.unarchiveAccount(testAccountId))
            .thenThrow(Exception('Unarchive error'));

        // act
        final result = await repository.unarchiveAccount(testAccountId);

        // assert
        expect(result, isA<Fail<void>>());
      });
    });

    group('getAccount', () {
      test('성공 시 Success<Account> 반환', () async {
        // arrange
        final account = createTestAccount();
        when(() => mockDataSource.getAccount(testAccountId))
            .thenAnswer((_) async => account);

        // act
        final result = await repository.getAccount(testAccountId);

        // assert
        expect(result, isA<Success<Account>>());
        expect((result as Success<Account>).data.id, testAccountId);
      });

      test('에러 시 Fail(ServerFailure) 반환', () async {
        // arrange
        when(() => mockDataSource.getAccount(testAccountId))
            .thenThrow(Exception('Not found'));

        // act
        final result = await repository.getAccount(testAccountId);

        // assert
        expect(result, isA<Fail<Account>>());
      });
    });

    group('updateDisplayOrders', () {
      test('성공 시 Success(null) 반환', () async {
        // arrange
        final orders = {'acc-1': 0, 'acc-2': 1, 'acc-3': 2};
        when(() => mockDataSource.updateDisplayOrders(orders))
            .thenAnswer((_) async {});

        // act
        final result = await repository.updateDisplayOrders(orders);

        // assert
        expect(result, isA<Success<void>>());
        verify(() => mockDataSource.updateDisplayOrders(orders)).called(1);
      });

      test('에러 시 Fail(ServerFailure) 반환', () async {
        // arrange
        final orders = {'acc-1': 0};
        when(() => mockDataSource.updateDisplayOrders(orders))
            .thenThrow(Exception('Update order error'));

        // act
        final result = await repository.updateDisplayOrders(orders);

        // assert
        expect(result, isA<Fail<void>>());
      });
    });
  });
}
