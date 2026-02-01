import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zan/core/utils/currency_formatter.dart';
import 'package:zan/presentation/screens/accounts/account_form_screen.dart';
import 'package:zan/presentation/screens/home/home_screen.dart';
import 'package:zan/presentation/screens/preset_setup/preset_setup_screen.dart';

import '../helpers/actions.dart';
import '../helpers/finders.dart';
import '../helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('홈 대시보드 E2E', () {
    testWidgets('P0: 데이터 있는 홈 화면 렌더링', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      expect(find.byType(HomeScreen), findsOneWidget);

      // 순자산 표시 (510000 - 30000 = 480000)
      expect(
        find.text(CurrencyFormatter.format(480000)),
        findsOneWidget,
      );

      // 월간 수입/지출 표시
      expect(
        find.text(CurrencyFormatter.format(300000)),
        findsWidgets,
      );
      expect(
        find.text(CurrencyFormatter.format(150000)),
        findsWidgets,
      );

      // 계좌 잔액 목록
      expect(find.text('現金'), findsOneWidget);
      expect(find.text('銀行口座'), findsOneWidget);
      expect(find.text('クレジットカード'), findsOneWidget);
    });

    testWidgets('P0: 빈 상태 홈 화면 (계좌 없음)', (tester) async {
      await pumpTestApp(tester, TestAppConfig.emptyData());

      // async provider 해결 대기
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(HomeScreen), findsOneWidget);

      // 빈 상태 아이콘
      expect(
        find.byIcon(Icons.account_balance_wallet_outlined),
        findsOneWidget,
      );
    });

    testWidgets('P0: 빈 상태 → 프리셋 설정 이동', (tester) async {
      await pumpTestApp(tester, TestAppConfig.emptyData());

      // async provider 해결 대기
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));

      // "프리셋 설정" 버튼 탭 (playlist_add 아이콘이 포함된 버튼)
      final presetButton = find.byIcon(Icons.playlist_add);
      expect(presetButton, findsOneWidget);
      await tester.tap(presetButton);
      await pumpAndWait(tester);

      expect(find.byType(PresetSetupScreen), findsOneWidget);
    });

    testWidgets('P0: 빈 상태 → 계좌 추가 이동', (tester) async {
      await pumpTestApp(tester, TestAppConfig.emptyData());

      // async provider 해결 대기
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));

      // "직접 추가" 버튼 탭
      final manualButton = find.byType(TextButton).last;
      await tester.tap(manualButton);
      await pumpAndWait(tester);

      expect(find.byType(AccountFormScreen), findsOneWidget);
    });

    testWidgets('P1: 순자산 계산 정확성 (자산-부채)', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      // 자산: 10000 + 500000 = 510000
      // 부채: 30000
      // 순자산: 480000
      expect(
        find.text(CurrencyFormatter.format(480000)),
        findsOneWidget,
      );
    });

    testWidgets('P2: FAB 표시 확인', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      expect(findFab(), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
