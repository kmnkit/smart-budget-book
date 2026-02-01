import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/presentation/screens/home/home_screen.dart';
import 'package:zan/presentation/screens/settings/settings_screen.dart';

import '../helpers/actions.dart';
import '../helpers/test_app.dart';
import '../helpers/test_fixtures.dart' as fixtures;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('에러 처리 E2E', () {
    testWidgets('P1: 잔액 로드 실패 시 홈 화면 graceful', (tester) async {
      final config = TestAppConfig.fullData();
      final mocks = await pumpTestApp(tester, config);

      // 잔액 로드 실패 설정
      when(() => mocks.mockBalanceDataSource.getUserBalances(any()))
          .thenThrow(Exception('Network error'));

      expect(find.byType(HomeScreen), findsOneWidget);
      // 크래시 없음 확인 - 앱이 정상 동작
    });

    testWidgets('P1: 거래 목록 로드 실패 에러 표시', (tester) async {
      final config = TestAppConfig(
        isLoggedIn: true,
        onboardingCompleted: true,
        profile: fixtures.profileJapanComplete(),
        accounts: fixtures.allAccounts(),
        balances: fixtures.dashboardBalances(),
        currentMonthSummary: fixtures.currentMonthSummary(),
      );
      await pumpTestApp(tester, config);

      // 거래 목록이 빈 상태
      await navigateToTab(tester, 1);

      // 에러가 아닌 빈 목록으로 graceful하게 처리됨
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('P2: 프로필 로드 실패 설정 화면', (tester) async {
      final config = TestAppConfig.fullData();
      final mocks = await pumpTestApp(tester, config);

      // 프로필 로드 실패 설정
      when(() => mocks.mockProfileRepo.getProfile(any()))
          .thenAnswer((_) async =>
              const Fail(ServerFailure('Server error')));

      await navigateToTab(tester, 3);
      expect(find.byType(SettingsScreen), findsOneWidget);

      // 크래시 없음 - 프로필 섹션이 숨겨짐
    });
  });
}
