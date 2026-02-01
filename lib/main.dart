import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zan/app.dart';
import 'package:zan/config/env/env.dart';
import 'package:zan/core/services/messaging_service.dart';
import 'package:zan/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Crashlytics: 디버그 모드에서는 비활성화
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  // Flutter 프레임워크 에러 캡처
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // 비동기 에러 캡처
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // FCM 초기화
  await MessagingService.instance.initialize();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: ZanApp(),
    ),
  );
}
