import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/data/datasources/remote/supabase_providers.dart';
import 'package:zan/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:zan/data/repositories/transaction_repository_impl.dart';
import 'package:zan/domain/repositories/transaction_repository.dart';

part 'transaction_providers.g.dart';

@riverpod
TransactionRemoteDataSource transactionRemoteDataSource(Ref ref) {
  return TransactionRemoteDataSource(ref.watch(supabaseClientProvider));
}

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepositoryImpl(ref.watch(transactionRemoteDataSourceProvider));
}
