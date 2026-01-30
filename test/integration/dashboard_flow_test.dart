import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zan/config/di/balance_providers.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/presentation/providers/auth_provider.dart';
import 'package:zan/presentation/providers/dashboard_provider.dart';

import '../../test/helpers/test_helpers.dart';

void main() {
  late MockBalanceRemoteDataSource mockBalanceDS;

  setUp(() {
    mockBalanceDS = MockBalanceRemoteDataSource();
  });

  ProviderContainer createContainer({String? userId = testUserId}) {
    return ProviderContainer(
      overrides: [
        balanceRemoteDataSourceProvider.overrideWith((ref) => mockBalanceDS),
        currentUserIdProvider.overrideWith((ref) => userId),
      ],
    );
  }

  group('Dashboard Flow Integration', () {
    group('accountBalances', () {
      test('BalanceDataSource → Provider 전체 체인 데이터 로드 검증', () async {
        // arrange
        final balances = [
          createTestAccountBalance(
            id: 'acc-1',
            name: '현금',
            type: AccountType.asset,
            balance: 100000,
          ),
          createTestAccountBalance(
            id: 'acc-2',
            name: '신용카드',
            type: AccountType.liability,
            balance: 30000,
          ),
        ];
        when(() => mockBalanceDS.getUserBalances(testUserId))
            .thenAnswer((_) async => balances);

        final container = createContainer();
        addTearDown(container.dispose);

        // act
        final result = await container.read(accountBalancesProvider.future);

        // assert
        expect(result, hasLength(2));
        expect(result[0].name, '현금');
        expect(result[0].balance, 100000);
        expect(result[1].name, '신용카드');
        verify(() => mockBalanceDS.getUserBalances(testUserId)).called(1);
      });

      test('userId가 null이면 빈 리스트 반환', () async {
        // arrange
        final container = createContainer(userId: null);
        addTearDown(container.dispose);

        // act
        final result = await container.read(accountBalancesProvider.future);

        // assert
        expect(result, isEmpty);
        verifyNever(() => mockBalanceDS.getUserBalances(any()));
      });

      test('DataSource 에러 시 error 상태 전파', () async {
        // arrange
        when(() => mockBalanceDS.getUserBalances(testUserId))
            .thenThrow(Exception('Network error'));

        final container = createContainer();
        addTearDown(container.dispose);

        // act & assert
        expect(
          () => container.read(accountBalancesProvider.future),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('currentMonthSummary', () {
      test('BalanceDataSource → Provider 전체 체인 데이터 로드 검증', () async {
        // arrange
        final summary = createTestMonthlySummary(
          totalIncome: 500000,
          totalExpense: 200000,
          netIncome: 300000,
          transactionCount: 15,
        );
        when(() => mockBalanceDS.getMonthlySummary(
              userId: testUserId,
              year: any(named: 'year'),
              month: any(named: 'month'),
            )).thenAnswer((_) async => summary);

        final container = createContainer();
        addTearDown(container.dispose);

        // act
        final result = await container.read(currentMonthSummaryProvider.future);

        // assert
        expect(result.totalIncome, 500000);
        expect(result.totalExpense, 200000);
        expect(result.netIncome, 300000);
        expect(result.transactionCount, 15);
      });

      test('userId가 null이면 기본값(all zeros) 반환', () async {
        // arrange
        final container = createContainer(userId: null);
        addTearDown(container.dispose);

        // act
        final result = await container.read(currentMonthSummaryProvider.future);

        // assert
        expect(result.totalIncome, 0);
        expect(result.totalExpense, 0);
        expect(result.netIncome, 0);
        expect(result.transactionCount, 0);
      });
    });

    group('netWorth', () {
      test('자산 - 부채 = 순자산 계산 검증', () async {
        // arrange
        final balances = [
          createTestAccountBalance(
            id: 'asset-1',
            name: '은행계좌',
            type: AccountType.asset,
            balance: 1000000,
          ),
          createTestAccountBalance(
            id: 'asset-2',
            name: '현금',
            type: AccountType.asset,
            balance: 200000,
          ),
          createTestAccountBalance(
            id: 'liability-1',
            name: '카드빚',
            type: AccountType.liability,
            balance: 300000,
          ),
          createTestAccountBalance(
            id: 'income-1',
            name: '급여',
            type: AccountType.income,
            balance: 500000,
          ),
        ];
        when(() => mockBalanceDS.getUserBalances(testUserId))
            .thenAnswer((_) async => balances);

        final container = createContainer();
        addTearDown(container.dispose);

        // act - wait for balances to load first
        await container.read(accountBalancesProvider.future);
        final netWorthValue = container.read(netWorthProvider);

        // assert: (1000000 + 200000) - 300000 = 900000
        expect(netWorthValue, 900000);
      });
    });
  });
}
