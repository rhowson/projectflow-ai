import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/project_role_model.dart';
import '../../../core/services/claude_ai_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../project_creation/providers/project_provider.dart';
import '../../auth/providers/auth_provider.dart';

part 'project_role_provider.g.dart';

/// Provider for managing project roles
@riverpod
class ProjectRoleNotifier extends _$ProjectRoleNotifier {
  @override
  AsyncValue<List<ProjectRole>> build(String projectId) {
    // Load roles automatically when provider is built
    _loadRolesAsync();
    return const AsyncValue.loading();
  }

  void _loadRolesAsync() {
    Future.microtask(() => loadProjectRoles());
  }

  /// Load roles for a specific project
  Future<void> loadProjectRoles() async {
    try {
      print('🔄 Loading project roles for project ID: $projectId');
      state = const AsyncValue.loading();
      
      // Try to load saved project roles from project metadata
      final projectsAsync = ref.read(projectNotifierProvider);
      final projects = await projectsAsync.when(
        data: (data) async => data,
        loading: () => throw Exception('Projects are still loading'),
        error: (error, stack) => throw error,
      );
      
      print('📄 Found ${projects.length} projects total');
      
      final project = projects.firstWhere(
        (p) => p.id == projectId,
        orElse: () => throw Exception('Project not found'),
      );
      
      print('🎯 Found target project: ${project.title}');
      print('🔍 Project metadata keys: ${project.metadata.customFields.keys.toList()}');
      
      // Load roles from project metadata if they exist
      List<ProjectRole> existingRoles = [];
      if (project.metadata.customFields.containsKey('projectRoles')) {
        final rolesData = project.metadata.customFields['projectRoles'] as List<dynamic>?;
        print('📊 Raw roles data type: ${rolesData.runtimeType}, length: ${rolesData?.length}');
        
        if (rolesData != null) {
          existingRoles = rolesData
              .map((roleData) => ProjectRole.fromJson(roleData as Map<String, dynamic>))
              .toList();
        }
      } else {
        print('⚠️  No projectRoles key found in metadata');
      }
      
      print('📋 Successfully loaded ${existingRoles.length} existing roles for project ${project.title}');
      if (existingRoles.isNotEmpty) {
        print('📝 Role names: ${existingRoles.map((r) => r.name).join(", ")}');
      }
      
      state = AsyncValue.data(existingRoles);
      
    } catch (error) {
      print('❌ Error loading project roles: $error');
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  /// Generate AI-suggested roles for the project using comprehensive context
  Future<List<AIRoleSuggestion>> generateRolesWithAI() async {
    try {
      final projectsAsync = ref.read(projectNotifierProvider);
      final projects = await projectsAsync.when(
        data: (data) async => data,
        loading: () => throw Exception('Projects are still loading'),
        error: (error, stack) => throw error,
      );
      final project = projects.firstWhere((p) => p.id == projectId);
      
      print('🎭 Generating roles with comprehensive context for project: ${project.title}');
      
      // Try to get saved project context and documentation if available
      List<DocumentContextPoint>? documentContext;
      Map<String, dynamic>? projectContextAnswers;
      String? documentContent;
      
      try {
        // Check if we have stored project context
        if (project.metadata.customFields.containsKey('documentContext')) {
          final contextData = project.metadata.customFields['documentContext'];
          if (contextData is List) {
            documentContext = contextData.map((item) => 
              DocumentContextPoint.fromJson(item as Map<String, dynamic>)
            ).toList();
          }
        }
        
        if (project.metadata.customFields.containsKey('projectContextAnswers')) {
          projectContextAnswers = project.metadata.customFields['projectContextAnswers'] as Map<String, dynamic>?;
        }
        
        if (project.metadata.customFields.containsKey('documentContent')) {
          documentContent = project.metadata.customFields['documentContent'] as String?;
        }
        
        print('📄 Found context data:');
        print('  Document context points: ${documentContext?.length ?? 0}');
        print('  Project context answers: ${projectContextAnswers?.keys.length ?? 0}');
        print('  Document content: ${documentContent?.length ?? 0} chars');
        
      } catch (e) {
        print('⚠️  Could not retrieve stored context: $e');
        print('📝 Proceeding with basic project information only');
      }

      // Use enhanced Claude AI service for role generation with full context
      final claudeService = ClaudeAIService(apiKey: AppConstants.claudeApiKey);
      final suggestions = await claudeService.generateProjectRoles(
        project,
        documentContext: documentContext,
        projectContextAnswers: projectContextAnswers,
        documentContent: documentContent,
      );
      
      print('✅ Generated ${suggestions.length} role suggestions with comprehensive context');
      return suggestions;
    } catch (error) {
      print('❌ Error generating AI roles: $error');
      rethrow;
    }
  }

  /// Create project roles from AI suggestions
  Future<void> createRolesFromSuggestions(List<AIRoleSuggestion> suggestions, {bool replaceExisting = false}) async {
    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) throw Exception('User not authenticated');

      print('🎯 Starting role creation: ${suggestions.length} suggestions, replace: $replaceExisting');

      final now = DateTime.now();
      final newRoles = suggestions.map((suggestion) => ProjectRole(
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

      print('🔧 Created ${newRoles.length} new role objects');

      // Determine final roles list based on replace vs add
      List<ProjectRole> finalRoles;
      if (replaceExisting) {
        finalRoles = newRoles;
        print('🔄 Replacing all existing roles with ${newRoles.length} new AI-generated roles');
      } else {
        final currentRoles = state.value ?? [];
        finalRoles = [...currentRoles, ...newRoles];
        print('➕ Adding ${newRoles.length} new roles to ${currentRoles.length} existing roles');
      }

      // Save roles to project metadata
      print('💾 Saving ${finalRoles.length} roles to project metadata...');
      await _saveRolesToProject(finalRoles);
      
      // Update local state
      state = AsyncValue.data(finalRoles);
      print('✅ Successfully updated provider state with ${finalRoles.length} roles');
      print('📋 Role names: ${finalRoles.map((r) => r.name).join(", ")}');
      
      // Notify listeners that roles have been updated
      print('📢 Notifying UI that roles have been updated...');
      
    } catch (error) {
      print('❌ Error creating roles from suggestions: $error');
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  /// Save roles to project metadata
  Future<void> _saveRolesToProject(List<ProjectRole> roles) async {
    try {
      // Get current project
      final projectsAsync = ref.read(projectNotifierProvider);
      final projects = await projectsAsync.when(
        data: (data) async => data,
        loading: () => throw Exception('Projects are still loading'),
        error: (error, stack) => throw error,
      );
      
      final project = projects.firstWhere(
        (p) => p.id == projectId,
        orElse: () => throw Exception('Project not found'),
      );

      // Update project metadata with roles
      final updatedCustomFields = Map<String, dynamic>.from(project.metadata.customFields);
      updatedCustomFields['projectRoles'] = roles.map((role) => role.toJson()).toList();
      
      final updatedMetadata = project.metadata.copyWith(
        customFields: updatedCustomFields,
      );
      
      final updatedProject = project.copyWith(
        metadata: updatedMetadata,
      );

      // Update project in the provider
      await ref.read(projectNotifierProvider.notifier).updateProject(updatedProject);
      
      print('💾 Saved ${roles.length} roles to project metadata');
      
      // Force reload of project roles to ensure UI reflects changes
      print('🔄 Forcing reload of project roles after save...');
      Future.delayed(const Duration(milliseconds: 100), () {
        loadProjectRoles();
      });
      
    } catch (error) {
      print('❌ Error saving roles to project: $error');
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

      // Add role to current roles list and save to project
      final currentRoles = state.value ?? [];
      final updatedRoles = [...currentRoles, role];
      
      // Save roles to project metadata
      await _saveRolesToProject(updatedRoles);
      
      // Update local state
      state = AsyncValue.data(updatedRoles);
      
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  /// Update an existing project role
  Future<void> updateRole(ProjectRole updatedRole) async {
    try {
      // Update local state
      final currentRoles = state.value ?? [];
      final updatedRoles = currentRoles.map((role) {
        return role.id == updatedRole.id ? updatedRole : role;
      }).toList();
      
      // Save updated roles to project metadata
      await _saveRolesToProject(updatedRoles);
      
      state = AsyncValue.data(updatedRoles);
      
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  /// Delete a project role
  Future<void> deleteRole(String roleId) async {
    try {
      // Update local state
      final currentRoles = state.value ?? [];
      final updatedRoles = currentRoles.where((role) => role.id != roleId).toList();
      
      // Save updated roles to project metadata
      await _saveRolesToProject(updatedRoles);
      
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

  /// Generate roles for active project using comprehensive context
  Future<void> generateRolesForActiveProject() async {
    try {
      state = const AsyncValue.loading();
      
      // Get active project
      final activeProject = await ref.read(activeProjectProvider.future);
      if (activeProject == null) {
        throw Exception('No active project found');
      }

      print('🎭 Generating roles for project: ${activeProject.title}');
      
      // Try to get saved project context and documentation if available
      List<DocumentContextPoint>? documentContext;
      Map<String, dynamic>? projectContextAnswers;
      String? documentContent;
      
      try {
        // Check if we have stored project context (this would be from project creation)
        // Note: In a real implementation, this would be stored in Firebase/backend
        // For now, we'll check if there's any recent context data
        
        print('🔍 Checking for saved project context and documentation...');
        
        // TODO: In production, retrieve these from Firebase/backend based on project ID
        // For now, we'll create a basic implementation that demonstrates the concept
        
        // Try to get any available context from project metadata or stored data
        if (activeProject.metadata.customFields.containsKey('documentContext')) {
          // Parse saved document context if available
          final contextData = activeProject.metadata.customFields['documentContext'];
          if (contextData is List) {
            documentContext = contextData.map((item) => 
              DocumentContextPoint.fromJson(item as Map<String, dynamic>)
            ).toList();
          }
        }
        
        if (activeProject.metadata.customFields.containsKey('projectContextAnswers')) {
          projectContextAnswers = activeProject.metadata.customFields['projectContextAnswers'] as Map<String, dynamic>?;
        }
        
        if (activeProject.metadata.customFields.containsKey('documentContent')) {
          documentContent = activeProject.metadata.customFields['documentContent'] as String?;
        }
        
        print('📄 Found context data:');
        print('  Document context points: ${documentContext?.length ?? 0}');
        print('  Project context answers: ${projectContextAnswers?.keys.length ?? 0}');
        print('  Document content: ${documentContent?.length ?? 0} chars');
        
      } catch (e) {
        print('⚠️  Could not retrieve stored context: $e');
        print('📝 Proceeding with basic project information only');
      }

      // Use enhanced Claude AI service for role generation with full context
      final claudeService = ClaudeAIService(apiKey: AppConstants.claudeApiKey);
      final suggestions = await claudeService.generateProjectRoles(
        activeProject,
        documentContext: documentContext,
        projectContextAnswers: projectContextAnswers,
        documentContent: documentContent,
      );
      
      print('✅ Generated ${suggestions.length} role suggestions with comprehensive context');
      state = AsyncValue.data(suggestions);
      
    } catch (error) {
      print('❌ Error generating roles for active project: $error');
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  /// Clear generated suggestions
  void clearSuggestions() {
    state = const AsyncValue.data(null);
  }
}