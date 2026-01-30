import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zan/core/constants/enums.dart';

part 'account_balance.freezed.dart';

@Freezed()
sealed class AccountBalance with _$AccountBalance {
  const factory AccountBalance({
    required String id,
    required String name,
    required AccountType type,
    required AccountCategory category,
    required String icon,
    required String color,
    required String currency,
    required int balance,
    required int displayOrder,
  }) = _AccountBalance;
}
