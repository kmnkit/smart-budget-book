import 'package:zan/core/constants/enums.dart';
import 'package:zan/domain/entities/transaction.dart';

class TransactionDto {
  const TransactionDto._();

  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: json['amount'] as int,
      debitAccountId: json['debit_account_id'] as String,
      creditAccountId: json['credit_account_id'] as String,
      description: json['description'] as String?,
      note: json['note'] as String?,
      sourceType: SourceType.fromDbValue(json['source_type'] as String? ?? 'manual'),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static Map<String, dynamic> toInsertJson(Transaction transaction) {
    return {
      'user_id': transaction.userId,
      'date': transaction.date.toIso8601String().split('T').first,
      'amount': transaction.amount,
      'debit_account_id': transaction.debitAccountId,
      'credit_account_id': transaction.creditAccountId,
      'description': transaction.description,
      'note': transaction.note,
      'source_type': transaction.sourceType.dbValue,
      'tags': transaction.tags,
    };
  }

  static Map<String, dynamic> toUpdateJson(Transaction transaction) {
    return {
      'date': transaction.date.toIso8601String().split('T').first,
      'amount': transaction.amount,
      'debit_account_id': transaction.debitAccountId,
      'credit_account_id': transaction.creditAccountId,
      'description': transaction.description,
      'note': transaction.note,
      'tags': transaction.tags,
    };
  }
}
