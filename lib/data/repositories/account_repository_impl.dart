import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/datasources/remote/account_remote_datasource.dart';
import 'package:zan/domain/entities/account.dart';
import 'package:zan/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._remoteDataSource);
  final AccountRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Account>>> getAccounts(String userId) async {
    try {
      final accounts = await _remoteDataSource.getAccounts(userId);
      return Success(accounts);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Account>>> getAllAccounts(String userId) async {
    try {
      final accounts = await _remoteDataSource.getAllAccounts(userId);
      return Success(accounts);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Account>> getAccount(String accountId) async {
    try {
      final account = await _remoteDataSource.getAccount(accountId);
      return Success(account);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Account>> createAccount(Account account) async {
    try {
      final created = await _remoteDataSource.createAccount(account);
      return Success(created);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> createAccounts(List<Account> accounts) async {
    try {
      await _remoteDataSource.createAccounts(accounts);
      return const Success(null);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Account>> updateAccount(Account account) async {
    try {
      final updated = await _remoteDataSource.updateAccount(account);
      return Success(updated);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> archiveAccount(String accountId) async {
    try {
      await _remoteDataSource.archiveAccount(accountId);
      return const Success(null);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> unarchiveAccount(String accountId) async {
    try {
      await _remoteDataSource.unarchiveAccount(accountId);
      return const Success(null);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateDisplayOrders(Map<String, int> orders) async {
    try {
      await _remoteDataSource.updateDisplayOrders(orders);
      return const Success(null);
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }
}
