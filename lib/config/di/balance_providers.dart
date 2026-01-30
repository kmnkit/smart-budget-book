import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/data/datasources/remote/balance_remote_datasource.dart';
import 'package:zan/data/datasources/remote/supabase_providers.dart';

part 'balance_providers.g.dart';

@riverpod
BalanceRemoteDataSource balanceRemoteDataSource(Ref ref) {
  return BalanceRemoteDataSource(ref.watch(supabaseClientProvider));
}
