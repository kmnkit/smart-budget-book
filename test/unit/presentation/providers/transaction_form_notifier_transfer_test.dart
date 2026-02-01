import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zan/config/di/transaction_providers.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/core/utils/transaction_type_helper.dart';
import 'package:zan/domain/entities/account.dart';
import 'package:zan/domain/entities/transaction.dart' as domain;
import 'package:zan/domain/repositories/transaction_repository.dart';
import 'package:zan/presentation/providers/auth_provider.dart';
import 'package:zan/presentation/providers/transaction_form_provider.dart';
import '../../../helpers/test_helpers.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late Account assetAccount1;
  late Account assetAccount2;
  late Account liabilityAccount;
  late Account expenseAccount;
  late Account incomeAccount;

  setUpAll(() {
    registerFallbackValue(
      createTestTransaction(
        debitAccountId: testUserId,
        creditAccountId: testUserId,
      ),
    );
  });

  setUp(() {
    mockRepo = MockTransactionRepository();

    assetAccount1 = createTestAccount(
      id: 'asset1',
      name: '은행계좌',
      type: AccountType.asset,
      category: AccountCategory.bankAccount,
    );

    assetAccount2 = createTestAccount(
      id: 'asset2',
      name: '현금',
      type: AccountType.asset,
      category: AccountCategory.cash,
    );

    liabilityAccount = createTestAccount(
      id: 'liability1',
      name: '신용카드',
      type: AccountType.liability,
      category: AccountCategory.creditCard,
    );

    expenseAccount = createTestAccount(
      id: 'expense1',
      name: '식비',
      type: AccountType.expense,
      category: AccountCategory.food,
    );

    incomeAccount = createTestAccount(
      id: 'income1',
      name: '급여',
      type: AccountType.income,
      category: AccountCategory.salary,
    );
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWith((ref) => testUserId),
        transactionRepositoryProvider.overrideWith((ref) => mockRepo),
      ],
    );
  }

  group('TransactionFormState - 이체 탭 유효성 검증', () {
    test('양쪽 계좌가 설정되고 금액이 0보다 크고 계좌가 다를 때 isValid = true', () {
      final state = TransactionFormState(
        transactionType: TransactionType.transfer,
        debitAccountId: assetAccount2.id,
        creditAccountId: assetAccount1.id,
        amount: 10000,
        date: testDateTime,
        description: '이체',
      );

      expect(state.isValid, true);
    });

    test('debit == credit (같은 계좌 이체)일 때 isValid = false', () {
      final state = TransactionFormState(
        transactionType: TransactionType.transfer,
        debitAccountId: assetAccount1.id,
        creditAccountId: assetAccount1.id,
        amount: 10000,
        date: testDateTime,
        description: '이체',
      );

      expect(state.isValid, false);
    });

    test('amount = 0일 때 isValid = false', () {
      final state = TransactionFormState(
        transactionType: TransactionType.transfer,
        debitAccountId: assetAccount2.id,
        creditAccountId: assetAccount1.id,
        amount: 0,
        date: testDateTime,
        description: '이체',
      );

      expect(state.isValid, false);
    });

    test('debitAccountId가 null일 때 isValid = false', () {
      final state = TransactionFormState(
        transactionType: TransactionType.transfer,
        debitAccountId: null,
        creditAccountId: assetAccount1.id,
        amount: 10000,
        date: testDateTime,
        description: '이체',
      );

      expect(state.isValid, false);
    });

    test('creditAccountId가 null일 때 isValid = false', () {
      final state = TransactionFormState(
        transactionType: TransactionType.transfer,
        debitAccountId: assetAccount2.id,
        creditAccountId: null,
        amount: 10000,
        date: testDateTime,
        description: '이체',
      );

      expect(state.isValid, false);
    });

    test('clearAccounts()가 debit/credit을 초기화하고 다른 필드는 유지', () {
      final state = TransactionFormState(
        transactionType: TransactionType.transfer,
        debitAccountId: assetAccount2.id,
        creditAccountId: assetAccount1.id,
        amount: 10000,
        date: testDateTime,
        description: '이체 테스트',
      );

      final cleared = state.clearAccounts();

      expect(cleared.debitAccountId, null);
      expect(cleared.creditAccountId, null);
      expect(cleared.transactionType, TransactionType.transfer);
      expect(cleared.amount, 10000);
      expect(cleared.date, testDateTime);
      expect(cleared.description, '이체 테스트');
    });
  });

  group('TransactionFormNotifier - 이체 탭 전환', () {
    test('setTransactionType(transfer)가 계좌를 초기화하고 타입을 변경', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormNotifierProvider.notifier);

      // 초기 상태에서 지출 설정
      notifier.setTransactionType(TransactionType.expense);
      notifier.setDebitAccount(expenseAccount.id);
      notifier.setCreditAccount(assetAccount1.id);

      // 이체로 전환
      notifier.setTransactionType(TransactionType.transfer);

      final state = container.read(transactionFormNotifierProvider);
      expect(state.transactionType, TransactionType.transfer);
      expect(state.debitAccountId, null);
      expect(state.creditAccountId, null);
    });

    test('이미 transfer일 때 setTransactionType(transfer) 호출 시 no-op', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormNotifierProvider.notifier);

      notifier.setTransactionType(TransactionType.transfer);
      notifier.setDebitAccount(assetAccount2.id);
      notifier.setCreditAccount(assetAccount1.id);

      final stateBefore = container.read(transactionFormNotifierProvider);

      // 다시 transfer 설정
      notifier.setTransactionType(TransactionType.transfer);

      final stateAfter = container.read(transactionFormNotifierProvider);

      expect(stateAfter, stateBefore);
      expect(stateAfter.debitAccountId, assetAccount2.id);
      expect(stateAfter.creditAccountId, assetAccount1.id);
    });

    test('이체에서 debit/credit 계좌 설정 후 상태 검증', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormNotifierProvider.notifier);

      notifier.setTransactionType(TransactionType.transfer);
      notifier.setDebitAccount(assetAccount2.id);
      notifier.setCreditAccount(assetAccount1.id);

      final state = container.read(transactionFormNotifierProvider);

      expect(state.transactionType, TransactionType.transfer);
      expect(state.debitAccountId, assetAccount2.id);
      expect(state.creditAccountId, assetAccount1.id);
    });

    test('완전한 이체 플로우: 타입 설정 → 계좌 설정 → 금액 설정 → isValid', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormNotifierProvider.notifier);

      // Arrange
      notifier.setTransactionType(TransactionType.transfer);

      // Act
      notifier.setDebitAccount(assetAccount2.id);
      notifier.setCreditAccount(assetAccount1.id);
      notifier.setAmount(50000);
      notifier.setDescription('급여 이체');

      // Assert
      final state = container.read(transactionFormNotifierProvider);
      expect(state.transactionType, TransactionType.transfer);
      expect(state.debitAccountId, assetAccount2.id);
      expect(state.creditAccountId, assetAccount1.id);
      expect(state.amount, 50000);
      expect(state.description, '급여 이체');
      expect(state.isValid, true);
    });
  });

  group('TransactionFormNotifier - loadFromTransaction 이체 케이스', () {
    test('기존 이체 거래를 로드하면 TransactionType.transfer로 추론', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final existingTransfer = createTestTransaction(
        id: 'transfer1',
        debitAccountId: assetAccount2.id,
        creditAccountId: assetAccount1.id,
        amount: 30000,
        description: '계좌 이체',
      );

      final notifier = container.read(transactionFormNotifierProvider.notifier);

      notifier.loadFromTransaction(existingTransfer, [
        assetAccount1,
        assetAccount2,
      ]);

      final state = container.read(transactionFormNotifierProvider);

      expect(state.transactionType, TransactionType.transfer);
      expect(state.debitAccountId, assetAccount2.id);
      expect(state.creditAccountId, assetAccount1.id);
      expect(state.amount, 30000);
      expect(state.description, '계좌 이체');
    });

    test('inferTransactionType이 asset → asset를 transfer로 추론', () {
      final type = inferTransactionType(
        debitType: assetAccount2.type,
        creditType: assetAccount1.type,
      );

      expect(type, TransactionType.transfer);
    });
  });

  group('TransactionTypeConfig - 이체 설정', () {
    test('transfer accountFieldConfig의 field1AllowedTypes = {asset, liability}', () {
      final config = TransactionType.transfer.accountFieldConfig;

      expect(
        config.field1AllowedTypes,
        containsAll([AccountType.asset, AccountType.liability]),
      );
      expect(config.field1AllowedTypes.length, 2);
    });

    test('transfer accountFieldConfig의 field2AllowedTypes = {asset, liability}', () {
      final config = TransactionType.transfer.accountFieldConfig;

      expect(
        config.field2AllowedTypes,
        containsAll([AccountType.asset, AccountType.liability]),
      );
      expect(config.field2AllowedTypes.length, 2);
    });

    test('transfer accountFieldConfig의 field1IsDebit = false', () {
      final config = TransactionType.transfer.accountFieldConfig;

      expect(config.field1IsDebit, false);
    });
  });

  group('inferTransactionType - 이체 추론 로직', () {
    test('debit=asset, credit=asset → transfer', () {
      final type = inferTransactionType(
        debitType: assetAccount1.type,
        creditType: assetAccount2.type,
      );

      expect(type, TransactionType.transfer);
    });

    test('debit=asset, credit=liability → transfer', () {
      final type = inferTransactionType(
        debitType: assetAccount1.type,
        creditType: liabilityAccount.type,
      );

      expect(type, TransactionType.transfer);
    });

    test('debit=liability, credit=asset → transfer', () {
      final type = inferTransactionType(
        debitType: liabilityAccount.type,
        creditType: assetAccount1.type,
      );

      expect(type, TransactionType.transfer);
    });

    test('debit=liability, credit=liability → transfer', () {
      final type = inferTransactionType(
        debitType: liabilityAccount.type,
        creditType: liabilityAccount.type,
      );

      expect(type, TransactionType.transfer);
    });

    test('debit=expense, credit=asset → expense (NOT transfer)', () {
      final type = inferTransactionType(
        debitType: expenseAccount.type,
        creditType: assetAccount1.type,
      );

      expect(type, TransactionType.expense);
    });

    test('debit=asset, credit=income → income (NOT transfer)', () {
      final type = inferTransactionType(
        debitType: assetAccount1.type,
        creditType: incomeAccount.type,
      );

      expect(type, TransactionType.income);
    });
  });
}
