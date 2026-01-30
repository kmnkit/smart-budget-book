import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:zan/domain/entities/transaction.dart';
import 'package:zan/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._remoteDataSource);
  final TransactionRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Transaction>>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final transactions = await _remoteDataSource.getTransactions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        searchQuery: searchQuery,
        limit: limit,
        offset: offset,
      );
      return Success(transactions);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Transaction>> getTransaction(String id) async {
    try {
      final transaction = await _remoteDataSource.getTransaction(id);
      return Success(transaction);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Transaction>> createTransaction(Transaction transaction) async {
    try {
      final created = await _remoteDataSource.createTransaction(transaction);
      return Success(created);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Transaction>> updateTransaction(Transaction transaction) async {
    try {
      final updated = await _remoteDataSource.updateTransaction(transaction);
      return Success(updated);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteTransaction(String id) async {
    try {
      await _remoteDataSource.deleteTransaction(id);
      return const Success(null);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Transaction>>> getRecentTransactions(String userId, {int limit = 3}) async {
    try {
      final transactions = await _remoteDataSource.getRecentTransactions(userId, limit: limit);
      return Success(transactions);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }
}
