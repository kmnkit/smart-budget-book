import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/data/datasources/remote/balance_remote_datasource.dart';

import '../../../helpers/test_helpers.dart';

// Fake PostgrestFilterBuilder that resolves to a fixed value when awaited.
// PostgrestBuilder<T, S, R> implements Future<T>, so we need our fake
// to behave as a Future<List<dynamic>> when awaited.
class _FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<List<dynamic>> {
  _FakePostgrestFilterBuilder(this._data);
  final List<dynamic> _data;

  @override
  Future<S> then<S>(FutureOr<S> Function(List<dynamic>) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue, onError: onError);
  }

  @override
  Future<List<dynamic>> catchError(Function onError,
      {bool Function(Object error)? test}) {
    return Future.value(_data).catchError(onError, test: test);
  }

  @override
  Future<List<dynamic>> whenComplete(FutureOr<void> Function() action) {
    return Future.value(_data).whenComplete(action);
  }

  @override
  Stream<List<dynamic>> asStream() {
    return Future.value(_data).asStream();
  }

  @override
  Future<List<dynamic>> timeout(Duration timeLimit,
      {FutureOr<List<dynamic>> Function()? onTimeout}) {
    return Future.value(_data).timeout(timeLimit, onTimeout: onTimeout);
  }
}

class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late _MockSupabaseClient mockClient;
  late BalanceRemoteDataSource dataSource;

  setUp(() {
    mockClient = _MockSupabaseClient();
    dataSource = BalanceRemoteDataSource(mockClient);
  });

  group('BalanceRemoteDataSource', () {
    group('getUserBalances', () {
      test('정상 응답 파싱 검증 - 잔액 목록을 올바르게 파싱한다', () async {
        // arrange
        final responseData = <dynamic>[
          balanceJsonFixture(
            id: 'acc-1',
            name: 'Cash Wallet',
            type: 'asset',
            category: 'cash',
            icon: 'wallet',
            color: '#6366F1',
            currency: 'JPY',
            balance: 50000,
            displayOrder: 0,
          ),
          balanceJsonFixture(
            id: 'acc-2',
            name: 'Credit Card',
            type: 'liability',
            category: 'credit_card',
            icon: 'credit_card',
            color: '#EF4444',
            currency: 'JPY',
            balance: -30000,
            displayOrder: 1,
          ),
        ];

        when(() => mockClient.rpc<List<dynamic>>(
              'get_user_balances',
              params: {'p_user_id': testUserId},
            )).thenAnswer((_) => _FakePostgrestFilterBuilder(responseData));

        // act
        final result = await dataSource.getUserBalances(testUserId);

        // assert
        expect(result, hasLength(2));
        expect(result[0].id, 'acc-1');
        expect(result[0].name, 'Cash Wallet');
        expect(result[0].type, AccountType.asset);
        expect(result[0].category, AccountCategory.cash);
        expect(result[0].balance, 50000);
        expect(result[1].id, 'acc-2');
        expect(result[1].type, AccountType.liability);
        expect(result[1].category, AccountCategory.creditCard);
        expect(result[1].balance, -30000);
        verify(() => mockClient.rpc<List<dynamic>>(
              'get_user_balances',
              params: {'p_user_id': testUserId},
            )).called(1);
      });

      test('빈 응답 처리 - 빈 리스트를 반환한다', () async {
        // arrange
        when(() => mockClient.rpc<List<dynamic>>(
              'get_user_balances',
              params: {'p_user_id': testUserId},
            )).thenAnswer((_) => _FakePostgrestFilterBuilder(<dynamic>[]));

        // act
        final result = await dataSource.getUserBalances(testUserId);

        // assert
        expect(result, isEmpty);
      });

      test('nullable 필드 기본값 검증 - icon, color, currency, displayOrder',
          () async {
        // arrange
        final responseData = <dynamic>[
          {
            'id': 'acc-1',
            'name': 'Minimal Account',
            'type': 'asset',
            'category': 'cash',
            'icon': null,
            'color': null,
            'currency': null,
            'balance': 1000,
            'display_order': null,
          },
        ];

        when(() => mockClient.rpc<List<dynamic>>(
              'get_user_balances',
              params: {'p_user_id': testUserId},
            )).thenAnswer((_) => _FakePostgrestFilterBuilder(responseData));

        // act
        final result = await dataSource.getUserBalances(testUserId);

        // assert
        expect(result, hasLength(1));
        expect(result[0].icon, 'wallet');
        expect(result[0].color, '#6366F1');
        expect(result[0].currency, 'JPY');
        expect(result[0].displayOrder, 0);
      });

      test('예외 발생 시 에러 전파', () async {
        // arrange
        when(() => mockClient.rpc<List<dynamic>>(
              'get_user_balances',
              params: {'p_user_id': testUserId},
            )).thenThrow(Exception('Network error'));

        // act & assert
        expect(
          () => dataSource.getUserBalances(testUserId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getMonthlySummary', () {
      test('정상 응답 파싱 검증', () async {
        // arrange
        final responseData = <dynamic>[
          monthlySummaryJsonFixture(
            totalIncome: 300000,
            totalExpense: 150000,
            netIncome: 150000,
            transactionCount: 25,
          ),
        ];

        when(() => mockClient.rpc<List<dynamic>>(
              'get_monthly_summary',
              params: {
                'p_user_id': testUserId,
                'p_year': 2026,
                'p_month': 1,
              },
            )).thenAnswer((_) => _FakePostgrestFilterBuilder(responseData));

        // act
        final result = await dataSource.getMonthlySummary(
          userId: testUserId,
          year: 2026,
          month: 1,
        );

        // assert
        expect(result.totalIncome, 300000);
        expect(result.totalExpense, 150000);
        expect(result.netIncome, 150000);
        expect(result.transactionCount, 25);
      });

      test('빈 응답 시 기본값 반환 (all zeros)', () async {
        // arrange
        when(() => mockClient.rpc<List<dynamic>>(
              'get_monthly_summary',
              params: {
                'p_user_id': testUserId,
                'p_year': 2026,
                'p_month': 1,
              },
            )).thenAnswer((_) => _FakePostgrestFilterBuilder(<dynamic>[]));

        // act
        final result = await dataSource.getMonthlySummary(
          userId: testUserId,
          year: 2026,
          month: 1,
        );

        // assert
        expect(result.totalIncome, 0);
        expect(result.totalExpense, 0);
        expect(result.netIncome, 0);
        expect(result.transactionCount, 0);
      });

      test('파라미터 전달 검증 (year, month)', () async {
        // arrange
        when(() => mockClient.rpc<List<dynamic>>(
              'get_monthly_summary',
              params: {
                'p_user_id': testUserId,
                'p_year': 2025,
                'p_month': 12,
              },
            )).thenAnswer(
            (_) => _FakePostgrestFilterBuilder(<dynamic>[monthlySummaryJsonFixture()]));

        // act
        await dataSource.getMonthlySummary(
          userId: testUserId,
          year: 2025,
          month: 12,
        );

        // assert
        verify(() => mockClient.rpc<List<dynamic>>(
              'get_monthly_summary',
              params: {
                'p_user_id': testUserId,
                'p_year': 2025,
                'p_month': 12,
              },
            )).called(1);
      });
    });
  });
}
