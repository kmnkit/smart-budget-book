import 'package:zan/core/usecase/result.dart';
import 'package:zan/domain/entities/account.dart';

abstract class AccountRepository {
  Future<Result<List<Account>>> getAccounts(String userId);
  Future<Result<List<Account>>> getAllAccounts(String userId);
  Future<Result<Account>> getAccount(String accountId);
  Future<Result<Account>> createAccount(Account account);
  Future<Result<void>> createAccounts(List<Account> accounts);
  Future<Result<Account>> updateAccount(Account account);
  Future<Result<void>> archiveAccount(String accountId);
  Future<Result<void>> unarchiveAccount(String accountId);
  Future<Result<void>> updateDisplayOrders(Map<String, int> orders);
}
