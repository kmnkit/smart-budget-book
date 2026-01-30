import 'package:flutter_test/flutter_test.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/data/models/account_dto.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('AccountDto', () {
    group('fromJson', () {
      test('전체 필드 파싱 검증', () {
        // arrange
        final json = accountJsonFixture(
          id: 'acc-123',
          userId: 'user-456',
          name: 'My Wallet',
          type: 'asset',
          category: 'cash',
          icon: 'wallet',
          color: '#FF0000',
          initialBalance: 10000,
          currency: 'KRW',
          displayOrder: 2,
          isArchived: false,
          paymentDueDay: 25,
          note: 'Test note',
          createdAt: '2026-01-10T09:00:00.000',
          updatedAt: '2026-01-15T12:00:00.000',
        );

        // act
        final account = AccountDto.fromJson(json);

        // assert
        expect(account.id, 'acc-123');
        expect(account.userId, 'user-456');
        expect(account.name, 'My Wallet');
        expect(account.type, AccountType.asset);
        expect(account.category, AccountCategory.cash);
        expect(account.icon, 'wallet');
        expect(account.color, '#FF0000');
        expect(account.initialBalance, 10000);
        expect(account.currency, 'KRW');
        expect(account.displayOrder, 2);
        expect(account.isArchived, false);
        expect(account.paymentDueDay, 25);
        expect(account.note, 'Test note');
        expect(account.createdAt, DateTime(2026, 1, 10, 9, 0));
        expect(account.updatedAt, DateTime(2026, 1, 15, 12, 0));
      });

      test('nullable 필드 기본값 검증', () {
        // arrange — minimal JSON with nulls for optional fields
        final json = {
          'id': 'acc-min',
          'user_id': 'user-min',
          'name': 'Minimal Account',
          'type': 'income',
          'category': 'salary',
          'icon': null,
          'color': null,
          'initial_balance': null,
          'currency': null,
          'display_order': null,
          'is_archived': null,
          'payment_due_day': null,
          'note': null,
          'created_at': '2026-01-01T00:00:00.000',
          'updated_at': '2026-01-01T00:00:00.000',
        };

        // act
        final account = AccountDto.fromJson(json);

        // assert
        expect(account.icon, 'wallet');
        expect(account.color, '#6366F1');
        expect(account.initialBalance, 0);
        expect(account.currency, 'JPY');
        expect(account.displayOrder, 0);
        expect(account.isArchived, false);
        expect(account.paymentDueDay, isNull);
        expect(account.note, isNull);
      });
    });

    group('toInsertJson', () {
      test('직렬화 검증 — user_id 포함', () {
        // arrange
        final account = createTestAccount(
          userId: 'user-789',
          name: 'Savings',
          type: AccountType.asset,
          category: AccountCategory.bankAccount,
          icon: 'bank',
          color: '#00FF00',
          initialBalance: 5000,
          currency: 'JPY',
          displayOrder: 1,
          isArchived: false,
          paymentDueDay: 15,
          note: 'Monthly savings',
        );

        // act
        final json = AccountDto.toInsertJson(account);

        // assert
        expect(json['user_id'], 'user-789');
        expect(json['name'], 'Savings');
        expect(json['type'], 'asset');
        expect(json['category'], 'bank_account');
        expect(json['icon'], 'bank');
        expect(json['color'], '#00FF00');
        expect(json['initial_balance'], 5000);
        expect(json['currency'], 'JPY');
        expect(json['display_order'], 1);
        expect(json['is_archived'], false);
        expect(json['payment_due_day'], 15);
        expect(json['note'], 'Monthly savings');
        // Should NOT contain 'id', 'created_at', 'updated_at'
        expect(json.containsKey('id'), false);
        expect(json.containsKey('created_at'), false);
        expect(json.containsKey('updated_at'), false);
      });
    });

    group('toUpdateJson', () {
      test('user_id 제외 확인', () {
        // arrange
        final account = createTestAccount(
          userId: 'user-789',
          name: 'Updated Name',
        );

        // act
        final json = AccountDto.toUpdateJson(account);

        // assert
        expect(json['name'], 'Updated Name');
        // Should NOT contain 'user_id', 'id', 'type', 'category', 'currency'
        expect(json.containsKey('user_id'), false);
        expect(json.containsKey('id'), false);
        expect(json.containsKey('type'), false);
        expect(json.containsKey('category'), false);
        expect(json.containsKey('currency'), false);
        expect(json.containsKey('created_at'), false);
        expect(json.containsKey('updated_at'), false);
        // Should contain editable fields
        expect(json.containsKey('name'), true);
        expect(json.containsKey('icon'), true);
        expect(json.containsKey('color'), true);
        expect(json.containsKey('initial_balance'), true);
        expect(json.containsKey('display_order'), true);
        expect(json.containsKey('is_archived'), true);
      });
    });
  });
}
