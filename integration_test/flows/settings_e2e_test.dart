import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zan/presentation/screens/accounts/account_list_screen.dart';
import 'package:zan/presentation/screens/preset_setup/preset_setup_screen.dart';
import 'package:zan/presentation/screens/settings/settings_screen.dart';

import '../helpers/actions.dart';
import '../helpers/finders.dart';
import '../helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('설정 E2E', () {
    testWidgets('P0: 로그아웃 - 확인 다이얼로그 취소', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await navigateToTab(tester, 3);
      expect(find.byType(SettingsScreen), findsOneWidget);

      // 로그아웃 ListTile 탭
      await tester.tap(find.byIcon(Icons.logout));
      await pumpAndWait(tester);

      // AlertDialog 표시
      expect(findAlertDialog(), findsOneWidget);

      // 취소 버튼 탭
      final cancelButtons = find.descendant(
        of: findAlertDialog(),
        matching: find.byType(TextButton),
      );
      await tester.tap(cancelButtons.first);
      await pumpAndWait(tester);

      // 여전히 설정 화면
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('P0: 계정 삭제 - 다이얼로그 표시', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await navigateToTab(tester, 3);

      // 계정 삭제 ListTile 탭
      await tester.tap(find.byIcon(Icons.delete_forever));
      await pumpAndWait(tester);

      // AlertDialog 표시
      expect(findAlertDialog(), findsOneWidget);
    });

    testWidgets('P1: 계좌 관리 네비게이션', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await navigateToTab(tester, 3);

      // 계좌 관리 아이콘 찾아서 탭
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await pumpAndWait(tester);

      expect(find.byType(AccountListScreen), findsOneWidget);
    });

    testWidgets('P1: 프리셋 설정 네비게이션', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await navigateToTab(tester, 3);

      // 프리셋 설정 아이콘 탭
      await tester.tap(find.byIcon(Icons.playlist_add));
      await pumpAndWait(tester);

      expect(find.byType(PresetSetupScreen), findsOneWidget);
    });

    testWidgets('P1: 프로필 정보 표시', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await navigateToTab(tester, 3);

      // 프로필 이름 표시
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('P1: 테마 변경 SegmentedButton 표시', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await navigateToTab(tester, 3);

      // SegmentedButton 존재 확인
      expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
    });
  });
}
