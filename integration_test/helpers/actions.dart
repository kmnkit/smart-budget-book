import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'finders.dart';

/// pumpAndSettle 대신 사용하는 헬퍼.
/// CircularProgressIndicator 등 무한 애니메이션이 있어서
/// pumpAndSettle은 타임아웃됩니다.
Future<void> pumpAndWait(WidgetTester tester, [Duration? extra]) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 300));
  if (extra != null) {
    await tester.pump(extra);
  }
}

/// 바텀 네비게이션 탭 전환
Future<void> navigateToTab(WidgetTester tester, int index) async {
  await tester.tap(findNavigationDestination(index));
  await pumpAndWait(tester);
}

/// FAB 탭
Future<void> tapFab(WidgetTester tester) async {
  await tester.tap(findFab());
  await pumpAndWait(tester);
}

/// 키패드로 금액 입력
Future<void> enterAmountViaKeypad(WidgetTester tester, String amount) async {
  // 먼저 C를 눌러 초기화
  await tester.tap(findKeypadButton('C'));
  await tester.pump();

  // 각 자릿수를 순서대로 입력
  for (final digit in amount.split('')) {
    await tester.tap(findKeypadButton(digit));
    await tester.pump();
  }
}

/// 특정 텍스트를 가진 버튼 탭
Future<void> tapButtonWithText(WidgetTester tester, String text) async {
  final finder = find.widgetWithText(ElevatedButton, text);
  if (finder.evaluate().isNotEmpty) {
    await tester.tap(finder);
  } else {
    // TextButton이나 OutlinedButton도 시도
    final textBtnFinder = find.widgetWithText(TextButton, text);
    if (textBtnFinder.evaluate().isNotEmpty) {
      await tester.tap(textBtnFinder);
    } else {
      await tester.tap(find.widgetWithText(OutlinedButton, text));
    }
  }
  await pumpAndWait(tester);
}

/// 특정 텍스트를 가진 ListTile 탭
Future<void> tapListTileWithText(WidgetTester tester, String text) async {
  await tester.tap(find.widgetWithText(ListTile, text));
  await pumpAndWait(tester);
}

/// AlertDialog에서 특정 버튼 탭
Future<void> tapDialogButton(WidgetTester tester, String text) async {
  await tester.tap(find.descendant(
    of: findAlertDialog(),
    matching: find.text(text),
  ));
  await pumpAndWait(tester);
}

/// TextField에 텍스트 입력 (labelText 기반)
Future<void> enterTextField(
  WidgetTester tester,
  String labelOrHint,
  String text,
) async {
  final field = find.widgetWithText(TextFormField, labelOrHint);
  if (field.evaluate().isNotEmpty) {
    await tester.enterText(field, text);
  } else {
    final field2 = find.widgetWithText(TextField, labelOrHint);
    await tester.enterText(field2, text);
  }
  await tester.pump();
}

/// 텍스트가 화면에 표시되는지 확인
void expectTextVisible(String text) {
  expect(find.text(text), findsWidgets);
}

/// 위젯 타입이 화면에 표시되는지 확인
void expectWidgetVisible(Type widgetType) {
  expect(find.byType(widgetType), findsWidgets);
}

/// 스플래시 화면 대기 후 라우팅 완료 대기
///
/// splash 경로(/)에서 시작하는 테스트 전용.
/// splash_screen.dart의 _checkAuth()에서 500ms delay 후 라우팅.
/// pumpTestApp에서 이미 1000ms를 pump하므로, 추가로 pump하여
/// GoRouter 네비게이션 + 렌더링을 완료.
Future<void> waitForSplashAndSettle(WidgetTester tester) async {
  // 여러 프레임에 걸쳐 충분히 pump
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  // GoRouter 네비게이션 완료 대기
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 300));
}

/// PageView에서 스와이프
Future<void> swipePageLeft(WidgetTester tester) async {
  await tester.drag(find.byType(PageView), const Offset(-400, 0));
  await pumpAndWait(tester);
}

/// PageView에서 오른쪽으로 스와이프
Future<void> swipePageRight(WidgetTester tester) async {
  await tester.drag(find.byType(PageView), const Offset(400, 0));
  await pumpAndWait(tester);
}
