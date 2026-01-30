import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/domain/entities/account_balance.dart';
import 'package:zan/domain/entities/monthly_summary.dart';

class BalanceRemoteDataSource {
  const BalanceRemoteDataSource(this._client);
  final SupabaseClient _client;

  Future<List<AccountBalance>> getUserBalances(String userId) async {
    final data = await _client.rpc<List<dynamic>>('get_user_balances', params: {
      'p_user_id': userId,
    });
    return data.map((json) {
      final map = json as Map<String, dynamic>;
      return AccountBalance(
        id: map['id'] as String,
        name: map['name'] as String,
        type: AccountType.values.firstWhere((e) => e.name == map['type']),
        category: AccountCategory.fromDbValue(map['category'] as String),
        icon: map['icon'] as String? ?? 'wallet',
        color: map['color'] as String? ?? '#6366F1',
        currency: map['currency'] as String? ?? 'JPY',
        balance: (map['balance'] as num).toInt(),
        displayOrder: (map['display_order'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  Future<MonthlySummary> getMonthlySummary({
    required String userId,
    required int year,
    required int month,
  }) async {
    final data = await _client.rpc<List<dynamic>>('get_monthly_summary', params: {
      'p_user_id': userId,
      'p_year': year,
      'p_month': month,
    });
    if (data.isNotEmpty) {
      final map = data.first as Map<String, dynamic>;
      return MonthlySummary(
        totalIncome: (map['total_income'] as num?)?.toInt() ?? 0,
        totalExpense: (map['total_expense'] as num?)?.toInt() ?? 0,
        netIncome: (map['net_income'] as num?)?.toInt() ?? 0,
        transactionCount: (map['transaction_count'] as num?)?.toInt() ?? 0,
      );
    }
    return const MonthlySummary(
      totalIncome: 0,
      totalExpense: 0,
      netIncome: 0,
      transactionCount: 0,
    );
  }
}
