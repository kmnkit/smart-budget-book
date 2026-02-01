import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zan/presentation/screens/home/home_screen.dart';
import 'package:zan/presentation/screens/reports/report_screen.dart';
import 'package:zan/presentation/screens/settings/settings_screen.dart';
import 'package:zan/presentation/screens/transactions/transaction_input_screen.dart';
import 'package:zan/presentation/screens/transactions/transaction_list_screen.dart';

import '../helpers/actions.dart';
import '../helpers/finders.dart';
import '../helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('네비게이션 E2E', () {
    testWidgets('P0: 바텀 네비게이션 4탭 전환', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      // 홈 탭 (기본)
      expect(find.byType(HomeScreen), findsOneWidget);

      // 거래 탭
      await navigateToTab(tester, 1);
      expect(find.byType(TransactionListScreen), findsOneWidget);

      // 리포트 탭
      await navigateToTab(tester, 2);
      expect(find.byType(ReportScreen), findsOneWidget);

      // 설정 탭
      await navigateToTab(tester, 3);
      expect(find.byType(SettingsScreen), findsOneWidget);

      // 다시 홈으로
      await navigateToTab(tester, 0);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('P0: FAB → 거래 입력 화면', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await tapFab(tester);
      expect(find.byType(TransactionInputScreen), findsOneWidget);
    });

    testWidgets('P1: FAB 표시 확인', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      expect(findFab(), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
