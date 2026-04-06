import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/db/isar_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Isar ──────────────────────────────────────────────────────
  final isar = await initIsar();

  // ── Initialize SharedPreferences ─────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        sharedPrefsProvider.overrideWithValue(prefs), // ← matches your existing name
      ],
      child: const TotoneruApp(),
    ),
  );
}

class TotoneruApp extends ConsumerWidget {
  const TotoneruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);   // ← uses your routerProvider
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: '整える',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.light(settings.accentColor),
      darkTheme: AppTheme.dark(settings.accentColor),
      routerConfig: router,
    );
  }
}