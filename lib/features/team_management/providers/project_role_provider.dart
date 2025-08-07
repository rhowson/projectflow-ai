import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/project_role_model.dart';
import '../../../core/services/project_role_ai_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../project_creation/providers/project_provider.dart';
import '../../auth/providers/auth_provider.dart';

part 'project_role_provider.g.dart';

/// Provider for managing project roles
@riverpod
class ProjectRoleNotifier extends _$ProjectRoleNotifier {
  @override
  AsyncValue<List<ProjectRole>> build(String projectId) {
    return const AsyncValue.loading();
  }

  /// Load roles for a specific project
  Future<void> loadProjectRoles() async {
    try {
      state = const AsyncValue.loading();
      
      // TODO: Implement Firebase/backend call to load project roles
      // For now, return empty list
      state = const AsyncValue.data([]);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  /// Generate AI-suggested roles for the project
  Future<List<AIRoleSuggestion>> generateRolesWithAI() async {
    try {
      final projectsAsync = ref.read(projectNotifierProvider);
      final projects = await projectsAsync.when(
        data: (data) async => data,
        loading: () => throw Exception('Projects are still loading'),
        error: (error, stack) => throw error,
      );
      final project = projects.firstWhere((p) => p.id == projectId);
      
      final aiService = ProjectRoleAIService(apiKey: AppConstants.claudeApiKey);
      final suggestions = await aiService.generateProjectRoles(project);
      
      return suggestions;
    } catch (error) {
      print('Error generating AI roles: $error');
      rethrow;
    }
  }

  /// Create project roles from AI suggestions
  Future<void> createRolesFromSuggestions(List<AIRoleSuggestion> suggestions) async {
    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final roles = suggestions.map((suggestion) => ProjectRole(
        id: _generateId(),
        projectId: projectId,
        name: suggestion.name,
        description: suggestion.description,
        color: suggestion.suggestedColor,
        permissions: suggestion.permissions,
        isAssignable: true,
        isAIGenerated: true,
        priority: suggestion.priority,
        createdAt: now,
        createdBy: currentUser.id,
        requiredSkills: suggestion.requiredSkills,
        timeCommitment: suggestion.timeCommitment,
      )).toList();

      // TODO: Save roles to Firebase/backend
      
      // Update local state
      final currentRoles = state.value ?? [];
      state = AsyncValue.data([...currentRoles, ...roles]);
      
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  /// Create a custom project role
  Future<void> createCustomRole({
    required String name,
    required String description,
    required String color,
    required List<String> permissions,
    required List<String> requiredSkills,
    double? timeCommitment,
    int priority = 5,
  }) async {
    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) throw Exception('User not authenticated');

      final role = ProjectRole(
        id: _generateId(),
        projectId: projectId,
        name: name,
        description: description,
        color: color,
        permissions: permissions,
        isAssignable: true,
        isAIGenerated: false,
        priority: priority,
        createdAt: DateTime.now(),
        createdBy: currentUser.id,
        requiredSkills: requiredSkills,
        timeCommitment: timeCommitment,
      );

      // TODO: Save role to Firebase/backend
      
      // Update local state
      final currentRoles = state.value ?? [];
      state = AsyncValue.data([...currentRoles, role]);
      
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  /// Update an existing project role
  Future<void> updateRole(ProjectRole updatedRole) async {
    try {
      // TODO: Update role in Firebase/backend
      
      // Update local state
      final currentRoles = state.value ?? [];
      final updatedRoles = currentRoles.map((role) {
        return role.id == updatedRole.id ? updatedRole : role;
      }).toList();
      state = AsyncValue.data(updatedRoles);
      
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  /// Delete a project role
  Future<void> deleteRole(String roleId) async {
    try {
      // TODO: Delete from Firebase/backend
      
      // Update local state
      final currentRoles = state.value ?? [];
      final updatedRoles = currentRoles.where((role) => role.id != roleId).toList();
      state = AsyncValue.data(updatedRoles);
      
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}

/// Provider for project role assignments
@riverpod
class ProjectRoleAssignmentNotifier extends _$ProjectRoleAssignmentNotifier {
  @override
  AsyncValue<List<ProjectRoleAssignment>> build(String projectId) {
    return const AsyncValue.loading();
  }

  /// Load role assignments for a project
  Future<void> loadAssignments() async {
    try {
      state = const AsyncValue.loading();
      
      // TODO: Implement Firebase/backend call to load assignments
      // For now, return empty list
      state = const AsyncValue.data([]);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  /// Assign a user to a project role
  Future<void> assignUserToRole({
    required String roleId,
    required String userId,
    String? customTitle,
    String? notes,
  }) async {
    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) throw Exception('User not authenticated');

      final assignment = ProjectRoleAssignment(
        id: _generateId(),
        projectRoleId: roleId,
        userId: userId,
        projectId: projectId,
        assignedAt: DateTime.now(),
        assignedBy: currentUser.id,
        status: AssignmentStatus.active,
        customTitle: customTitle,
        notes: notes,
      );

      // TODO: Save assignment to Firebase/backend
      
      // Update local state
      final currentAssignments = state.value ?? [];
      state = AsyncValue.data([...currentAssignments, assignment]);
      
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  /// Remove user from role
  Future<void> removeUserFromRole(String assignmentId) async {
    try {
      // TODO: Delete assignment from Firebase/backend
      
      // Update local state
      final currentAssignments = state.value ?? [];
      final updatedAssignments = currentAssignments.where((a) => a.id != assignmentId).toList();
      state = AsyncValue.data(updatedAssignments);
      
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  /// Get assignments for a specific role
  List<ProjectRoleAssignment> getAssignmentsForRole(String roleId) {
    final assignments = state.value ?? [];
    return assignments.where((a) => a.projectRoleId == roleId).toList();
  }

  /// Get assignments for a specific user
  List<ProjectRoleAssignment> getAssignmentsForUser(String userId) {
    final assignments = state.value ?? [];
    return assignments.where((a) => a.userId == userId).toList();
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}

/// Combined provider for active project roles (convenience)
@riverpod
Future<Project?> activeProject(Ref ref) async {
  final projectsAsync = ref.watch(projectNotifierProvider);
  return await projectsAsync.when(
    data: (projects) async => projects.isNotEmpty ? projects.first : null,
    loading: () => null,
    error: (error, stack) => null,
  );
}

/// Provider for AI role generation state
@riverpod
class AIRoleGenerationNotifier extends _$AIRoleGenerationNotifier {
  @override
  AsyncValue<List<AIRoleSuggestion>?> build() {
    return const AsyncValue.data(null);
  }

  /// Generate roles for active project
  Future<void> generateRolesForActiveProject() async {
    try {
      state = const AsyncValue.loading();
      
      final activeProject = await ref.read(activeProjectProvider.future);
      if (activeProject == null) {
        throw Exception('No active project found');
      }

      final aiService = ProjectRoleAIService(apiKey: AppConstants.claudeApiKey);
      final suggestions = await aiService.generateProjectRoles(activeProject);
      
      state = AsyncValue.data(suggestions);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  /// Clear generated suggestions
  void clearSuggestions() {
    state = const AsyncValue.data(null);
  }
}