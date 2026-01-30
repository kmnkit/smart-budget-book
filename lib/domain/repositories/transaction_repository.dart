import 'package:zan/core/usecase/result.dart';
import 'package:zan/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<Result<List<Transaction>>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  });
  Future<Result<Transaction>> getTransaction(String id);
  Future<Result<Transaction>> createTransaction(Transaction transaction);
  Future<Result<Transaction>> updateTransaction(Transaction transaction);
  Future<Result<void>> deleteTransaction(String id);
  Future<Result<List<Transaction>>> getRecentTransactions(String userId, {int limit = 3});
}
