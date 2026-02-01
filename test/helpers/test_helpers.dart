import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/data/datasources/remote/account_remote_datasource.dart';
import 'package:zan/data/datasources/remote/auth_remote_datasource.dart';
import 'package:zan/data/datasources/remote/balance_remote_datasource.dart';
import 'package:zan/data/datasources/remote/profile_remote_datasource.dart';
import 'package:zan/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:zan/domain/entities/account.dart';
import 'package:zan/domain/entities/account_balance.dart';
import 'package:zan/domain/entities/monthly_summary.dart';
import 'package:zan/domain/entities/profile.dart';
import 'package:zan/domain/entities/transaction.dart' as domain;
import 'package:zan/domain/repositories/account_repository.dart';
import 'package:zan/domain/repositories/auth_repository.dart';
import 'package:zan/domain/repositories/profile_repository.dart';
import 'package:zan/domain/repositories/transaction_repository.dart';

// ---- Mock Classes ----

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockAccountRemoteDataSource extends Mock implements AccountRemoteDataSource {}

class MockTransactionRemoteDataSource extends Mock implements TransactionRemoteDataSource {}

class MockBalanceRemoteDataSource extends Mock implements BalanceRemoteDataSource {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockProfileRemoteDataSource extends Mock implements ProfileRemoteDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

class FakeAuthResponse extends Fake implements AuthResponse {
  @override
  User? get user => null;
}

// ---- Test Constants ----

const testUserId = 'test-user-id-123';
const testAccountId = 'test-account-id-456';
const testTransactionId = 'test-transaction-id-789';

final testDateTime = DateTime(2026, 1, 15, 10, 30);
final testDate = DateTime(2026, 1, 15);

// ---- Factory Functions ----

Account createTestAccount({
  String id = 'test-account-id-456',
  String userId = 'test-user-id-123',
  String name = 'Test Wallet',
  AccountType type = AccountType.asset,
  AccountCategory category = AccountCategory.cash,
  String icon = 'wallet',
  String color = '#6366F1',
  int initialBalance = 0,
  String currency = 'JPY',
  int displayOrder = 0,
  bool isArchived = false,
  int? paymentDueDay,
  String? note,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return Account(
    id: id,
    userId: userId,
    name: name,
    type: type,
    category: category,
    icon: icon,
    color: color,
    initialBalance: initialBalance,
    currency: currency,
    displayOrder: displayOrder,
    isArchived: isArchived,
    paymentDueDay: paymentDueDay,
    note: note,
    createdAt: createdAt ?? testDateTime,
    updatedAt: updatedAt ?? testDateTime,
  );
}

domain.Transaction createTestTransaction({
  String id = 'test-transaction-id-789',
  String userId = 'test-user-id-123',
  DateTime? date,
  int amount = 1000,
  String debitAccountId = 'debit-account-id',
  String creditAccountId = 'credit-account-id',
  String? description = 'Test transaction',
  String? note,
  SourceType sourceType = SourceType.manual,
  List<String> tags = const [],
  DateTime? deletedAt,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return domain.Transaction(
    id: id,
    userId: userId,
    date: date ?? testDate,
    amount: amount,
    debitAccountId: debitAccountId,
    creditAccountId: creditAccountId,
    description: description,
    note: note,
    sourceType: sourceType,
    tags: tags,
    deletedAt: deletedAt,
    createdAt: createdAt ?? testDateTime,
    updatedAt: updatedAt ?? testDateTime,
  );
}

AccountBalance createTestAccountBalance({
  String id = 'test-account-id-456',
  String name = 'Test Wallet',
  AccountType type = AccountType.asset,
  AccountCategory category = AccountCategory.cash,
  String icon = 'wallet',
  String color = '#6366F1',
  String currency = 'JPY',
  int balance = 50000,
  int displayOrder = 0,
}) {
  return AccountBalance(
    id: id,
    name: name,
    type: type,
    category: category,
    icon: icon,
    color: color,
    currency: currency,
    balance: balance,
    displayOrder: displayOrder,
  );
}

MonthlySummary createTestMonthlySummary({
  int totalIncome = 300000,
  int totalExpense = 150000,
  int netIncome = 150000,
  int transactionCount = 25,
}) {
  return MonthlySummary(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    netIncome: netIncome,
    transactionCount: transactionCount,
  );
}

// ---- JSON Fixture Maps ----

Map<String, dynamic> accountJsonFixture({
  String id = 'test-account-id-456',
  String userId = 'test-user-id-123',
  String name = 'Test Wallet',
  String type = 'asset',
  String category = 'cash',
  String icon = 'wallet',
  String color = '#6366F1',
  int initialBalance = 0,
  String currency = 'JPY',
  int displayOrder = 0,
  bool isArchived = false,
  int? paymentDueDay,
  String? note,
  String? createdAt,
  String? updatedAt,
}) {
  return {
    'id': id,
    'user_id': userId,
    'name': name,
    'type': type,
    'category': category,
    'icon': icon,
    'color': color,
    'initial_balance': initialBalance,
    'currency': currency,
    'display_order': displayOrder,
    'is_archived': isArchived,
    'payment_due_day': paymentDueDay,
    'note': note,
    'created_at': createdAt ?? '2026-01-15T10:30:00.000',
    'updated_at': updatedAt ?? '2026-01-15T10:30:00.000',
  };
}

Map<String, dynamic> transactionJsonFixture({
  String id = 'test-transaction-id-789',
  String userId = 'test-user-id-123',
  String date = '2026-01-15',
  int amount = 1000,
  String debitAccountId = 'debit-account-id',
  String creditAccountId = 'credit-account-id',
  String? description = 'Test transaction',
  String? note,
  String sourceType = 'manual',
  List<String>? tags,
  String? deletedAt,
  String? createdAt,
  String? updatedAt,
}) {
  return {
    'id': id,
    'user_id': userId,
    'date': date,
    'amount': amount,
    'debit_account_id': debitAccountId,
    'credit_account_id': creditAccountId,
    'description': description,
    'note': note,
    'source_type': sourceType,
    'tags': tags,
    'deleted_at': deletedAt,
    'created_at': createdAt ?? '2026-01-15T10:30:00.000',
    'updated_at': updatedAt ?? '2026-01-15T10:30:00.000',
  };
}

Map<String, dynamic> balanceJsonFixture({
  String id = 'test-account-id-456',
  String name = 'Test Wallet',
  String type = 'asset',
  String category = 'cash',
  String? icon = 'wallet',
  String? color = '#6366F1',
  String? currency = 'JPY',
  int balance = 50000,
  int? displayOrder = 0,
}) {
  return {
    'id': id,
    'name': name,
    'type': type,
    'category': category,
    'icon': icon,
    'color': color,
    'currency': currency,
    'balance': balance,
    'display_order': displayOrder,
  };
}

Map<String, dynamic> monthlySummaryJsonFixture({
  int totalIncome = 300000,
  int totalExpense = 150000,
  int netIncome = 150000,
  int transactionCount = 25,
}) {
  return {
    'total_income': totalIncome,
    'total_expense': totalExpense,
    'net_income': netIncome,
    'transaction_count': transactionCount,
  };
}

// ---- Profile Helpers ----

Profile createTestProfile({
  String id = 'test-user-id-123',
  String? displayName = 'Test User',
  String defaultCurrency = 'JPY',
  String country = 'JP',
  String? defaultDebitAccountId,
  bool onboardingCompleted = false,
  Map<String, dynamic> settings = const {},
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return Profile(
    id: id,
    displayName: displayName,
    defaultCurrency: defaultCurrency,
    country: country,
    defaultDebitAccountId: defaultDebitAccountId,
    onboardingCompleted: onboardingCompleted,
    settings: settings,
    createdAt: createdAt ?? testDateTime,
    updatedAt: updatedAt ?? testDateTime,
  );
}

Map<String, dynamic> profileJsonFixture({
  String id = 'test-user-id-123',
  String? displayName = 'Test User',
  String defaultCurrency = 'JPY',
  String country = 'JP',
  String? defaultDebitAccountId,
  bool onboardingCompleted = false,
  Map<String, dynamic>? settings,
  String? createdAt,
  String? updatedAt,
}) {
  return {
    'id': id,
    'display_name': displayName,
    'default_currency': defaultCurrency,
    'country': country,
    'default_debit_account_id': defaultDebitAccountId,
    'onboarding_completed': onboardingCompleted,
    'settings': settings ?? {},
    'created_at': createdAt ?? '2026-01-15T10:30:00.000',
    'updated_at': updatedAt ?? '2026-01-15T10:30:00.000',
  };
}
