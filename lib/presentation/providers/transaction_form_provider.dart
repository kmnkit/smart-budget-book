import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/di/transaction_providers.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/core/utils/transaction_type_helper.dart';
import 'package:zan/domain/entities/account.dart';
import 'package:zan/domain/entities/transaction.dart';
import 'package:zan/presentation/providers/auth_provider.dart';
import 'package:zan/presentation/providers/dashboard_provider.dart';
import 'package:zan/presentation/providers/report_provider.dart';
import 'package:zan/presentation/providers/subscription_provider.dart';
import 'package:zan/presentation/providers/transaction_list_provider.dart';

part 'transaction_form_provider.g.dart';

class TransactionFormState {
  const TransactionFormState({
    this.transactionType = TransactionType.expense,
    this.debitAccountId,
    this.creditAccountId,
    this.amount = 0,
    this.date,
    this.description,
    this.note,
    this.isLoading = false,
    this.error,
  });

  final TransactionType transactionType;
  final String? debitAccountId;
  final String? creditAccountId;
  final int amount;
  final DateTime? date;
  final String? description;
  final String? note;
  final bool isLoading;
  final String? error;

  TransactionFormState copyWith({
    TransactionType? transactionType,
    String? debitAccountId,
    String? creditAccountId,
    int? amount,
    DateTime? date,
    String? description,
    String? note,
    bool? isLoading,
    String? error,
  }) {
    return TransactionFormState(
      transactionType: transactionType ?? this.transactionType,
      debitAccountId: debitAccountId ?? this.debitAccountId,
      creditAccountId: creditAccountId ?? this.creditAccountId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      note: note ?? this.note,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Create a copy with account IDs explicitly cleared to null.
  TransactionFormState clearAccounts() {
    return TransactionFormState(
      transactionType: transactionType,
      debitAccountId: null,
      creditAccountId: null,
      amount: amount,
      date: date,
      description: description,
      note: note,
      isLoading: isLoading,
      error: error,
    );
  }

  bool get isValid =>
      debitAccountId != null &&
      creditAccountId != null &&
      amount > 0 &&
      debitAccountId != creditAccountId;
}

@riverpod
class TransactionFormNotifier extends _$TransactionFormNotifier {
  @override
  TransactionFormState build() => TransactionFormState(date: DateTime.now());

  void setTransactionType(TransactionType type) {
    if (type == state.transactionType) return;
    state = state.clearAccounts().copyWith(transactionType: type);
  }

  void setDebitAccount(String id) {
    state = state.copyWith(debitAccountId: id);
  }

  void setCreditAccount(String id) {
    state = state.copyWith(creditAccountId: id);
  }

  void setAmount(int amount) {
    state = state.copyWith(amount: amount);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setDescription(String? description) {
    state = state.copyWith(description: description);
  }

  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  /// Load from an existing transaction for editing.
  /// Infers the TransactionType from the account types.
  void loadFromTransaction(Transaction transaction, List<Account> accounts) {
    final debitAccount =
        accounts.where((a) => a.id == transaction.debitAccountId).firstOrNull;
    final creditAccount =
        accounts.where((a) => a.id == transaction.creditAccountId).firstOrNull;

    final type = (debitAccount != null && creditAccount != null)
        ? inferTransactionType(
            debitType: debitAccount.type,
            creditType: creditAccount.type,
          )
        : TransactionType.expense;

    state = TransactionFormState(
      transactionType: type,
      debitAccountId: transaction.debitAccountId,
      creditAccountId: transaction.creditAccountId,
      amount: transaction.amount,
      date: transaction.date,
      description: transaction.description,
      note: transaction.note,
    );
  }

  Future<bool> save({String? existingId}) async {
    if (!state.isValid) return false;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return false;

    // Check transaction quota for new transactions
    if (existingId == null) {
      final access = ref.read(featureAccessProvider(FeatureType.createTransaction));
      if (!access.allowed) {
        state = state.copyWith(error: access.reason);
        return false;
      }
    }

    state = state.copyWith(isLoading: true, error: null);

    final now = DateTime.now();
    final transaction = Transaction(
      id: existingId ?? '',
      userId: userId,
      date: state.date ?? now,
      amount: state.amount,
      debitAccountId: state.debitAccountId!,
      creditAccountId: state.creditAccountId!,
      description: state.description,
      note: state.note,
      sourceType: SourceType.manual,
      createdAt: now,
      updatedAt: now,
    );

    final repo = ref.read(transactionRepositoryProvider);
    final result = existingId != null
        ? await repo.updateTransaction(transaction)
        : await repo.createTransaction(transaction);

    return result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        _invalidateTransactionDependents();
        return true;
      },
      failure: (f) {
        state = state.copyWith(isLoading: false, error: f.message);
        return false;
      },
    );
  }

  void _invalidateTransactionDependents() {
    ref.invalidate(accountBalancesProvider);
    ref.invalidate(currentMonthSummaryProvider);
    ref.invalidate(transactionListProvider);
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(monthlyReportProvider);
    ref.invalidate(categoryBreakdownProvider);
    ref.invalidate(previousMonthSummaryProvider);
    ref.invalidate(usageQuotaProvider);
  }
}
