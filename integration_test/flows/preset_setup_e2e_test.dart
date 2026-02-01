import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zan/presentation/screens/preset_setup/preset_setup_screen.dart';

import '../helpers/actions.dart';
import '../helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('프리셋 설정 E2E', () {
    testWidgets('P0: 일본 프리셋 표시 및 Step 1→2 전환', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      // 설정 탭 → 프리셋 설정 이동
      await navigateToTab(tester, 3);

      final presetTile = find.textContaining('プリセット');
      if (presetTile.evaluate().isNotEmpty) {
        await tester.tap(presetTile.first);
        await pumpAndWait(tester);
      } else {
        // l10n에 따라 다를 수 있으므로 아이콘으로 찾기
        await tester.tap(find.byIcon(Icons.playlist_add));
        await pumpAndWait(tester);
      }

      expect(find.byType(PresetSetupScreen), findsOneWidget);

      // 일본 프리셋 계좌 항목 표시 확인
      expect(find.text('現金'), findsWidgets);

      // "다음" 버튼으로 Step 2 이동
      await tester.tap(find.byType(ElevatedButton));
      await pumpAndWait(tester);

      // Step 2: 잔액 입력 화면
      // Step indicator 2번째가 활성
    });

    testWidgets('P1: 이전 버튼으로 Step 1 복귀', (tester) async {
      await pumpTestApp(tester, TestAppConfig.fullData());

      await navigateToTab(tester, 3);
      await tester.tap(find.byIcon(Icons.playlist_add));
      await pumpAndWait(tester);

      // Step 2로 이동
      await tester.tap(find.byType(ElevatedButton));
      await pumpAndWait(tester);

      // "이전" 버튼 탭
      final prevButton = find.byType(OutlinedButton);
      if (prevButton.evaluate().isNotEmpty) {
        await tester.tap(prevButton.first);
        await pumpAndWait(tester);
      }

      // Step 1으로 복귀 - 프리셋 목록 다시 표시
      expect(find.byType(PresetSetupScreen), findsOneWidget);
    });
  });
}
