import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/project_creation/presentation/project_creation_screen.dart';
import '../features/project_creation/presentation/project_context_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import '../features/profile/presentation/simple_profile_screen.dart';
import '../features/team_management/presentation/team_screen.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../shared/widgets/main_navigation.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final isAuthenticated = container.read(isAuthenticatedProvider);
      final authState = container.read(authStateProvider);
      
      final isAuthRoute = state.fullPath == '/auth' || state.fullPath == '/';
      
      // Still loading auth state
      if (authState.isLoading) {
        return '/'; // Stay on splash
      }
      
      // Not authenticated and not on auth route
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth';
      }
      
      // Authenticated and on auth route, redirect to dashboard
      if (isAuthenticated && isAuthRoute && state.fullPath != '/') {
        return '/dashboard';
      }
      
      return null; // No redirect needed
    },
    routes: [
      // Splash screen (no bottom nav)
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth routes (no bottom nav)
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      
      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(
            currentPath: state.fullPath ?? '/dashboard',
            child: child,
          );
        },
        routes: [
          // Dashboard routes
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/dashboard/:projectId',
            name: 'project-dashboard',
            builder: (context, state) {
              final projectId = state.pathParameters['projectId'];
              return DashboardScreen(projectId: projectId);
            },
          ),
          
          // Create project route
          GoRoute(
            path: '/create-project',
            name: 'create-project',
            builder: (context, state) => const ProjectCreationScreen(),
          ),
          
          // Tasks routes
          GoRoute(
            path: '/tasks',
            name: 'tasks',
            builder: (context, state) {
              final projectId = state.uri.queryParameters['project'];
              final phaseId = state.uri.queryParameters['phase'];
              return TasksScreen(projectId: projectId, phaseId: phaseId);
            },
          ),
          GoRoute(
            path: '/tasks/:projectId',
            name: 'project-tasks',
            builder: (context, state) {
              final projectId = state.pathParameters['projectId'];
              final phaseId = state.uri.queryParameters['phase'];
              return TasksScreen(projectId: projectId, phaseId: phaseId);
            },
          ),
          
          // Team management route
          GoRoute(
            path: '/team',
            name: 'team',
            builder: (context, state) => const TeamScreen(),
          ),
          
          // Profile and Settings routes
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const SimpleProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Settings Screen - To be implemented'),
              ),
            ),
          ),
        ],
      ),
      
      // Special routes (no bottom nav)
      GoRoute(
        path: '/project-context',
        name: 'project-context',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final projectDescription = extra?['projectDescription'] as String? ?? '';
          final documentContent = extra?['documentContent'] as String?;
          
          return ProjectContextScreen(
            projectDescription: projectDescription,
            documentContent: documentContent,
          );
        },
      ),
      
      // Team management routes (no bottom nav for specific project views)
      GoRoute(
        path: '/team/:projectId',
        name: 'project-team',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'];
          return Scaffold(
            body: Center(
              child: Text('Team Management for Project: $projectId - To be implemented'),
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}