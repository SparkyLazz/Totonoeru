import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Preferred orientations ──────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Init Isar (task 1.22) ───────────────────────────────────────────────
  await DatabaseService.instance.init();

  // ── Init SharedPreferences (task 1.24) ─────────────────────────────────
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override the placeholder with the real prefs instance
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TotnonoruApp(),
    ),
  );
}

// ── Root App ──────────────────────────────────────────────────────────────────

class TotnonoruApp extends ConsumerWidget {
  const TotnonoruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Watch accent + theme — rebuilds ThemeData on change (task 1.11) ──
    final accent = ref.watch(accentColorProvider);
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Totonoeru',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,

      // Light theme
      theme: AppTheme.buildTheme(accent, Brightness.light),

      // Dark theme
      darkTheme: AppTheme.buildTheme(accent, Brightness.dark),

      // Router
      routerConfig: router,
    );
  }
}
//