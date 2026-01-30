import 'package:zan/core/constants/enums.dart';
import 'package:zan/domain/entities/account.dart';

class AccountDto {
  const AccountDto._();

  static Account fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: AccountType.values.firstWhere((e) => e.name == json['type']),
      category: AccountCategory.fromDbValue(json['category'] as String),
      icon: json['icon'] as String? ?? 'wallet',
      color: json['color'] as String? ?? '#6366F1',
      initialBalance: json['initial_balance'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'JPY',
      displayOrder: json['display_order'] as int? ?? 0,
      isArchived: json['is_archived'] as bool? ?? false,
      paymentDueDay: json['payment_due_day'] as int?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static Map<String, dynamic> toInsertJson(Account account) {
    return {
      'user_id': account.userId,
      'name': account.name,
      'type': account.type.name,
      'category': account.category.dbValue,
      'icon': account.icon,
      'color': account.color,
      'initial_balance': account.initialBalance,
      'currency': account.currency,
      'display_order': account.displayOrder,
      'is_archived': account.isArchived,
      'payment_due_day': account.paymentDueDay,
      'note': account.note,
    };
  }

  static Map<String, dynamic> toUpdateJson(Account account) {
    return {
      'name': account.name,
      'icon': account.icon,
      'color': account.color,
      'initial_balance': account.initialBalance,
      'display_order': account.displayOrder,
      'is_archived': account.isArchived,
      'payment_due_day': account.paymentDueDay,
      'note': account.note,
    };
  }
}
