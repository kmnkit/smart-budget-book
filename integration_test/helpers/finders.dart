import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// ValueKey 기반 위젯 검색
Finder findByKey(String key) => find.byKey(ValueKey(key));

/// 특정 타입의 상위 위젯 내부에서 텍스트 검색
Finder findDescendantText(Type ancestorType, String text) {
  return find.descendant(
    of: find.byType(ancestorType),
    matching: find.text(text),
  );
}

/// 바텀 네비게이션 바에서 특정 인덱스의 탭 찾기
Finder findNavigationDestination(int index) {
  return find.byType(NavigationDestination).at(index);
}

/// 숫자 키패드의 버튼 찾기
Finder findKeypadButton(String label) {
  return find.widgetWithText(TextButton, label);
}

/// FloatingActionButton 찾기
Finder findFab() => find.byType(FloatingActionButton);

/// SnackBar 텍스트 찾기
Finder findSnackBarText(String text) {
  return find.descendant(
    of: find.byType(SnackBar),
    matching: find.text(text),
  );
}

/// AlertDialog 찾기
Finder findAlertDialog() => find.byType(AlertDialog);

/// CircularProgressIndicator 찾기
Finder findLoading() => find.byType(CircularProgressIndicator);

/// SegmentedButton 찾기
Finder findSegmentedButton() => find.byType(SegmentedButton);

/// TabBar 찾기
Finder findTabBar() => find.byType(TabBar);

/// Tab 찾기 (텍스트 기반)
Finder findTabByText(String text) {
  return find.descendant(
    of: find.byType(TabBar),
    matching: find.text(text),
  );
}
