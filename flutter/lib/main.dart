import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'app_provider.dart';
import 'themes.dart';
import 'screens/auth_screen.dart';
import 'screens/main_scaffold.dart';
import 'services/firebase_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  
  // Initialisation de Firebase
  await Firebase.initializeApp();
  
  // Initialisation des notifications
  await _initializeNotifications();
  
  runApp(const ProviderScope(child: StudyNestApp()));
}

Future<void> _initializeNotifications() async {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );
  
  await notificationsPlugin.initialize(initializationSettings);
  
  // Créer le channel Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'todo_channel',
    'Rappels de tâches',
    description: 'Notifications pour les rappels de tâches',
    importance: Importance.high,
  );
  
  await notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  
  // Initialiser les timezone
  tz_data.initializeTimeZones();
}

class StudyNestApp extends ConsumerWidget {
  const StudyNestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final theme = buildThemeData(state.theme);

    return MaterialApp(
      title:        'StudyNest',
      debugShowCheckedModeBanner: false,
      theme:        theme,
      home:         const AppRouter(),
    );
  }
}

// ─── Router ────────────────────────────────────────────────────────────────────

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user != null) {
          return MainScaffold(
            onLogout: () async {
              final authService = ref.read(firebaseAuthServiceProvider);
              await authService.signOut();
            },
          );
        }
        return AuthScreen(
          onLogin: () {
            // Le login est géré automatiquement par Firebase Auth
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }
}
