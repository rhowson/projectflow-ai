import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/project_creation/presentation/project_creation_screen.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
      GoRoute(
        path: '/create-project',
        name: 'create-project',
        builder: (context, state) => const ProjectCreationScreen(),
      ),
      // Auth routes (to be implemented)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Login Screen - To be implemented'),
          ),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register', 
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Register Screen - To be implemented'),
          ),
        ),
      ),
      // Project context gathering (to be implemented)
      GoRoute(
        path: '/project-context/:projectId',
        name: 'project-context',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'];
          return Scaffold(
            body: Center(
              child: Text('Context Gathering for Project: $projectId - To be implemented'),
            ),
          );
        },
      ),
      // Task management routes (to be implemented)
      GoRoute(
        path: '/tasks/:projectId',
        name: 'tasks',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'];
          return Scaffold(
            body: Center(
              child: Text('Task Management for Project: $projectId - To be implemented'),
            ),
          );
        },
      ),
      // Team management routes (to be implemented)
      GoRoute(
        path: '/team/:projectId',
        name: 'team',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'];
          return Scaffold(
            body: Center(
              child: Text('Team Management for Project: $projectId - To be implemented'),
            ),
          );
        },
      ),
      // Settings routes (to be implemented)
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Settings Screen - To be implemented'),
          ),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Profile Screen - To be implemented'),
          ),
        ),
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
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}