import 'package:flutter_test/flutter_test.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/data/models/transaction_dto.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('TransactionDto', () {
    group('fromJson', () {
      test('전체 필드 파싱 검증', () {
        // arrange
        final json = transactionJsonFixture(
          id: 'tx-123',
          userId: 'user-456',
          date: '2026-01-20',
          amount: 5000,
          debitAccountId: 'debit-acc',
          creditAccountId: 'credit-acc',
          description: 'Dinner',
          note: 'With friends',
          sourceType: 'text_ai',
          tags: ['food', 'social'],
          deletedAt: null,
          createdAt: '2026-01-20T18:30:00.000',
          updatedAt: '2026-01-20T18:30:00.000',
        );

        // act
        final transaction = TransactionDto.fromJson(json);

        // assert
        expect(transaction.id, 'tx-123');
        expect(transaction.userId, 'user-456');
        expect(transaction.date, DateTime(2026, 1, 20));
        expect(transaction.amount, 5000);
        expect(transaction.debitAccountId, 'debit-acc');
        expect(transaction.creditAccountId, 'credit-acc');
        expect(transaction.description, 'Dinner');
        expect(transaction.note, 'With friends');
        expect(transaction.sourceType, SourceType.textAi);
        expect(transaction.tags, ['food', 'social']);
        expect(transaction.deletedAt, isNull);
        expect(transaction.createdAt, DateTime(2026, 1, 20, 18, 30));
        expect(transaction.updatedAt, DateTime(2026, 1, 20, 18, 30));
      });

      test('tags 파싱, deletedAt null 처리, source_type 기본값', () {
        // arrange — tags null, deletedAt null, source_type null
        final json = {
          'id': 'tx-min',
          'user_id': 'user-min',
          'date': '2026-02-01',
          'amount': 100,
          'debit_account_id': 'da',
          'credit_account_id': 'ca',
          'description': null,
          'note': null,
          'source_type': null,
          'tags': null,
          'deleted_at': null,
          'created_at': '2026-02-01T00:00:00.000',
          'updated_at': '2026-02-01T00:00:00.000',
        };

        // act
        final transaction = TransactionDto.fromJson(json);

        // assert
        expect(transaction.tags, isEmpty);
        expect(transaction.deletedAt, isNull);
        expect(transaction.sourceType, SourceType.manual);
        expect(transaction.description, isNull);
        expect(transaction.note, isNull);
      });
    });

    group('toInsertJson', () {
      test('날짜 포맷 (date only, no time) 및 필드 검증', () {
        // arrange
        final transaction = createTestTransaction(
          userId: 'user-789',
          date: DateTime(2026, 3, 15, 14, 30, 45),
          amount: 2500,
          debitAccountId: 'expense-food',
          creditAccountId: 'wallet',
          description: 'Lunch',
          note: 'Ramen',
          sourceType: SourceType.voiceAi,
          tags: ['food'],
        );

        // act
        final json = TransactionDto.toInsertJson(transaction);

        // assert
        expect(json['user_id'], 'user-789');
        expect(json['date'], '2026-03-15'); // date only, no time part
        expect(json['amount'], 2500);
        expect(json['debit_account_id'], 'expense-food');
        expect(json['credit_account_id'], 'wallet');
        expect(json['description'], 'Lunch');
        expect(json['note'], 'Ramen');
        expect(json['source_type'], 'voice_ai');
        expect(json['tags'], ['food']);
        // Should NOT contain generated fields
        expect(json.containsKey('id'), false);
        expect(json.containsKey('created_at'), false);
        expect(json.containsKey('updated_at'), false);
        expect(json.containsKey('deleted_at'), false);
      });
    });

    group('toUpdateJson', () {
      test('user_id 제외, source_type 제외 확인', () {
        // arrange
        final transaction = createTestTransaction(
          userId: 'user-789',
          description: 'Updated desc',
          sourceType: SourceType.ocr,
        );

        // act
        final json = TransactionDto.toUpdateJson(transaction);

        // assert
        expect(json['description'], 'Updated desc');
        expect(json['date'], isA<String>());
        // Should NOT contain user_id, source_type, id, created_at, updated_at, deleted_at
        expect(json.containsKey('user_id'), false);
        expect(json.containsKey('source_type'), false);
        expect(json.containsKey('id'), false);
        expect(json.containsKey('created_at'), false);
        expect(json.containsKey('updated_at'), false);
        expect(json.containsKey('deleted_at'), false);
        // Should contain editable fields
        expect(json.containsKey('date'), true);
        expect(json.containsKey('amount'), true);
        expect(json.containsKey('debit_account_id'), true);
        expect(json.containsKey('credit_account_id'), true);
        expect(json.containsKey('description'), true);
        expect(json.containsKey('note'), true);
        expect(json.containsKey('tags'), true);
      });
    });
  });
}
