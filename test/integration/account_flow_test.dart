import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zan/config/di/account_providers.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/presentation/providers/account_provider.dart';
import 'package:zan/presentation/providers/auth_provider.dart';

import '../../test/helpers/test_helpers.dart';

void main() {
  late MockAccountRemoteDataSource mockAccountDS;

  setUp(() {
    mockAccountDS = MockAccountRemoteDataSource();
  });

  ProviderContainer createContainer({String? userId = testUserId}) {
    return ProviderContainer(
      overrides: [
        accountRemoteDataSourceProvider.overrideWith((ref) => mockAccountDS),
        currentUserIdProvider.overrideWith((ref) => userId),
      ],
    );
  }

  group('Account Flow Integration', () {
    group('accountList', () {
      test('DataSource → Repository → Provider 전체 체인 데이터 로드 검증', () async {
        // arrange
        final accounts = [
          createTestAccount(id: 'acc-1', name: '현금', type: AccountType.asset),
          createTestAccount(id: 'acc-2', name: '은행', type: AccountType.asset),
        ];
        when(() => mockAccountDS.getAccounts(testUserId))
            .thenAnswer((_) async => accounts);

        final container = createContainer();
        addTearDown(container.dispose);

        // act
        final result = await container.read(accountListProvider.future);

        // assert
        expect(result, hasLength(2));
        expect(result[0].name, '현금');
        expect(result[1].name, '은행');
        verify(() => mockAccountDS.getAccounts(testUserId)).called(1);
      });

      test('DataSource 에러 → Repository Fail → Provider 빈 리스트 반환 검증', () async {
        // arrange
        when(() => mockAccountDS.getAccounts(testUserId))
            .thenThrow(Exception('Server error'));

        final container = createContainer();
        addTearDown(container.dispose);

        // act
        final result = await container.read(accountListProvider.future);

        // assert - provider returns empty list on failure
        expect(result, isEmpty);
      });

      test('userId가 null이면 DataSource 호출 없이 빈 리스트 반환', () async {
        // arrange
        final container = createContainer(userId: null);
        addTearDown(container.dispose);

        // act
        final result = await container.read(accountListProvider.future);

        // assert
        expect(result, isEmpty);
        verifyNever(() => mockAccountDS.getAccounts(any()));
      });
    });

    group('allAccountList', () {
      test('DataSource → Repository → Provider 전체 체인 데이터 로드 검증', () async {
        // arrange
        final accounts = [
          createTestAccount(id: 'acc-1', name: '현금', isArchived: false),
          createTestAccount(id: 'acc-2', name: '옛날계좌', isArchived: true),
        ];
        when(() => mockAccountDS.getAllAccounts(testUserId))
            .thenAnswer((_) async => accounts);

        final container = createContainer();
        addTearDown(container.dispose);

        // act
        final result = await container.read(allAccountListProvider.future);

        // assert
        expect(result, hasLength(2));
        expect(result[1].isArchived, true);
        verify(() => mockAccountDS.getAllAccounts(testUserId)).called(1);
      });
    });
  });
}
