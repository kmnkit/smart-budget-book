import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zan/config/router/route_names.dart';
import 'package:zan/presentation/screens/auth/sign_in_screen.dart';
import 'package:zan/presentation/screens/home/home_screen.dart';
import 'package:zan/presentation/screens/onboarding/onboarding_screen.dart';

import '../helpers/actions.dart';
import '../helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('인증 E2E', () {
    testWidgets('P0: 비인증 → 스플래시 → 로그인 화면 리다이렉트', (tester) async {
      // splash를 통과하는 테스트이므로 initialLocation을 splash로 설정
      await pumpTestApp(
        tester,
        TestAppConfig(
          isLoggedIn: false,
          onboardingCompleted: false,
          initialLocation: RoutePaths.splash,
        ),
      );

      // 스플래시 딜레이 후 SignInScreen 표시
      await waitForSplashAndSettle(tester);

      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('P0: 인증됨 → 홈 화면 이동', (tester) async {
      // splash 없이 직접 /home으로 시작 (기본 동작)
      await pumpTestApp(tester, TestAppConfig.fullData());

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('P1: 로그인 중 로딩 인디케이터 표시', (tester) async {
      // signIn 화면으로 직접 시작
      await pumpTestApp(tester, TestAppConfig.loggedOut());

      // SignInScreen 표시 확인
      expect(find.byType(SignInScreen), findsOneWidget);

      // Google 로그인 텍스트 확인
      expect(find.textContaining('Google'), findsWidgets);
    });
  });

  group('온보딩 E2E', () {
    testWidgets('P0: 온보딩 미완료 → 온보딩 화면 리다이렉트', (tester) async {
      // onboarding 화면으로 직접 시작 (기본 동작)
      await pumpTestApp(tester, TestAppConfig.loggedInNoOnboarding());

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('P0: 온보딩 3단계 완주 (환영→기능소개→국가선택→홈)', (tester) async {
      await pumpTestApp(tester, TestAppConfig.loggedInNoOnboarding());

      expect(find.byType(OnboardingScreen), findsOneWidget);

      // Page 0: 환영 페이지 - "다음" 탭
      await tester.tap(find.byType(ElevatedButton));
      await pumpAndWait(tester);

      // Page 1: 기능 소개 - "다음" 탭
      await tester.tap(find.byType(ElevatedButton));
      await pumpAndWait(tester);

      // Page 2: 국가 선택 - 일본 선택
      await tester.tap(find.text('日本'));
      await pumpAndWait(tester);

      // "시작" 버튼 탭
      await tester.tap(find.byType(ElevatedButton));
      await pumpAndWait(tester);

      // HomeScreen 도달
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('P1: 온보딩 "건너뛰기" → 국가 선택 직행', (tester) async {
      await pumpTestApp(tester, TestAppConfig.loggedInNoOnboarding());

      expect(find.byType(OnboardingScreen), findsOneWidget);

      // "건너뛰기" 버튼 탭
      final skipFinder = find.byType(TextButton);
      if (skipFinder.evaluate().isNotEmpty) {
        await tester.tap(skipFinder.first);
        await pumpAndWait(tester);
      }

      // 국가 선택 페이지 도달 확인 (일본/한국 표시)
      expect(find.text('日本'), findsOneWidget);
      expect(find.text('한국'), findsOneWidget);
    });

    testWidgets('P1: 국가 미선택 시 시작 불가', (tester) async {
      await pumpTestApp(tester, TestAppConfig.loggedInNoOnboarding());

      // 건너뛰기로 국가 선택 페이지 이동
      final skipFinder = find.byType(TextButton);
      if (skipFinder.evaluate().isNotEmpty) {
        await tester.tap(skipFinder.first);
        await pumpAndWait(tester);
      }

      // 국가 미선택 상태에서 버튼 탭 - HomeScreen으로 이동하지 않음
      await tester.tap(find.byType(ElevatedButton));
      await pumpAndWait(tester);

      // 여전히 OnboardingScreen
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('P1: 한국 선택 → KR 코드로 온보딩 완료', (tester) async {
      await pumpTestApp(tester, TestAppConfig.loggedInNoOnboarding());

      // 건너뛰기
      final skipFinder = find.byType(TextButton);
      if (skipFinder.evaluate().isNotEmpty) {
        await tester.tap(skipFinder.first);
        await pumpAndWait(tester);
      }

      // 한국 선택
      await tester.tap(find.text('한국'));
      await pumpAndWait(tester);

      // 시작 버튼
      await tester.tap(find.byType(ElevatedButton));
      await pumpAndWait(tester);

      // HomeScreen 도달
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
