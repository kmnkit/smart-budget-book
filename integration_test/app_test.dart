/// Zan E2E 테스트 메인 진입점
///
/// 모든 E2E 테스트 플로우를 그룹핑합니다.
/// 개별 플로우는 `flows/` 디렉토리에서 독립 실행 가능합니다.
///
/// 전체 실행: `flutter test integration_test/`
/// 개별 실행: `flutter test integration_test/flows/auth_onboarding_e2e_test.dart`
library;

import 'package:integration_test/integration_test.dart';

import 'flows/auth_onboarding_e2e_test.dart' as auth_onboarding;
import 'flows/navigation_e2e_test.dart' as navigation;
import 'flows/home_dashboard_e2e_test.dart' as home_dashboard;
import 'flows/transaction_management_e2e_test.dart' as transaction_management;
import 'flows/account_management_e2e_test.dart' as account_management;
import 'flows/preset_setup_e2e_test.dart' as preset_setup;
import 'flows/report_e2e_test.dart' as report;
import 'flows/settings_e2e_test.dart' as settings;
import 'flows/error_handling_e2e_test.dart' as error_handling;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  navigation.main();
  auth_onboarding.main();
  home_dashboard.main();
  transaction_management.main();
  account_management.main();
  preset_setup.main();
  report.main();
  settings.main();
  error_handling.main();
}
