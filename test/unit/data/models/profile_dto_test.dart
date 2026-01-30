import 'package:flutter_test/flutter_test.dart';
import 'package:zan/data/models/profile_dto.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('ProfileDto', () {
    group('fromJson', () {
      test('전체 필드 파싱 검증', () {
        // arrange
        final json = profileJsonFixture(
          id: 'user-1',
          displayName: '홍길동',
          defaultCurrency: 'KRW',
          country: 'KR',
          defaultDebitAccountId: 'debit-acc-1',
          onboardingCompleted: true,
          settings: {'theme': 'dark', 'notifications': true},
          createdAt: '2026-01-15T10:30:00.000',
          updatedAt: '2026-01-20T15:45:00.000',
        );

        // act
        final profile = ProfileDto.fromJson(json);

        // assert
        expect(profile.id, 'user-1');
        expect(profile.displayName, '홍길동');
        expect(profile.defaultCurrency, 'KRW');
        expect(profile.country, 'KR');
        expect(profile.defaultDebitAccountId, 'debit-acc-1');
        expect(profile.onboardingCompleted, true);
        expect(profile.settings, {'theme': 'dark', 'notifications': true});
        expect(profile.createdAt, DateTime.parse('2026-01-15T10:30:00.000'));
        expect(profile.updatedAt, DateTime.parse('2026-01-20T15:45:00.000'));
      });

      test('nullable 필드 기본값 검증', () {
        // arrange
        final json = <String, dynamic>{
          'id': 'minimal-user',
          'display_name': null,
          'default_currency': null,
          'country': null,
          'default_debit_account_id': null,
          'onboarding_completed': null,
          'settings': null,
          'created_at': '2026-01-15T10:30:00.000',
          'updated_at': '2026-01-15T10:30:00.000',
        };

        // act
        final profile = ProfileDto.fromJson(json);

        // assert
        expect(profile.id, 'minimal-user');
        expect(profile.displayName, isNull);
        expect(profile.defaultCurrency, 'JPY');
        expect(profile.country, 'JP');
        expect(profile.defaultDebitAccountId, isNull);
        expect(profile.onboardingCompleted, false);
        expect(profile.settings, isEmpty);
      });
    });

    group('toJson', () {
      test('직렬화 검증', () {
        // arrange
        final profile = createTestProfile(
          id: 'user-1',
          displayName: '김철수',
          defaultCurrency: 'KRW',
          country: 'KR',
          defaultDebitAccountId: 'debit-acc-1',
          onboardingCompleted: true,
          settings: {'language': 'ko'},
        );

        // act
        final json = ProfileDto.toJson(profile);

        // assert
        expect(json['id'], 'user-1');
        expect(json['display_name'], '김철수');
        expect(json['default_currency'], 'KRW');
        expect(json['country'], 'KR');
        expect(json['default_debit_account_id'], 'debit-acc-1');
        expect(json['onboarding_completed'], true);
        expect(json['settings'], {'language': 'ko'});
      });

      test('timestamps 미포함 검증', () {
        // arrange
        final profile = createTestProfile();

        // act
        final json = ProfileDto.toJson(profile);

        // assert
        expect(json.containsKey('created_at'), false);
        expect(json.containsKey('updated_at'), false);
      });
    });
  });
}
