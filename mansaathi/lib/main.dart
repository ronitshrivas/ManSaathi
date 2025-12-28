import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

import 'app.dart';
import 'services/local_storage_service.dart';
import 'services/shared_prefs_service.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/therapist_provider.dart';
import 'providers/community_provider.dart';
import 'providers/meditation_provider.dart';
import 'providers/subscription_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only for better UX)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  // Initialize Hive for local database
  await Hive.initFlutter();
  debugPrint('✅ Hive initialized');

  // Initialize Local Storage Service
  await LocalStorageService().initialize();
  debugPrint('✅ Local Storage initialized');

  // Initialize SharedPreferences
  await SharedPrefsService().initialize();
  debugPrint('✅ SharedPreferences initialized');

  // Initialize Notification Service
  await NotificationService().initialize();
  debugPrint('✅ Notifications initialized');

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ManSaathiApp());
}

class ManSaathiApp extends StatelessWidget {
  const ManSaathiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => TherapistProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => MeditationProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: const App(),
    );
  }
}
