import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zan/core/constants/enums.dart';

part 'transaction.freezed.dart';

@Freezed()
sealed class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String userId,
    required DateTime date,
    required int amount,
    required String debitAccountId,
    required String creditAccountId,
    String? description,
    String? note,
    required SourceType sourceType,
    @Default([]) List<String> tags,
    DateTime? deletedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Transaction;
}
