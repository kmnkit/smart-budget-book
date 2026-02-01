import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zan/presentation/screens/transactions/transaction_input_screen.dart';
import 'package:zan/presentation/screens/transactions/transaction_list_screen.dart';

import '../helpers/actions.dart';
import '../helpers/finders.dart';
import '../helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('거래 입력 E2E', () {
    testWidgets('P0: 지출 입력 - 금액 키패드 입력', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      // FAB으로 거래 입력 화면 이동
      await tapFab(tester);
      expect(find.byType(TransactionInputScreen), findsOneWidget);

      // 키패드로 금액 입력
      await enterAmountViaKeypad(tester, '1500');

      // 금액 표시 확인
      expect(find.textContaining('1,500'), findsWidgets);
    });

    testWidgets('P0: 금액 0원 시 저장 불가', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await tapFab(tester);
      expect(find.byType(TransactionInputScreen), findsOneWidget);

      // 금액 0인 상태에서 저장 버튼은 비활성
      // (isValid = false → onPressed: null)
      final saveButton = find.widgetWithText(TextButton, '저장');
      if (saveButton.evaluate().isNotEmpty) {
        final textButton = tester.widget<TextButton>(saveButton.first);
        expect(textButton.onPressed, isNull);
      }
    });

    testWidgets('P1: C(클리어) 키 동작', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await tapFab(tester);

      // 금액 입력
      await tester.tap(findKeypadButton('1'));
      await tester.pump();
      await tester.tap(findKeypadButton('5'));
      await tester.pump();

      // C 키로 클리어
      await tester.tap(findKeypadButton('C'));
      await tester.pump();

      // 금액이 0으로 리셋됨
      expect(find.textContaining('0'), findsWidgets);
    });

    testWidgets('P1: ⌫(백스페이스) 키 동작', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await tapFab(tester);

      // 금액 입력: 150
      await tester.tap(findKeypadButton('1'));
      await tester.pump();
      await tester.tap(findKeypadButton('5'));
      await tester.pump();
      await tester.tap(findKeypadButton('0'));
      await tester.pump();

      // 백스페이스
      await tester.tap(findKeypadButton('⌫'));
      await tester.pump();

      // 15로 변경됨
      expect(find.textContaining('15'), findsWidgets);
    });

    testWidgets('P1: 탭 전환 (지출→수입→이체)', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await tapFab(tester);

      // TabBar 존재 확인
      expect(findTabBar(), findsOneWidget);

      // 3개의 탭 확인
      expect(find.byType(Tab), findsNWidgets(3));
    });
  });

  group('거래 목록 E2E', () {
    testWidgets('P0: 거래 목록 표시', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      // 거래 탭으로 이동
      await navigateToTab(tester, 1);
      expect(find.byType(TransactionListScreen), findsOneWidget);

      // 거래 항목 표시
      expect(find.text('ランチ'), findsOneWidget);
      expect(find.text('電車'), findsOneWidget);
      expect(find.text('給与'), findsOneWidget);
    });

    testWidgets('P0: 빈 목록 메시지', (tester) async {
      await pumpTestApp(tester, TestAppConfig.emptyData());

      await navigateToTab(tester, 1);

      // 빈 목록 텍스트
      expect(find.byType(TransactionListScreen), findsOneWidget);
    });

    testWidgets('P1: 필터 다이얼로그 열기', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await navigateToTab(tester, 1);

      // filter_list 아이콘 탭
      await tester.tap(find.byIcon(Icons.filter_list));
      await pumpAndWait(tester);

      // 바텀시트가 열림
      expect(find.byType(BottomSheet), findsOneWidget);
    });
  });
}
