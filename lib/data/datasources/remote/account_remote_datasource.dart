import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zan/data/models/account_dto.dart';
import 'package:zan/domain/entities/account.dart';

class AccountRemoteDataSource {
  const AccountRemoteDataSource(this._client);
  final SupabaseClient _client;

  Future<List<Account>> getAccounts(String userId) async {
    final data = await _client
        .from('accounts')
        .select()
        .eq('user_id', userId)
        .eq('is_archived', false)
        .order('type')
        .order('display_order');
    return data.map(AccountDto.fromJson).toList();
  }

  Future<List<Account>> getAllAccounts(String userId) async {
    final data = await _client
        .from('accounts')
        .select()
        .eq('user_id', userId)
        .order('type')
        .order('display_order');
    return data.map(AccountDto.fromJson).toList();
  }

  Future<Account> getAccount(String accountId) async {
    final data = await _client
        .from('accounts')
        .select()
        .eq('id', accountId)
        .single();
    return AccountDto.fromJson(data);
  }

  Future<Account> createAccount(Account account) async {
    final data = await _client
        .from('accounts')
        .insert(AccountDto.toInsertJson(account))
        .select()
        .single();
    return AccountDto.fromJson(data);
  }

  Future<void> createAccounts(List<Account> accounts) async {
    final jsonList = accounts.map(AccountDto.toInsertJson).toList();
    await _client.from('accounts').insert(jsonList);
  }

  Future<Account> updateAccount(Account account) async {
    final data = await _client
        .from('accounts')
        .update(AccountDto.toUpdateJson(account))
        .eq('id', account.id)
        .select()
        .single();
    return AccountDto.fromJson(data);
  }

  Future<void> archiveAccount(String accountId) async {
    await _client
        .from('accounts')
        .update({'is_archived': true})
        .eq('id', accountId);
  }

  Future<void> unarchiveAccount(String accountId) async {
    await _client
        .from('accounts')
        .update({'is_archived': false})
        .eq('id', accountId);
  }

  Future<void> updateDisplayOrders(Map<String, int> orders) async {
    for (final entry in orders.entries) {
      await _client
          .from('accounts')
          .update({'display_order': entry.value})
          .eq('id', entry.key);
    }
  }
}
