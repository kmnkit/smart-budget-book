import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();
  static final instance = AnalyticsService._();

  final _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logOnboardingComplete({required String country}) async {
    await _analytics.logEvent(
      name: 'onboarding_complete',
      parameters: {'country': country},
    );
  }

  Future<void> logFirstTransaction() async {
    await _analytics.logEvent(name: 'first_transaction');
  }

  Future<void> logTransactionCreated({required String type}) async {
    await _analytics.logEvent(
      name: 'transaction_created',
      parameters: {'type': type},
    );
  }

  Future<void> logPaywallView({String? reason}) async {
    await _analytics.logEvent(
      name: 'paywall_view',
      parameters: {if (reason != null) 'reason': reason},
    );
  }

  Future<void> logSubscriptionStart({required String productId}) async {
    await _analytics.logEvent(
      name: 'subscription_start',
      parameters: {'product_id': productId},
    );
  }

  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}
