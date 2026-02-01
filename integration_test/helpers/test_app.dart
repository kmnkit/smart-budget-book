import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zan/app.dart';
import 'package:zan/config/di/account_providers.dart';
import 'package:zan/config/di/auth_providers.dart';
import 'package:zan/config/di/balance_providers.dart';
import 'package:zan/config/di/transaction_providers.dart';
import 'package:zan/config/router/app_router.dart';
import 'package:zan/config/router/route_names.dart';
import 'package:zan/core/errors/failures.dart';
import 'package:zan/core/usecase/result.dart';
import 'package:zan/data/datasources/remote/account_remote_datasource.dart';
import 'package:zan/data/datasources/remote/auth_remote_datasource.dart';
import 'package:zan/data/datasources/remote/balance_remote_datasource.dart';
import 'package:zan/data/datasources/remote/profile_remote_datasource.dart';
import 'package:zan/data/datasources/remote/supabase_providers.dart';
import 'package:zan/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:zan/domain/entities/account.dart';
import 'package:zan/domain/entities/account_balance.dart';
import 'package:zan/domain/entities/monthly_summary.dart';
import 'package:zan/domain/entities/profile.dart';
import 'package:zan/domain/entities/transaction.dart' as domain;
import 'package:zan/domain/repositories/account_repository.dart';
import 'package:zan/domain/repositories/auth_repository.dart';
import 'package:zan/domain/repositories/profile_repository.dart';
import 'package:zan/domain/repositories/transaction_repository.dart';
import 'package:zan/presentation/providers/auth_provider.dart';
import 'package:zan/presentation/providers/settings_provider.dart';
import 'package:zan/presentation/screens/accounts/account_form_screen.dart';
import 'package:zan/presentation/screens/accounts/account_list_screen.dart';
import 'package:zan/presentation/screens/auth/sign_in_screen.dart';
import 'package:zan/presentation/screens/home/home_screen.dart';
import 'package:zan/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:zan/presentation/screens/preset_setup/preset_setup_screen.dart';
import 'package:zan/presentation/screens/reports/report_screen.dart';
import 'package:zan/presentation/screens/settings/settings_screen.dart';
import 'package:zan/presentation/screens/shell/app_shell.dart';
import 'package:zan/presentation/screens/splash/splash_screen.dart';
import 'package:zan/presentation/screens/transactions/transaction_input_screen.dart';
import 'package:zan/presentation/screens/transactions/transaction_list_screen.dart';

import 'mock_data_sources.dart';
import 'test_fixtures.dart' as fixtures;

// ---- Mock Repository Classes ----

class MockAccountRepository extends Mock implements AccountRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAccountRemoteDataSource extends Mock
    implements AccountRemoteDataSource {}

class MockTransactionRemoteDataSource extends Mock
    implements TransactionRemoteDataSource {}

class MockBalanceRemoteDataSource extends Mock
    implements BalanceRemoteDataSource {}

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

// ---- Test Configuration ----

/// 테스트 앱 설정 구성
class TestAppConfig {
  TestAppConfig({
    this.isLoggedIn = true,
    this.onboardingCompleted = true,
    this.profile,
    this.accounts = const [],
    this.allAccounts,
    this.balances = const [],
    this.currentMonthSummary,
    this.previousMonthSummary,
    this.transactions = const [],
    this.categoryBreakdown = const {},
    this.additionalOverrides = const [],
    this.initialLocation,
  });

  final bool isLoggedIn;
  final bool onboardingCompleted;
  final Profile? profile;
  final List<Account> accounts;
  final List<Account>? allAccounts;
  final List<AccountBalance> balances;
  final MonthlySummary? currentMonthSummary;
  final MonthlySummary? previousMonthSummary;
  final List<domain.Transaction> transactions;
  final Map<String, int> categoryBreakdown;
  final List<Override> additionalOverrides;

  /// 시작 경로 오버라이드 (null이면 인증 상태에 따라 자동 결정)
  final String? initialLocation;

  /// 비인증 상태 (로그아웃)
  factory TestAppConfig.loggedOut() => TestAppConfig(
        isLoggedIn: false,
        onboardingCompleted: false,
      );

  /// 인증됨, 온보딩 미완료
  factory TestAppConfig.loggedInNoOnboarding() => TestAppConfig(
        isLoggedIn: true,
        onboardingCompleted: false,
        profile: fixtures.profileOnboardingIncomplete(),
      );

  /// 완전 인증 + 풍부한 데이터
  factory TestAppConfig.fullData() => TestAppConfig(
        isLoggedIn: true,
        onboardingCompleted: true,
        profile: fixtures.profileJapanComplete(),
        accounts: fixtures.allAccounts(),
        allAccounts: fixtures.allAccountsIncludingArchived(),
        balances: fixtures.dashboardBalances(),
        currentMonthSummary: fixtures.currentMonthSummary(),
        previousMonthSummary: fixtures.previousMonthSummary(),
        transactions: fixtures.sampleTransactions(),
        categoryBreakdown: fixtures.categoryBreakdown(),
      );

