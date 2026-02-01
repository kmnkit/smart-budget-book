import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zan/core/utils/currency_formatter.dart';
import 'package:zan/presentation/screens/reports/report_screen.dart';

import '../helpers/actions.dart';
import '../helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('리포트 E2E', () {
    testWidgets('P1: 월간 리포트 기본 화면', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await navigateToTab(tester, 2);
      expect(find.byType(ReportScreen), findsOneWidget);

      // 수입/지출 표시
      expect(
        find.text(CurrencyFormatter.format(300000)),
        findsWidgets,
      );
      expect(
        find.text(CurrencyFormatter.format(150000)),
        findsWidgets,
      );
    });

    testWidgets('P1: 이전/다음 월 이동', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await navigateToTab(tester, 2);

      // 현재 월 표시
      final now = DateTime.now();
      final monthStr =
          '${now.year}/${now.month.toString().padLeft(2, '0')}';
      expect(find.text(monthStr), findsOneWidget);

      // 이전 월 chevron 탭
      await tester.tap(find.byIcon(Icons.chevron_left));
      await pumpAndWait(tester);

      // 이전 월로 변경
      final prevMonth = DateTime(now.year, now.month - 1);
      final prevMonthStr =
          '${prevMonth.year}/${prevMonth.month.toString().padLeft(2, '0')}';
      expect(find.text(prevMonthStr), findsOneWidget);

      // 다음 월 chevron 탭 (원래로 복귀)
      await tester.tap(find.byIcon(Icons.chevron_right));
      await pumpAndWait(tester);

      expect(find.text(monthStr), findsOneWidget);
    });

    testWidgets('P2: 빈 데이터 리포트 화면', (tester) async {
      await pumpTestApp(tester, TestAppConfig.emptyData());

      await navigateToTab(tester, 2);
      expect(find.byType(ReportScreen), findsOneWidget);

      // 0원 표시
      expect(find.text(CurrencyFormatter.format(0)), findsWidgets);
    });
  });
}
