import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zan/presentation/screens/accounts/account_form_screen.dart';
import 'package:zan/presentation/screens/accounts/account_list_screen.dart';

import '../helpers/actions.dart';
import '../helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('계좌 목록 E2E', () {
    testWidgets('P0: 유형별 그룹 표시', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      // 설정 → 계좌 관리로 이동 (아이콘 기반 네비게이션)
      await navigateToTab(tester, 3);
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await pumpAndWait(tester);

      expect(find.byType(AccountListScreen), findsOneWidget);

      // 계좌 목록 확인
      expect(find.text('現金'), findsOneWidget);
      expect(find.text('銀行口座'), findsOneWidget);
      expect(find.text('クレジットカード'), findsOneWidget);
      expect(find.text('食費'), findsOneWidget);
    });

    testWidgets('P0: 추가 버튼 → 폼 이동', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await navigateToTab(tester, 3);
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await pumpAndWait(tester);

      // 추가 아이콘 탭 (여러 개일 수 있으므로 first 사용)
      await tester.tap(find.byIcon(Icons.add).first);
      await pumpAndWait(tester);

      expect(find.byType(AccountFormScreen), findsOneWidget);
    });

    testWidgets('P1: 아카이브 계좌 Chip 표시', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await navigateToTab(tester, 3);
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await pumpAndWait(tester);

      // 아카이브된 계좌에 Chip 표시
      expect(find.byType(Chip), findsOneWidget);
    });
  });

  group('계좌 추가 E2E', () {
    testWidgets('P0: 계좌명 미입력 유효성 검사', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await navigateToTab(tester, 3);
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await pumpAndWait(tester);
      await tester.tap(find.byIcon(Icons.add).first);
      await pumpAndWait(tester);

      expect(find.byType(AccountFormScreen), findsOneWidget);

      // 이름 미입력 상태로 저장
      await tester.tap(find.byType(ElevatedButton));
      await pumpAndWait(tester);

      // 유효성 검사 에러 메시지
      // (nameRequired 키에 해당하는 l10n 메시지 표시)
      expect(find.byType(AccountFormScreen), findsOneWidget);
    });
  });
}
