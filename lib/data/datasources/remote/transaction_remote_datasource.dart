import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zan/data/models/transaction_dto.dart';
import 'package:zan/domain/entities/transaction.dart' as domain;

class TransactionRemoteDataSource {
  const TransactionRemoteDataSource(this._client);
  final SupabaseClient _client;

  Future<List<domain.Transaction>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = _client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .isFilter('deleted_at', null);

    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String().split('T').first);
    }
    if (endDate != null) {
      query = query.lte('date', endDate.toIso8601String().split('T').first);
    }
    if (accountId != null) {
      query = query.or('debit_account_id.eq.$accountId,credit_account_id.eq.$accountId');
    }

    final data = await query
        .order('date', ascending: false)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    var transactions = data.map(TransactionDto.fromJson).toList();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      transactions = transactions
          .where((t) =>
              (t.description?.toLowerCase().contains(lowerQuery) ?? false) ||
              (t.note?.toLowerCase().contains(lowerQuery) ?? false))
          .toList();
    }

    return transactions;
  }

  Future<domain.Transaction> getTransaction(String id) async {
    final data = await _client
        .from('transactions')
        .select()
        .eq('id', id)
        .single();
    return TransactionDto.fromJson(data);
  }

  Future<domain.Transaction> createTransaction(domain.Transaction transaction) async {
    final data = await _client
        .from('transactions')
        .insert(TransactionDto.toInsertJson(transaction))
        .select()
        .single();
    return TransactionDto.fromJson(data);
  }

  Future<domain.Transaction> updateTransaction(domain.Transaction transaction) async {
    final data = await _client
        .from('transactions')
        .update(TransactionDto.toUpdateJson(transaction))
        .eq('id', transaction.id)
        .select()
        .single();
    return TransactionDto.fromJson(data);
  }

  Future<void> deleteTransaction(String id) async {
    await _client
        .from('transactions')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  Future<List<domain.Transaction>> getRecentTransactions(String userId, {int limit = 3}) async {
    final data = await _client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .limit(limit);
    return data.map(TransactionDto.fromJson).toList();
  }
}
