import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';
import '../../features/home/home_screen.dart';
import '../../features/tasks/task_list_screen.dart';
import '../../features/schedule/schedule_screen.dart';
import '../../features/focus/focus_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/stats/stats_screen.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ROUTER
// Decision 1: 5-tab StatefulShellRoute. Each tab has its own nav stack.
// Onboarding is a full-screen route (no nav bar), shown once only.
// Stats is NOT a tab — pushed from Settings.
// ─────────────────────────────────────────────────────────────────────────────

// Route path constants
class AppRoutes {
  AppRoutes._();
  static const String onboarding = '/onboarding';
  static const String home       = '/home';
  static const String tasks      = '/tasks';
  static const String schedule   = '/schedule';
  static const String focus      = '/focus';
  static const String settings   = '/settings';
  static const String stats      = '/settings/stats';
}

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingDone = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: onboardingDone ? AppRoutes.home : AppRoutes.onboarding,
    redirect: (context, state) {
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!onboardingDone && !isOnboarding) return AppRoutes.onboarding;
      if (onboardingDone && isOnboarding) return AppRoutes.home;
      return null;
    },
    routes: [
      // ── ONBOARDING ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── MAIN SHELL (5 tabs with persistent bottom nav) ──────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.tasks,
                builder: (context, state) => const TaskListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.schedule,
                builder: (context, state) => const ScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.focus,
                builder: (context, state) => const FocusScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'stats',
                    builder: (context, state) => const StatsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// ── APP SHELL ─────────────────────────────────────────────────────────────────
// Wraps all tab screens with the persistent BottomNavBar.

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
