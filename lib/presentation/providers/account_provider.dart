import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/di/account_providers.dart';
import 'package:zan/domain/entities/account.dart';
import 'package:zan/presentation/providers/auth_provider.dart';

part 'account_provider.g.dart';

@riverpod
Future<List<Account>> accountList(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final result = await ref.watch(accountRepositoryProvider).getAccounts(userId);
  return result.when(
    success: (accounts) => accounts,
    failure: (_) => [],
  );
}

@riverpod
Future<List<Account>> allAccountList(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final result = await ref.watch(accountRepositoryProvider).getAllAccounts(userId);
  return result.when(
    success: (accounts) => accounts,
    failure: (_) => [],
  );
}
