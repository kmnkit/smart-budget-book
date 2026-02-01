import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:zan/core/services/crashlytics_service.dart';

/// 백그라운드 메시지 핸들러 — 반드시 top-level 함수여야 함
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // background isolate에서 Firebase.initializeApp()이 자동 호출됨
}

class MessagingService {
  MessagingService._();
  static final instance = MessagingService._();

  final _messaging = FirebaseMessaging.instance;
  final _logger = Logger();
  String? _currentToken;

  String? get currentToken => _currentToken;

  Future<void> initialize() async {
    try {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      final settings = await _requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _logger.w('FCM: 알림 권한이 거부됨');
        return;
      }

      await _getAndStoreToken();
      _setupTokenRefreshListener();
      _setupForegroundMessageHandler();
      _setupMessageOpenedAppHandler();
      await _handleInitialMessage();

      _logger.i('FCM: 초기화 완료');
    } catch (e, stack) {
      _logger.e('FCM: 초기화 실패', error: e, stackTrace: stack);
      try {
        await CrashlyticsService.instance.recordError(
          e,
          stack,
          reason: 'FCM initialization failed',
        );
      } catch (_) {}
    }
  }

  Future<NotificationSettings> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    _logger.i('FCM: 권한 상태 = ${settings.authorizationStatus}');
    return settings;
  }

  Future<void> _getAndStoreToken() async {
    try {
      final token = await _messaging.getToken();
      _currentToken = token;
      _logger.d('FCM: 토큰 = $token');

      if (token != null) {
        try {
          await CrashlyticsService.instance.setCustomKey('fcm_token', token);
        } catch (_) {}
      }
    } catch (e, stack) {
      _logger.e('FCM: 토큰 가져오기 실패', error: e, stackTrace: stack);
      try {
        await CrashlyticsService.instance.recordError(
          e,
          stack,
          reason: 'FCM getToken failed',
        );
      } catch (_) {}
    }
  }

  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((token) {
      _currentToken = token;
      _logger.d('FCM: 토큰 갱신 = $token');

      try {
        CrashlyticsService.instance.setCustomKey('fcm_token', token);
      } catch (_) {}
    });
  }

  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i(
        'FCM: 포그라운드 메시지 수신 — ${message.notification?.title}',
      );
    });
  }

  void _setupMessageOpenedAppHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.i(
        'FCM: 알림 탭으로 앱 열림 — ${message.notification?.title}',
      );
    });
  }

  Future<void> _handleInitialMessage() async {
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _logger.i(
          'FCM: 종료 상태에서 알림으로 앱 시작 — '
          '${initialMessage.notification?.title}',
        );
      }
    } catch (e, stack) {
      _logger.e('FCM: 초기 메시지 처리 실패', error: e, stackTrace: stack);
      try {
        await CrashlyticsService.instance.recordError(
          e,
          stack,
          reason: 'FCM getInitialMessage failed',
        );
      } catch (_) {}
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logger.i('FCM: 토픽 구독 — $topic');
    } catch (e, stack) {
      _logger.e('FCM: 토픽 구독 실패 — $topic', error: e, stackTrace: stack);
      try {
        await CrashlyticsService.instance.recordError(
          e,
          stack,
          reason: 'FCM subscribeToTopic failed: $topic',
        );
      } catch (_) {}
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _logger.i('FCM: 토픽 구독 해제 — $topic');
    } catch (e, stack) {
      _logger.e(
        'FCM: 토픽 구독 해제 실패 — $topic',
        error: e,
        stackTrace: stack,
      );
      try {
        await CrashlyticsService.instance.recordError(
          e,
          stack,
          reason: 'FCM unsubscribeFromTopic failed: $topic',
        );
      } catch (_) {}
    }
  }
}
