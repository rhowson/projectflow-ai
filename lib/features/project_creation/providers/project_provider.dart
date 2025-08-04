import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/project_model.dart';
import '../../../core/services/claude_ai_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/document_service.dart';
import '../../../core/constants/app_constants.dart';

class ProjectNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  final ClaudeAIService _claudeService;
  final FirebaseService _firebaseService;
  final DocumentService _documentService;
  
  ProjectNotifier(this._claudeService, this._firebaseService, this._documentService) : super(const AsyncValue.loading()) {
    loadProjects();
  }

  Future<void> loadProjects() async {
    state = const AsyncValue.loading();
    try {
      print('Loading projects from Firebase...');
      final projects = await _firebaseService.loadAllProjects();
      state = AsyncValue.data(projects);
      print('Successfully loaded ${projects.length} projects');
    } catch (error, stackTrace) {
      print('Error loading projects: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<String> createProjectWithContext(
    String description, 
    Map<String, dynamic> contextAnswers, {
    DocumentUploadResult? document,
    String? documentContent,
  }) async {
    print('Starting project creation with context...');
    state = const AsyncValue.loading();
    
    try {
      final claudeService = _claudeService;
      print('Got Claude service, generating project breakdown...');
      
      // Generate complete project breakdown with context answers
      final projectBreakdown = await claudeService.generateProjectBreakdown(
        description, 
        contextAnswers,
      );
      print('Project breakdown generated with ${projectBreakdown.phases.length} phases');
      
      // Convert breakdown to project phases with tasks
      final phases = projectBreakdown.phases.map((phaseBreakdown) {
        final tasks = phaseBreakdown.tasks.map((taskBreakdown) {
          return Task(
            id: taskBreakdown.id,
            title: taskBreakdown.title,
            description: taskBreakdown.description,
            status: TaskStatus.todo,
            priority: _parsePriority(taskBreakdown.priority),
            createdAt: DateTime.now(),
            attachmentIds: [],
            dependencyIds: taskBreakdown.dependencies,
            estimatedHours: taskBreakdown.estimatedHours,
            actualHours: 0.0,
            comments: [],
          );
        }).toList();

        return ProjectPhase(
          id: phaseBreakdown.id,
          name: phaseBreakdown.name,
          description: phaseBreakdown.description,
          tasks: tasks,
          status: PhaseStatus.notStarted,
          startDate: null,
          endDate: null,
        );
      }).toList();
      
      // Create project with generated phases and tasks
      final project = Project(
        id: _generateId(),
        title: _extractTitle(description),
        description: description,
        status: ProjectStatus.inProgress,
        createdAt: DateTime.now(),
        teamMemberIds: [],
        phases: phases,
        metadata: ProjectMetadata(
          type: ProjectType.mobile, // Use fixed type for demo
          priority: Priority.medium,
          estimatedHours: projectBreakdown.totalEstimatedDays * 8.0,
          customFields: {
            'contextAnswers': contextAnswers,
            'totalEstimatedDays': projectBreakdown.totalEstimatedDays,
            'recommendations': projectBreakdown.recommendations,
          },
        ),
      );
      
      print('Created project: ${project.title} with ${project.phases.length} phases');
      
      // Save to Firebase
      await _firebaseService.saveProject(project);
      
      // Update state
      final currentProjects = state.value ?? [];
      state = AsyncValue.data([...currentProjects, project]);
      print('Project created and saved successfully: ${project.title}');
      
      // Clean up uploaded document if it exists
      if (document != null) {
        _documentService.cleanupDocument(document);
        print('Document cleaned up after processing');
      }
      
      return project.id;
      
    } catch (error, stackTrace) {
      print('Error creating project with context: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<String> createProject(String description, {DocumentUploadResult? document}) async {
    print('Starting project creation...');
    state = const AsyncValue.loading();
    
    try {
      final claudeService = _claudeService;
      print('Got Claude service, assessing project...');
      
      // Step 1: Assess project with Claude AI
      final assessment = await claudeService.assessProject(
        description, 
        documentContent: document?.content,
      );
      print('Project assessed: ${assessment.projectType}');
      
      // Step 2: Generate context questions
      await claudeService.generateContextQuestions(assessment);
      print('Context questions generated');
      
      // Step 3: Generate complete project breakdown with tasks
      final projectBreakdown = await claudeService.generateProjectBreakdown(
        description, 
        {'assessment': assessment.toJson()} // Use assessment as context for now
      );
      print('Project breakdown generated with ${projectBreakdown.phases.length} phases');
      
      // Step 4: Convert breakdown to project phases with tasks
      final phases = projectBreakdown.phases.map((phaseBreakdown) {
        final tasks = phaseBreakdown.tasks.map((taskBreakdown) {
          return Task(
            id: taskBreakdown.id,
            title: taskBreakdown.title,
            description: taskBreakdown.description,
            status: TaskStatus.todo,
            priority: _parsePriority(taskBreakdown.priority),
            createdAt: DateTime.now(),
            attachmentIds: [],
            dependencyIds: taskBreakdown.dependencies,
            estimatedHours: taskBreakdown.estimatedHours,
            actualHours: 0.0,
            comments: [],
          );
        }).toList();

        return ProjectPhase(
          id: phaseBreakdown.id,
          name: phaseBreakdown.name,
          description: phaseBreakdown.description,
          tasks: tasks,
          status: PhaseStatus.notStarted,
          startDate: null,
          endDate: null,
        );
      }).toList();
      
      // Step 5: Create project with generated phases and tasks
      final project = Project(
        id: _generateId(),
        title: _extractTitle(description),
        description: description,
        status: ProjectStatus.inProgress,
        createdAt: DateTime.now(),
        teamMemberIds: [],
        phases: phases,
        metadata: ProjectMetadata(
          type: ProjectType.mobile, // Use fixed type for demo since extension might not exist
          priority: Priority.medium,
          estimatedHours: projectBreakdown.totalEstimatedDays * 8.0, // Convert days to hours
          customFields: {
            'assessment': assessment.toJson(),
            'totalEstimatedDays': projectBreakdown.totalEstimatedDays,
            'recommendations': projectBreakdown.recommendations,
          },
        ),
      );
      
      print('Created project: ${project.title} with ${project.phases.length} phases');
      
      // Save to Firebase
      await _firebaseService.saveProject(project);
      
      // Update state
      final currentProjects = state.value ?? [];
      state = AsyncValue.data([...currentProjects, project]);
      print('Project created and saved successfully: ${project.title}');
      
      // Clean up uploaded document if it exists
      if (document != null) {
        _documentService.cleanupDocument(document);
        print('Document cleaned up after processing');
      }
      
      // Store questions for context gathering
      // This would typically be handled by navigation or another provider
      
      // Return the project ID for navigation
      return project.id;
      
    } catch (error, stackTrace) {
      print('Error creating project: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow; // Re-throw so the UI can handle it
    }
  }

  Future<void> completeContextGathering(
    String projectId,
    Map<String, dynamic> contextAnswers,
  ) async {
    try {
      final claudeService = _claudeService;
      final currentProjects = state.value ?? [];
      final projectIndex = currentProjects.indexWhere((p) => p.id == projectId);
      
      if (projectIndex == -1) {
        throw Exception('Project not found');
      }
      
      final project = currentProjects[projectIndex];
      
      // Generate complete project breakdown
      final breakdown = await claudeService.generateProjectBreakdown(
        project.description,
        contextAnswers,
      );
      
      // Convert breakdown to project phases
      final phases = breakdown.phases.map((phaseBreakdown) {
        final tasks = phaseBreakdown.tasks.map((taskBreakdown) {
          return Task(
            id: taskBreakdown.id,
            title: taskBreakdown.title,
            description: taskBreakdown.description,
            status: TaskStatus.todo,
            priority: _parsePriority(taskBreakdown.priority),
            createdAt: DateTime.now(),
            attachmentIds: [],
            dependencyIds: taskBreakdown.dependencies,
            estimatedHours: taskBreakdown.estimatedHours,
            actualHours: 0.0,
            comments: [],
          );
        }).toList();

        return ProjectPhase(
          id: phaseBreakdown.id,
          name: phaseBreakdown.name,
          description: phaseBreakdown.description,
          tasks: tasks,
          status: PhaseStatus.notStarted,
          startDate: null,
          endDate: null,
        );
      }).toList();
      
      // Update project with phases and tasks
      final updatedProject = project.copyWith(
        phases: phases,
        status: ProjectStatus.inProgress,
      );
      
      // Save to Firebase
      await _firebaseService.updateProject(updatedProject);
      
      // Update state
      final updatedProjects = [...currentProjects];
      updatedProjects[projectIndex] = updatedProject;
      state = AsyncValue.data(updatedProjects);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProject(Project updatedProject) async {
    final currentProjects = state.value ?? [];
    final projectIndex = currentProjects.indexWhere((p) => p.id == updatedProject.id);
    
    if (projectIndex != -1) {
      try {
        // Save to Firebase
        await _firebaseService.updateProject(updatedProject);
        
        // Update state
        final updatedProjects = [...currentProjects];
        updatedProjects[projectIndex] = updatedProject;
        state = AsyncValue.data(updatedProjects);
        print('Project updated: ${updatedProject.title}');
      } catch (error, stackTrace) {
        print('Error updating project: $error');
        // Note: We don't update state on error to maintain consistency
      }
    }
  }

  // Task Management Methods
  Future<void> addTaskToPhase(String projectId, String phaseId, Task newTask) async {
    try {
      final currentProjects = state.value ?? [];
      final projectIndex = currentProjects.indexWhere((p) => p.id == projectId);
      
      if (projectIndex != -1) {
        final project = currentProjects[projectIndex];
        final phaseIndex = project.phases.indexWhere((p) => p.id == phaseId);
        
        if (phaseIndex != -1) {
          final updatedPhases = [...project.phases];
          final phase = updatedPhases[phaseIndex];
          final updatedTasks = [...phase.tasks, newTask];
          
          updatedPhases[phaseIndex] = ProjectPhase(
            id: phase.id,
            name: phase.name,
            description: phase.description,
            tasks: updatedTasks,
            status: phase.status,
            startDate: phase.startDate,
            endDate: phase.endDate,
          );
          
          final updatedProject = Project(
            id: project.id,
            title: project.title,
            description: project.description,
            status: project.status,
            createdAt: project.createdAt,
            dueDate: project.dueDate,
            teamMemberIds: project.teamMemberIds,
            phases: updatedPhases,
            metadata: project.metadata,
          );
          
          // Save to Firebase
          await _firebaseService.updateProject(updatedProject);
          
          final updatedProjects = [...currentProjects];
          updatedProjects[projectIndex] = updatedProject;
          state = AsyncValue.data(updatedProjects);
        }
      }
    } catch (error, stackTrace) {
      print('Error adding task to phase: $error');
      // Don't update state on error to maintain consistency
    }
  }

  Future<void> updateTask(String projectId, String phaseId, Task updatedTask) async {
    final currentProjects = state.value ?? [];
    final projectIndex = currentProjects.indexWhere((p) => p.id == projectId);
    
    if (projectIndex != -1) {
      final project = currentProjects[projectIndex];
      final phaseIndex = project.phases.indexWhere((p) => p.id == phaseId);
      
      if (phaseIndex != -1) {
        final updatedPhases = [...project.phases];
        final phase = updatedPhases[phaseIndex];
        final taskIndex = phase.tasks.indexWhere((t) => t.id == updatedTask.id);
        
        if (taskIndex != -1) {
          final updatedTasks = [...phase.tasks];
          updatedTasks[taskIndex] = updatedTask;
          
          updatedPhases[phaseIndex] = ProjectPhase(
            id: phase.id,
            name: phase.name,
            description: phase.description,
            tasks: updatedTasks,
            status: phase.status,
            startDate: phase.startDate,
            endDate: phase.endDate,
          );
          
          final updatedProject = Project(
            id: project.id,
            title: project.title,
            description: project.description,
            status: project.status,
            createdAt: project.createdAt,
            dueDate: project.dueDate,
            teamMemberIds: project.teamMemberIds,
            phases: updatedPhases,
            metadata: project.metadata,
          );
          
          // Save to Firebase
          await _firebaseService.updateProject(updatedProject);
          
          final updatedProjects = [...currentProjects];
          updatedProjects[projectIndex] = updatedProject;
          state = AsyncValue.data(updatedProjects);
        }
      }
    }
  }

  Future<void> deleteTask(String projectId, String phaseId, String taskId) async {
    final currentProjects = state.value ?? [];
    final projectIndex = currentProjects.indexWhere((p) => p.id == projectId);
    
    if (projectIndex != -1) {
      final project = currentProjects[projectIndex];
      final phaseIndex = project.phases.indexWhere((p) => p.id == phaseId);
      
      if (phaseIndex != -1) {
        final updatedPhases = [...project.phases];
        final phase = updatedPhases[phaseIndex];
        final updatedTasks = phase.tasks.where((t) => t.id != taskId).toList();
        
        updatedPhases[phaseIndex] = ProjectPhase(
          id: phase.id,
          name: phase.name,
          description: phase.description,
          tasks: updatedTasks,
          status: phase.status,
          startDate: phase.startDate,
          endDate: phase.endDate,
        );
        
        final updatedProject = Project(
          id: project.id,
          title: project.title,
          description: project.description,
          status: project.status,
          createdAt: project.createdAt,
          dueDate: project.dueDate,
          teamMemberIds: project.teamMemberIds,
          phases: updatedPhases,
          metadata: project.metadata,
        );
        
        // Save to Firebase
        await _firebaseService.updateProject(updatedProject);
        
        final updatedProjects = [...currentProjects];
        updatedProjects[projectIndex] = updatedProject;
        state = AsyncValue.data(updatedProjects);
      }
    }
  }

  Future<void> toggleTaskCompletion(String projectId, String phaseId, String taskId) async {
    final currentProjects = state.value ?? [];
    final projectIndex = currentProjects.indexWhere((p) => p.id == projectId);
    
    if (projectIndex != -1) {
      final project = currentProjects[projectIndex];
      final phaseIndex = project.phases.indexWhere((p) => p.id == phaseId);
      
      if (phaseIndex != -1) {
        final updatedPhases = [...project.phases];
        final phase = updatedPhases[phaseIndex];
        final taskIndex = phase.tasks.indexWhere((t) => t.id == taskId);
        
        if (taskIndex != -1) {
          final task = phase.tasks[taskIndex];
          final updatedTasks = [...phase.tasks];
          
          // Toggle task completion status
          final newStatus = task.status == TaskStatus.completed 
              ? TaskStatus.todo 
              : TaskStatus.completed;
              
          updatedTasks[taskIndex] = Task(
            id: task.id,
            title: task.title,
            description: task.description,
            status: newStatus,
            priority: task.priority,
            assignedToId: task.assignedToId,
            createdAt: task.createdAt,
            dueDate: task.dueDate,
            attachmentIds: task.attachmentIds,
            dependencyIds: task.dependencyIds,
            estimatedHours: task.estimatedHours,
            actualHours: task.actualHours,
            comments: task.comments,
          );
          
          // Check if all tasks in phase are completed
          final allTasksCompleted = updatedTasks.every((t) => t.status == TaskStatus.completed);
          final newPhaseStatus = updatedTasks.isEmpty 
              ? PhaseStatus.notStarted
              : allTasksCompleted 
                  ? PhaseStatus.completed 
                  : PhaseStatus.inProgress;
          
          updatedPhases[phaseIndex] = ProjectPhase(
            id: phase.id,
            name: phase.name,
            description: phase.description,
            tasks: updatedTasks,
            status: newPhaseStatus,
            startDate: phase.startDate,
            endDate: newPhaseStatus == PhaseStatus.completed ? DateTime.now() : phase.endDate,
          );
          
          final updatedProject = Project(
            id: project.id,
            title: project.title,
            description: project.description,
            status: project.status,
            createdAt: project.createdAt,
            dueDate: project.dueDate,
            teamMemberIds: project.teamMemberIds,
            phases: updatedPhases,
            metadata: project.metadata,
          );
          
          // Save to Firebase
          await _firebaseService.updateProject(updatedProject);
          
          final updatedProjects = [...currentProjects];
          updatedProjects[projectIndex] = updatedProject;
          state = AsyncValue.data(updatedProjects);
        }
      }
    }
  }

  Future<void> moveTaskToPhase(String projectId, String fromPhaseId, String toPhaseId, String taskId) async {
    final currentProjects = state.value ?? [];
    final projectIndex = currentProjects.indexWhere((p) => p.id == projectId);
    
    if (projectIndex != -1) {
      final project = currentProjects[projectIndex];
      final fromPhaseIndex = project.phases.indexWhere((p) => p.id == fromPhaseId);
      final toPhaseIndex = project.phases.indexWhere((p) => p.id == toPhaseId);
      
      if (fromPhaseIndex != -1 && toPhaseIndex != -1) {
        final updatedPhases = [...project.phases];
        final fromPhase = updatedPhases[fromPhaseIndex];
        final toPhase = updatedPhases[toPhaseIndex];
        
        // Find and remove task from source phase
        final taskToMove = fromPhase.tasks.firstWhere((t) => t.id == taskId);
        final updatedFromTasks = fromPhase.tasks.where((t) => t.id != taskId).toList();
        
        // Add task to destination phase
        final updatedToTasks = [...toPhase.tasks, taskToMove];
        
        // Update both phases
        updatedPhases[fromPhaseIndex] = ProjectPhase(
          id: fromPhase.id,
          name: fromPhase.name,
          description: fromPhase.description,
          tasks: updatedFromTasks,
          status: fromPhase.status,
          startDate: fromPhase.startDate,
          endDate: fromPhase.endDate,
        );
        
        updatedPhases[toPhaseIndex] = ProjectPhase(
          id: toPhase.id,
          name: toPhase.name,
          description: toPhase.description,
          tasks: updatedToTasks,
          status: toPhase.status,
          startDate: toPhase.startDate,
          endDate: toPhase.endDate,
        );
        
        final updatedProject = Project(
          id: project.id,
          title: project.title,
          description: project.description,
          status: project.status,
          createdAt: project.createdAt,
          dueDate: project.dueDate,
          teamMemberIds: project.teamMemberIds,
          phases: updatedPhases,
          metadata: project.metadata,
        );
        
        // Save to Firebase
        await _firebaseService.updateProject(updatedProject);
        
        final updatedProjects = [...currentProjects];
        updatedProjects[projectIndex] = updatedProject;
        state = AsyncValue.data(updatedProjects);
      }
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      print('Deleting project with ID: $projectId');
      
      // Delete from Firebase first
      await _firebaseService.deleteProject(projectId);
      print('Project deleted from Firebase');
      
      // Update local state
      final currentProjects = state.value ?? [];
      final updatedProjects = currentProjects.where((p) => p.id != projectId).toList();
      state = AsyncValue.data(updatedProjects);
      
      print('Project deleted successfully. Remaining projects: ${updatedProjects.length}');
      
    } catch (error, stackTrace) {
      print('Error deleting project: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow; // Re-throw so the UI can handle the error
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _extractTitle(String description) {
    // Extract first sentence or first 50 chars as title
    final sentences = description.split('.');
    if (sentences.isNotEmpty && sentences.first.length <= 50) {
      return sentences.first.trim();
    }
    return description.length <= 50 
        ? description 
        : '${description.substring(0, 47)}...';
  }

  Priority _parsePriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      case 'urgent':
        return Priority.urgent;
      default:
        return Priority.medium;
    }
  }
}

// Providers
final claudeAIServiceProvider = Provider<ClaudeAIService>((ref) {
  return ClaudeAIService(apiKey: AppConstants.claudeApiKey);
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final documentServiceProvider = Provider<DocumentService>((ref) {
  return DocumentService();
});

final projectNotifierProvider = StateNotifierProvider<ProjectNotifier, AsyncValue<List<Project>>>((ref) {
  final claudeService = ref.watch(claudeAIServiceProvider);
  final firebaseService = ref.watch(firebaseServiceProvider);
  final documentService = ref.watch(documentServiceProvider);
  return ProjectNotifier(claudeService, firebaseService, documentService);
});

final projectProvider = Provider.family<AsyncValue<Project?>, String>((ref, projectId) {
  final projects = ref.watch(projectNotifierProvider);
  return projects.when(
    data: (projectList) {
      try {
        final project = projectList.firstWhere((p) => p.id == projectId);
        return AsyncValue.data(project);
      } catch (e) {
        return AsyncValue.error('Project not found', StackTrace.current);
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});