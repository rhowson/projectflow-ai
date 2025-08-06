import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/project_context_model.dart' as context_models;
import '../../../core/services/claude_ai_service.dart' as claude_service;
import '../../../core/services/firebase_service.dart';
import '../../../core/services/document_service.dart';
import '../../auth/providers/auth_provider.dart';
import 'project_provider.dart';

enum GenerationStep {
  analyzing,
  structuring,
  detailing,
  finalizing,
  completed,
}

class GenerationProgress {
  final GenerationStep currentStep;
  final String message;
  final List<String> completedSteps;
  final double progress;
  final String? projectId;
  final String? error;
  final bool isCompleted;

  const GenerationProgress({
    required this.currentStep,
    required this.message,
    required this.completedSteps,
    required this.progress,
    this.projectId,
    this.error,
    this.isCompleted = false,
  });

  GenerationProgress copyWith({
    GenerationStep? currentStep,
    String? message,
    List<String>? completedSteps,
    double? progress,
    String? projectId,
    String? error,
    bool? isCompleted,
  }) {
    return GenerationProgress(
      currentStep: currentStep ?? this.currentStep,
      message: message ?? this.message,
      completedSteps: completedSteps ?? this.completedSteps,
      progress: progress ?? this.progress,
      projectId: projectId ?? this.projectId,
      error: error ?? this.error,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ProjectGenerationNotifier extends StateNotifier<AsyncValue<GenerationProgress>> {
  final claude_service.ClaudeAIService _claudeService;
  final FirebaseService _firebaseService;
  final DocumentService _documentService;
  final Ref ref;

  ProjectGenerationNotifier(
    this._claudeService,
    this._firebaseService,
    this._documentService,
    this.ref,
  ) : super(const AsyncValue.loading());

  String get _currentUserId {
    final currentUser = ref.read(authStateProvider);
    return currentUser.when(
      data: (user) => user?.uid ?? '',
      loading: () => '',
      error: (_, __) => '',
    );
  }

  Future<String> generateProjectWithProgress(
    String description,
    Map<String, dynamic> contextAnswers, {
    DocumentUploadResult? document,
    String? documentContent,
  }) async {
    try {
      // Initialize progress
      state = AsyncValue.data(GenerationProgress(
        currentStep: GenerationStep.analyzing,
        message: 'Analyzing project requirements with AI...',
        completedSteps: [],
        progress: 0.0,
      ));

      // Step 1: Project Analysis (25% progress)
      await Future.delayed(const Duration(milliseconds: 500)); // Small delay for UX
      final projectAnalysis = await _claudeService.analyzeProjectWithFullContext(
        description,
        contextAnswers,
        documentContent,
      );

      _updateProgress(
        GenerationStep.structuring,
        'Creating optimal phase structure...',
        ['Project analysis completed'],
        0.25,
      );

      // Step 2: Phase Structure (50% progress)
      await Future.delayed(const Duration(milliseconds: 500));
      final phaseStructure = await _claudeService.generatePhaseStructure(
        description,
        contextAnswers,
        documentContent,
        projectAnalysis,
      );

      _updateProgress(
        GenerationStep.detailing,
        'Generating detailed tasks and timelines...',
        ['Project analysis completed', 'Phase structure created'],
        0.50,
      );

      // Step 3: Detailed Task Generation (75% progress)
      await Future.delayed(const Duration(milliseconds: 500));
      final phases = <claude_service.ProjectPhaseBreakdown>[];
      for (int i = 0; i < phaseStructure.length; i++) {
        final phase = phaseStructure[i];
        
        // Update message for current phase
        _updateProgress(
          GenerationStep.detailing,
          'Generating tasks for "${phase.name}"...',
          ['Project analysis completed', 'Phase structure created'],
          0.50 + (i / phaseStructure.length) * 0.25,
        );
        
        final detailedPhase = await _claudeService.generatePhaseWithDetailedTasks(
          phase,
          description,
          contextAnswers,
          documentContent,
          projectAnalysis,
          phases,
        );
        phases.add(detailedPhase);
      }

      _updateProgress(
        GenerationStep.finalizing,
        'Finalizing project breakdown...',
        ['Project analysis completed', 'Phase structure created', 'Detailed tasks generated'],
        0.75,
      );

      // Step 4: Create and Save Project (90% progress)
      await Future.delayed(const Duration(milliseconds: 300));
      final projectId = _generateId();
      final project = Project(
        id: projectId,
        title: _extractTitle(description),
        description: description,
        status: ProjectStatus.inProgress,
        createdAt: DateTime.now(),
        ownerId: _currentUserId,
        teamMemberIds: [],
        phases: _convertToProjectPhases(phases),
        metadata: ProjectMetadata(
          type: ProjectType.mobile,
          priority: Priority.medium,
          estimatedHours: phases.fold(0.0, (sum, phase) => sum + (phase.estimatedDays.toDouble() * 8.0)),
          teamId: null,
          customFields: {
            'contextAnswers': contextAnswers,
            'totalEstimatedDays': phases.fold(0, (sum, phase) => sum + phase.estimatedDays.toInt()),
            'generatedWithAI': true,
            'generationTimestamp': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Save to Firebase
      await _firebaseService.saveProject(project);

      // Handle document upload if exists
      if (document != null) {
        try {
          final projectDocument = await _documentService.uploadDocumentToFirebase(
            document: document,
            projectId: projectId,
            uploadedBy: _currentUserId,
            type: context_models.DocumentType.requirement,
            description: 'Context document uploaded during project creation',
          );

          // Save project context
          final contextQuestions = contextAnswers.entries.map((entry) {
            return context_models.ContextQuestion(
              id: _generateId(),
              question: entry.key,
              answer: entry.value.toString(),
              type: context_models.ContextQuestionType.other,
              answeredAt: DateTime.now(),
              isRequired: false,
            );
          }).toList();

          final projectContext = context_models.ProjectContext(
            projectId: projectId,
            contextQuestions: contextQuestions,
            documents: [projectDocument],
            lastUpdated: DateTime.now(),
            summary: null,
          );

          await _firebaseService.saveProjectContext(projectContext);
        } catch (e) {
          print('Warning: Failed to upload document: $e');
        }
      }

      // Update project list in main provider
      ref.read(projectNotifierProvider.notifier).loadProjects();

      // Complete generation (100% progress)
      state = AsyncValue.data(GenerationProgress(
        currentStep: GenerationStep.completed,
        message: 'Project generation completed successfully!',
        completedSteps: [
          'Project analysis completed',
          'Phase structure created',
          'Detailed tasks generated',
          'Project saved to database'
        ],
        progress: 1.0,
        projectId: projectId,
        isCompleted: true,
      ));

      return projectId;

    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  void _updateProgress(
    GenerationStep step,
    String message,
    List<String> completedSteps,
    double progress,
  ) {
    if (mounted) {
      state = AsyncValue.data(GenerationProgress(
        currentStep: step,
        message: message,
        completedSteps: List.from(completedSteps),
        progress: progress,
      ));
    }
  }

  List<ProjectPhase> _convertToProjectPhases(List<claude_service.ProjectPhaseBreakdown> phases) {
    return phases.map((phaseBreakdown) {
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

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _extractTitle(String description) {
    if (description.isEmpty) {
      return 'Untitled Project';
    }
    
    final sentences = description.split('.');
    if (sentences.isNotEmpty && sentences.first.trim().isNotEmpty && sentences.first.length <= 50) {
      return sentences.first.trim();
    }
    
    if (description.length <= 50) {
      return description.trim();
    } else {
      final maxLength = description.length > 47 ? 47 : description.length;
      return '${description.substring(0, maxLength)}...';
    }
  }

  void reset() {
    state = const AsyncValue.loading();
  }
}

// Providers
final projectGenerationProvider = StateNotifierProvider<ProjectGenerationNotifier, AsyncValue<GenerationProgress>>((ref) {
  final claudeService = ref.watch(claudeAIServiceProvider);
  final firebaseService = ref.watch(firebaseServiceProvider);
  final documentService = ref.watch(documentServiceProvider);
  return ProjectGenerationNotifier(claudeService, firebaseService, documentService, ref);
});