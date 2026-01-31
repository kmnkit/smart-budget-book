import 'package:zan/core/constants/enums.dart';
import 'package:zan/generated/l10n/app_localizations.dart';

class AccountFieldConfig {
  const AccountFieldConfig({
    required this.field1AllowedTypes,
    required this.field2AllowedTypes,
    required this.field1IsDebit,
  });

  /// Allowed AccountTypes for field 1 (left)
  final Set<AccountType> field1AllowedTypes;

  /// Allowed AccountTypes for field 2 (right)
  final Set<AccountType> field2AllowedTypes;

  /// If true, field1 maps to debit and field2 maps to credit.
  /// If false, field2 maps to debit and field1 maps to credit.
  final bool field1IsDebit;
}

extension TransactionTypeConfig on TransactionType {
  AccountFieldConfig get accountFieldConfig {
    return switch (this) {
      TransactionType.expense => const AccountFieldConfig(
          field1AllowedTypes: {AccountType.expense},
          field2AllowedTypes: {AccountType.asset, AccountType.liability},
          field1IsDebit: true,
        ),
      TransactionType.income => const AccountFieldConfig(
          field1AllowedTypes: {AccountType.income},
          field2AllowedTypes: {AccountType.asset},
          field1IsDebit: false,
        ),
      TransactionType.transfer => const AccountFieldConfig(
          field1AllowedTypes: {AccountType.asset, AccountType.liability},
          field2AllowedTypes: {AccountType.asset, AccountType.liability},
          field1IsDebit: false,
        ),
    };
  }

  String field1Label(AppLocalizations l10n) {
    return switch (this) {
      TransactionType.expense => l10n.expenseCategory,
      TransactionType.income => l10n.incomeSource,
      TransactionType.transfer => l10n.fromAccount,
    };
  }

  String field2Label(AppLocalizations l10n) {
    return switch (this) {
      TransactionType.expense => l10n.paymentMethod,
      TransactionType.income => l10n.receivingAccount,
      TransactionType.transfer => l10n.toAccount,
    };
  }
}

extension TransactionTypeL10n on TransactionType {
  String label(AppLocalizations l10n) {
    return switch (this) {
      TransactionType.expense => l10n.expense,
      TransactionType.income => l10n.income,
      TransactionType.transfer => l10n.transactionTypeTransfer,
    };
  }
}

/// Infer TransactionType from debit/credit account types.
TransactionType inferTransactionType({
  required AccountType debitType,
  required AccountType creditType,
}) {
  if (debitType == AccountType.expense) return TransactionType.expense;
  if (creditType == AccountType.income) return TransactionType.income;
  return TransactionType.transfer;
}
