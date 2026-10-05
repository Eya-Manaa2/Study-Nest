import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_provider.dart';
import 'themes.dart';
import 'screens/auth_screen.dart';
import 'screens/main_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(const ProviderScope(child: StudyNestApp()));
}

class StudyNestApp extends ConsumerWidget {
  const StudyNestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final theme = buildThemeData(state.theme);

    return MaterialApp(
      title: 'StudyNest',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const AppRouter(),
    );
  }
}

// ─── Router ────────────────────────────────────────────────────────────────────

class AppRouter extends ConsumerStatefulWidget {
  const AppRouter({super.key});

  @override
  ConsumerState<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends ConsumerState<AppRouter> {
  bool _isAuthenticated = false;

  void _onLogin() => setState(() => _isAuthenticated = true);
  void _onLogout() => setState(() => _isAuthenticated = false);

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return AuthScreen(onLogin: _onLogin);
    }
    return MainScaffold(onLogout: _onLogout);
  }
}
