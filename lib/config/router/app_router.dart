import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/config/router/route_names.dart';
import 'package:zan/presentation/providers/auth_provider.dart';
import 'package:zan/presentation/screens/auth/sign_in_screen.dart';
import 'package:zan/presentation/screens/home/home_screen.dart';
import 'package:zan/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:zan/presentation/screens/reports/report_screen.dart';
import 'package:zan/presentation/screens/settings/settings_screen.dart';
import 'package:zan/presentation/screens/shell/app_shell.dart';
import 'package:zan/presentation/screens/splash/splash_screen.dart';
import 'package:zan/presentation/screens/transactions/transaction_input_screen.dart';
import 'package:zan/presentation/screens/transactions/transaction_list_screen.dart';
import 'package:zan/presentation/screens/accounts/account_list_screen.dart';
import 'package:zan/presentation/screens/accounts/account_form_screen.dart';
import 'package:zan/presentation/screens/preset_setup/preset_setup_screen.dart';
import 'package:zan/presentation/screens/subscription/subscription_screen.dart';
import 'package:zan/presentation/screens/subscription/subscription_management_screen.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.session != null;
      final isOnSplash = state.matchedLocation == RoutePaths.splash;
      final isOnAuth = state.matchedLocation == RoutePaths.signIn;

      if (isOnSplash) return null;

      if (!isLoggedIn) {
        return isOnAuth ? null : RoutePaths.signIn;
      }

      if (isOnAuth) {
        return RoutePaths.home;
      }

      return null;
    },
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
        navigatorKey: _shellNavigatorKey,
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
      GoRoute(
        path: RoutePaths.subscription,
        name: RouteNames.subscription,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: RoutePaths.subscriptionManagement,
        name: RouteNames.subscriptionManagement,
        builder: (context, state) => const SubscriptionManagementScreen(),
      ),
    ],
  );
}