  /// 인증됨 + 빈 데이터 (계좌 없음)
  factory TestAppConfig.emptyData() => TestAppConfig(
        isLoggedIn: true,
        onboardingCompleted: true,
        profile: fixtures.profileJapanComplete(),
      );
}

// ---- Mock Holders ----

class TestMocks {
  final mockAuth = MockGoTrueClient();
  final mockSupabaseClient = MockSupabaseClient();
  final mockAccountRepo = MockAccountRepository();
  final mockTransactionRepo = MockTransactionRepository();
  final mockProfileRepo = MockProfileRepository();
  final mockAuthRepo = MockAuthRepository();
  final mockBalanceDataSource = MockBalanceRemoteDataSource();

  void dispose() {
    mockAuth.dispose();
  }
}

// ---- Fallback Values ----

bool _fallbacksRegistered = false;

void _registerFallbackValues() {
  if (_fallbacksRegistered) return;
  _fallbacksRegistered = true;

  registerFallbackValue(fixtures.profileJapanComplete());
  registerFallbackValue(fixtures.cashAccount());
  registerFallbackValue(<Account>[]);
  registerFallbackValue(fixtures.todayExpense());
}

// ---- Test App Builder ----

/// 테스트용 앱을 pump하는 헬퍼
///
/// `main.dart`의 `Supabase.initialize()` + `dotenv.load()`를 우회하고
/// 모든 Provider를 Mock으로 오버라이드합니다.
///
/// 핵심: GlobalKey 충돌 방지를 위해 appRouterProvider를 매 테스트마다
/// 새 GoRouter 인스턴스로 오버라이드합니다.
Future<TestMocks> pumpTestApp(
  WidgetTester tester,
  TestAppConfig config,
) async {
  _registerFallbackValues();

  final mocks = TestMocks();
  _configureMocks(mocks, config);

  final overrides = _buildOverrides(mocks, config);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [...overrides, ...config.additionalOverrides],
      child: const ZanApp(),
    ),
  );

  // CircularProgressIndicator 등 무한 애니메이션 때문에 pumpAndSettle 사용 불가.
  // 대신 충분한 시간을 pump하여 스플래시 딜레이(500ms) + 네비게이션을 처리.
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 300));

  return mocks;
}

// ---- Internal Helpers ----

/// 인증 상태에 따라 적절한 시작 경로를 결정
String _resolveInitialLocation(TestAppConfig config) {
  if (config.initialLocation != null) return config.initialLocation!;
  // splash를 건너뛰고 직접 목적지로 이동
  if (!config.isLoggedIn) return RoutePaths.signIn;
  if (!config.onboardingCompleted) return RoutePaths.onboarding;
  return RoutePaths.home;
}

/// 매 테스트마다 새 GlobalKey로 GoRouter를 생성하여 키 충돌 방지
GoRouter _createTestRouter(TestAppConfig config) {
  final rootKey = GlobalKey<NavigatorState>();
  final shellKey = GlobalKey<NavigatorState>();
  final initialLocation = _resolveInitialLocation(config);

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.signIn,
        name: RouteNames.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: shellKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            name: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RoutePaths.transactions,
            name: RouteNames.transactions,
            builder: (context, state) => const TransactionListScreen(),
          ),
          GoRoute(
            path: RoutePaths.reports,
            name: RouteNames.reports,
            builder: (context, state) => const ReportScreen(),
          ),
          GoRoute(
            path: RoutePaths.settings,
            name: RouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.transactionInput,
        name: RouteNames.transactionInput,
        builder: (context, state) {
          final transactionId = state.uri.queryParameters['id'];
          return TransactionInputScreen(transactionId: transactionId);
        },
      ),
      GoRoute(
        path: RoutePaths.accountList,
        name: RouteNames.accountList,
        builder: (context, state) => const AccountListScreen(),
      ),
      GoRoute(
        path: RoutePaths.accountForm,
        name: RouteNames.accountForm,
        builder: (context, state) {
          final accountId = state.uri.queryParameters['id'];
          return AccountFormScreen(accountId: accountId);
        },
      ),
      GoRoute(
        path: RoutePaths.presetSetup,
        name: RouteNames.presetSetup,
        builder: (context, state) => const PresetSetupScreen(),
      ),
    ],
  );
}

