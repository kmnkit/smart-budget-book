import 'package:zan/core/constants/enums.dart';
import 'package:zan/domain/entities/account.dart';
import 'package:zan/domain/entities/account_balance.dart';
import 'package:zan/domain/entities/monthly_summary.dart';
import 'package:zan/domain/entities/profile.dart';
import 'package:zan/domain/entities/transaction.dart' as domain;

// ---- Constants ----

const testUserId = 'test-user-id-123';
final testDateTime = DateTime(2026, 1, 15, 10, 30);
final testDate = DateTime(2026, 1, 15);

// ---- Profiles ----

Profile profileOnboardingIncomplete() => Profile(
      id: testUserId,
      displayName: 'Test User',
      defaultCurrency: 'JPY',
      country: 'JP',
      onboardingCompleted: false,
      settings: const {},
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

Profile profileJapanComplete() => Profile(
      id: testUserId,
      displayName: 'Test User',
      defaultCurrency: 'JPY',
      country: 'JP',
      onboardingCompleted: true,
      settings: const {},
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

Profile profileKoreaComplete() => Profile(
      id: testUserId,
      displayName: 'Test User',
      defaultCurrency: 'KRW',
      country: 'KR',
      onboardingCompleted: true,
      settings: const {},
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

// ---- Accounts ----

Account cashAccount() => Account(
      id: 'acct-cash',
      userId: testUserId,
      name: '現金',
      type: AccountType.asset,
      category: AccountCategory.cash,
      icon: 'cash',
      color: '#4CAF50',
      initialBalance: 10000,
      currency: 'JPY',
      displayOrder: 0,
      isArchived: false,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

Account bankAccount() => Account(
      id: 'acct-bank',
      userId: testUserId,
      name: '銀行口座',
      type: AccountType.asset,
      category: AccountCategory.bankAccount,
      icon: 'bank',
      color: '#2196F3',
      initialBalance: 500000,
      currency: 'JPY',
      displayOrder: 1,
      isArchived: false,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

Account creditCardAccount() => Account(
      id: 'acct-cc',
      userId: testUserId,
      name: 'クレジットカード',
      type: AccountType.liability,
      category: AccountCategory.creditCard,
      icon: 'credit_card',
      color: '#FF5722',
      initialBalance: 30000,
      currency: 'JPY',
      displayOrder: 2,
      isArchived: false,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

Account foodExpense() => Account(
      id: 'acct-food',
      userId: testUserId,
      name: '食費',
      type: AccountType.expense,
      category: AccountCategory.food,
      icon: 'restaurant',
      color: '#FF9800',
      initialBalance: 0,
      currency: 'JPY',
      displayOrder: 3,
      isArchived: false,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

Account transportExpense() => Account(
      id: 'acct-transport',
      userId: testUserId,
      name: '交通費',
      type: AccountType.expense,
      category: AccountCategory.transport,
      icon: 'directions_transit',
      color: '#607D8B',
      initialBalance: 0,
      currency: 'JPY',
      displayOrder: 4,
      isArchived: false,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

Account salaryIncome() => Account(
      id: 'acct-salary',
      userId: testUserId,
      name: '給与',
      type: AccountType.income,
      category: AccountCategory.salary,
      icon: 'work',
      color: '#4CAF50',
      initialBalance: 0,
      currency: 'JPY',
      displayOrder: 5,
      isArchived: false,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

Account archivedAccount() => Account(
      id: 'acct-archived',
      userId: testUserId,
      name: 'Old Wallet',
      type: AccountType.asset,
      category: AccountCategory.cash,
      icon: 'wallet',
      color: '#9E9E9E',
      initialBalance: 0,
      currency: 'JPY',
      displayOrder: 10,
      isArchived: true,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

List<Account> allAccounts() => [
      cashAccount(),
      bankAccount(),
      creditCardAccount(),
      foodExpense(),
      transportExpense(),
      salaryIncome(),
    ];

List<Account> allAccountsIncludingArchived() => [
      ...allAccounts(),
      archivedAccount(),
    ];

// ---- Account Balances ----

AccountBalance cashBalance() => const AccountBalance(
      id: 'acct-cash',
      name: '現金',
      type: AccountType.asset,
      category: AccountCategory.cash,
      icon: 'cash',
      color: '#4CAF50',
      currency: 'JPY',
      balance: 10000,
      displayOrder: 0,
    );

AccountBalance bankBalance() => const AccountBalance(
      id: 'acct-bank',
      name: '銀行口座',
      type: AccountType.asset,
      category: AccountCategory.bankAccount,
      icon: 'bank',
      color: '#2196F3',
      currency: 'JPY',
      balance: 500000,
      displayOrder: 1,
    );

AccountBalance creditCardBalance() => const AccountBalance(
      id: 'acct-cc',
      name: 'クレジットカード',
      type: AccountType.liability,
      category: AccountCategory.creditCard,
      icon: 'credit_card',
      color: '#FF5722',
      currency: 'JPY',
      balance: 30000,
      displayOrder: 2,
    );

List<AccountBalance> dashboardBalances() => [
      cashBalance(),
      bankBalance(),
      creditCardBalance(),
    ];

// ---- Monthly Summaries ----

MonthlySummary currentMonthSummary() => const MonthlySummary(
      totalIncome: 300000,
      totalExpense: 150000,
      netIncome: 150000,
      transactionCount: 25,
    );

MonthlySummary previousMonthSummary() => const MonthlySummary(
      totalIncome: 280000,
      totalExpense: 170000,
      netIncome: 110000,
      transactionCount: 30,
    );

MonthlySummary emptySummary() => const MonthlySummary(
      totalIncome: 0,
      totalExpense: 0,
      netIncome: 0,
      transactionCount: 0,
    );

// ---- Transactions ----

domain.Transaction todayExpense() => domain.Transaction(
      id: 'txn-1',
      userId: testUserId,
      date: DateTime.now(),
      amount: 1500,
      debitAccountId: 'acct-food',
      creditAccountId: 'acct-cash',
      description: 'ランチ',
      sourceType: SourceType.manual,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

domain.Transaction yesterdayExpense() => domain.Transaction(
      id: 'txn-2',
      userId: testUserId,
      date: DateTime.now().subtract(const Duration(days: 1)),
      amount: 350,
      debitAccountId: 'acct-transport',
      creditAccountId: 'acct-cash',
      description: '電車',
      sourceType: SourceType.manual,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

domain.Transaction thisMonthIncome() => domain.Transaction(
      id: 'txn-3',
      userId: testUserId,
      date: DateTime(DateTime.now().year, DateTime.now().month, 1),
      amount: 300000,
      debitAccountId: 'acct-bank',
      creditAccountId: 'acct-salary',
      description: '給与',
      sourceType: SourceType.manual,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

domain.Transaction transferTransaction() => domain.Transaction(
      id: 'txn-4',
      userId: testUserId,
      date: DateTime.now(),
      amount: 5000,
      debitAccountId: 'acct-cash',
      creditAccountId: 'acct-bank',
      description: 'ATM引き出し',
      sourceType: SourceType.manual,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

List<domain.Transaction> sampleTransactions() => [
      todayExpense(),
      yesterdayExpense(),
      thisMonthIncome(),
    ];

// ---- Category Breakdown (for reports) ----

Map<String, int> categoryBreakdown() => {
      '食費': 45000,
      '交通費': 15000,
      '住居費': 60000,
      '光熱費': 10000,
      '娯楽': 12000,
      'その他支出': 8000,
    };
