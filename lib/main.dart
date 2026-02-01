import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zan/app.dart';
import 'package:zan/config/env/env.dart';
import 'package:zan/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env');
  await dotenv.load(fileName: envFile);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
