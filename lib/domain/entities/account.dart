import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zan/core/constants/enums.dart';

part 'account.freezed.dart';

@Freezed()
sealed class Account with _$Account {
  const factory Account({
    required String id,
    required String userId,
    required String name,
    required AccountType type,
    required AccountCategory category,
    required String icon,
    required String color,
    required int initialBalance,
    required String currency,
    required int displayOrder,
    required bool isArchived,
    int? paymentDueDay,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Account;
}
