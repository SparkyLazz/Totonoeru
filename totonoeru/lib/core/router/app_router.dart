import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../features/tasks/task_detail_screen.dart';
import '../../features/tasks/add_task_sheet.dart';
import '../../features/schedule/schedule_screen.dart';
import '../../features/focus/focus_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../providers/shared_preferences_provider.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const tasks = '/tasks';
  static const taskDetail = '/tasks/:id';
  static const taskAdd = '/tasks/add';
  static const schedule = '/schedule';
  static const scheduleMonth = '/schedule/month';
  static const focus = '/focus';
  static const settings = '/settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final onboardingComplete = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: onboardingComplete ? AppRoutes.home : AppRoutes.onboarding,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!onboardingComplete && !isOnboarding) return AppRoutes.onboarding;
      if (onboardingComplete && isOnboarding) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0 — Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),

          // Branch 1 — Tasks (Week 2 wired)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.tasks,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TasksScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'add',
                    pageBuilder: (context, state) => MaterialPage(
                      fullscreenDialog: true,
                      child: Builder(
                        builder: (ctx) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (ctx.mounted) {
                              showModalBottomSheet(
                                context: ctx,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const AddTaskSheet(),
                              ).then((_) {
                                if (ctx.mounted) ctx.go(AppRoutes.tasks);
                              });
                            }
                          });
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) {
                      final rawId = state.pathParameters['id']!;
                      final taskId = int.tryParse(rawId) ?? 0;
                      return MaterialPage(
                        child: TaskDetailScreen(taskId: taskId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 2 — Schedule
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.schedule,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ScheduleScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'month',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: ScheduleScreen(initialView: ScheduleView.month),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Branch 3 — Focus
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.focus,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FocusScreen(),
                ),
              ),
            ],
          ),

          // Branch 4 — Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

void handleNotificationDeepLink(BuildContext context, String? payload) {
  if (payload == null) return;
  final parts = payload.split(':');
  if (parts.isEmpty) return;
  switch (parts[0]) {
    case 'task':
      if (parts.length > 1) context.go('/tasks/${parts[1]}');
    case 'block':
      context.go(AppRoutes.schedule);
    case 'focus':
      context.go(AppRoutes.focus);
  }
}