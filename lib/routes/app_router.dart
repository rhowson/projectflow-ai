import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/project_creation/presentation/project_creation_screen.dart';
import '../features/project_creation/presentation/project_context_screen.dart';
import '../features/project_creation/presentation/document_context_review_screen.dart';
import '../features/project_creation/presentation/project_generation_wrapper_screen.dart';
import '../features/project_context/presentation/project_context_screen.dart' as project_context;
import '../features/team_management/presentation/team_details_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import '../features/profile/presentation/simple_profile_screen.dart';
import '../features/team_management/presentation/team_screen.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../core/services/claude_ai_service.dart';
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
        path: '/document-context-review',
        name: 'document-context-review',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final projectDescription = extra?['projectDescription'] as String? ?? '';
          final documentContent = extra?['documentContent'] as String?;
          final documentAcknowledgment = extra?['documentAcknowledgment'] as String?;
          final documentUpload = extra?['documentUpload'];
          final tempDocument = extra?['tempDocument'];
          
          return DocumentContextReviewScreen(
            projectDescription: projectDescription,
            documentContent: documentContent,
            documentAcknowledgment: documentAcknowledgment,
            documentUpload: documentUpload,
            tempDocument: tempDocument,
          );
        },
      ),
      
      GoRoute(
        path: '/project-context',
        name: 'project-context',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final projectDescription = extra?['projectDescription'] as String? ?? '';
          final documentContent = extra?['documentContent'] as String?;
          final documentUploadResult = extra?['documentUploadResult'];
          final tempDocumentResult = extra?['tempDocumentResult'];
          final extractedContext = extra?['extractedContext'] as List<DocumentContextPoint>?;
          
          return ProjectContextScreen(
            projectDescription: projectDescription,
            documentContent: documentContent,
            documentUploadResult: documentUploadResult,
            tempDocumentResult: tempDocumentResult,
            extractedContext: extractedContext,
          );
        },
      ),
      
      // Project generation progress screen
      GoRoute(
        path: '/project-generation-progress',
        name: 'project-generation-progress',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            // Fallback to dashboard if no data provided
            return const DashboardScreen();
          }
          
          return ProjectGenerationWrapperScreen(
            generationData: extra,
          );
        },
      ),
      
      // Project context viewing route
      GoRoute(
        path: '/project-context/:projectId',
        name: 'view-project-context',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final projectTitle = state.uri.queryParameters['title'] ?? 'Project Context';
          
          return project_context.ProjectContextScreen(
            projectId: projectId,
            projectTitle: projectTitle,
          );
        },
      ),
      
      // Team management routes (no bottom nav for specific views)
      GoRoute(
        path: '/team-details/:teamId',
        name: 'team-details',
        builder: (context, state) {
          final teamId = state.pathParameters['teamId']!;
          return TeamDetailsScreen(teamId: teamId);
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