void _configureMocks(TestMocks mocks, TestAppConfig config) {
  // Auth
  if (config.isLoggedIn) {
    setupLoggedInMocks(mocks.mockAuth);
  } else {
    setupLoggedOutMocks(mocks.mockAuth);
  }

  // Profile
  final profile = config.profile ??
      (config.onboardingCompleted
          ? fixtures.profileJapanComplete()
          : fixtures.profileOnboardingIncomplete());

  when(() => mocks.mockProfileRepo.getProfile(any()))
      .thenAnswer((_) async => Success(profile));
  when(() => mocks.mockProfileRepo.updateProfile(any()))
      .thenAnswer((_) async => const Success(null));
  when(() => mocks.mockProfileRepo.completeOnboarding(
        userId: any(named: 'userId'),
        country: any(named: 'country'),
        currency: any(named: 'currency'),
      )).thenAnswer((_) async => const Success(null));

  // Accounts
  when(() => mocks.mockAccountRepo.getAccounts(any()))
      .thenAnswer((_) async => Success(config.accounts));
  when(() => mocks.mockAccountRepo.getAllAccounts(any()))
      .thenAnswer(
          (_) async => Success(config.allAccounts ?? config.accounts));
  when(() => mocks.mockAccountRepo.getAccount(any())).thenAnswer((inv) async {
    final id = inv.positionalArguments[0] as String;
    final match = config.accounts.where((a) => a.id == id).firstOrNull;
    if (match != null) {
      return Success(match);
    }
    return const Fail(NotFoundFailure('Account not found'));
  });
  when(() => mocks.mockAccountRepo.createAccount(any())).thenAnswer(
      (_) async =>
          Success(config.accounts.firstOrNull ?? fixtures.cashAccount()));
  when(() => mocks.mockAccountRepo.createAccounts(any()))
      .thenAnswer((_) async => const Success(null));
  when(() => mocks.mockAccountRepo.updateAccount(any())).thenAnswer(
      (_) async =>
          Success(config.accounts.firstOrNull ?? fixtures.cashAccount()));
  when(() => mocks.mockAccountRepo.archiveAccount(any()))
      .thenAnswer((_) async => const Success(null));

  // Transactions
  when(() => mocks.mockTransactionRepo.getTransactions(
        userId: any(named: 'userId'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        accountId: any(named: 'accountId'),
        searchQuery: any(named: 'searchQuery'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => Success(config.transactions));
  when(() => mocks.mockTransactionRepo.getRecentTransactions(
        any(),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => Success(config.transactions));
  when(() => mocks.mockTransactionRepo.getTransaction(any()))
      .thenAnswer((inv) async {
    final id = inv.positionalArguments[0] as String;
    final match = config.transactions.where((t) => t.id == id).firstOrNull;
    if (match != null) {
      return Success(match);
    }
    return const Fail(NotFoundFailure('Transaction not found'));
  });
  when(() => mocks.mockTransactionRepo.createTransaction(any()))
      .thenAnswer((_) async => Success(fixtures.todayExpense()));
  when(() => mocks.mockTransactionRepo.updateTransaction(any()))
      .thenAnswer((_) async => Success(fixtures.todayExpense()));

  // Balances
  when(() => mocks.mockBalanceDataSource.getUserBalances(any()))
      .thenAnswer((_) async => config.balances);
  when(() => mocks.mockBalanceDataSource.getMonthlySummary(
        userId: any(named: 'userId'),
        year: any(named: 'year'),
        month: any(named: 'month'),
      )).thenAnswer(
      (_) async => config.currentMonthSummary ?? fixtures.emptySummary());

  // Auth repository
  when(() => mocks.mockAuthRepo.signInWithGoogle())
      .thenAnswer((_) async => const Success(null));
  when(() => mocks.mockAuthRepo.signInWithApple())
      .thenAnswer((_) async => const Success(null));
  when(() => mocks.mockAuthRepo.signOut())
      .thenAnswer((_) async => const Success(null));
  when(() => mocks.mockAuthRepo.deleteAccount())
      .thenAnswer((_) async => const Success(null));
}

List<Override> _buildOverrides(TestMocks mocks, TestAppConfig config) {
  final authStream = config.isLoggedIn
      ? Stream.value(AuthState(AuthChangeEvent.signedIn, FakeSession()))
      : Stream.value(const AuthState(AuthChangeEvent.signedOut, null));

  final testRouter = _createTestRouter(config);

  return [
    // Router (새 GlobalKey로 충돌 방지)
    appRouterProvider.overrideWithValue(testRouter),

    // Supabase providers (lowest level)
    supabaseClientProvider.overrideWithValue(mocks.mockSupabaseClient),
    supabaseAuthProvider.overrideWithValue(mocks.mockAuth),

    // Auth state providers
    authStateProvider.overrideWith((ref) => authStream),
    currentUserProvider
        .overrideWith((ref) => config.isLoggedIn ? FakeUser() : null),
    currentUserIdProvider
        .overrideWith((ref) => config.isLoggedIn ? fixtures.testUserId : null),

    // Profile provider (splash screen에서 사용)
    userProfileProvider.overrideWith((ref) async {
      if (!config.isLoggedIn) return null;
      return config.profile ??
          (config.onboardingCompleted
              ? fixtures.profileJapanComplete()
              : fixtures.profileOnboardingIncomplete());
    }),

    // Repository providers
    accountRepositoryProvider.overrideWithValue(mocks.mockAccountRepo),
    transactionRepositoryProvider
        .overrideWithValue(mocks.mockTransactionRepo),
    profileRepositoryProvider.overrideWithValue(mocks.mockProfileRepo),
    authRepositoryProvider.overrideWithValue(mocks.mockAuthRepo),

    // Data source providers
    balanceRemoteDataSourceProvider
        .overrideWithValue(mocks.mockBalanceDataSource),
  ];
}
