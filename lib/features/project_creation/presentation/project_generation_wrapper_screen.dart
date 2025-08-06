import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'project_generation_progress_screen.dart';
import '../providers/project_provider.dart';
import '../../../core/services/document_service.dart';

class ProjectGenerationWrapperScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> generationData;
  
  const ProjectGenerationWrapperScreen({
    super.key,
    required this.generationData,
  });

  @override
  ConsumerState<ProjectGenerationWrapperScreen> createState() => _ProjectGenerationWrapperScreenState();
}

class _ProjectGenerationWrapperScreenState extends ConsumerState<ProjectGenerationWrapperScreen> {
  bool _isGenerating = false;
  String? _createdProjectId;
  GenerationStep _currentStep = GenerationStep.analyzing;
  String _currentMessage = '';
  String _currentPhaseDescription = '';
  List<String> _completedSteps = [];

  @override
  void initState() {
    super.initState();
    // Start project generation after the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateProject();
    });
  }

  Future<void> _generateProject() async {
    if (_isGenerating) return;
    
    setState(() {
      _isGenerating = true;
      _currentStep = GenerationStep.analyzing;
      _currentMessage = 'Analyzing project requirements with AI...';
      _currentPhaseDescription = 'Reading your project description...';
    });

    try {
      print('Starting project generation with context data...');
      
      final projectDescription = widget.generationData['projectDescription'] as String? ?? '';
      final contextAnswers = widget.generationData['contextAnswers'] as Map<String, dynamic>? ?? {};
      final documentUploadResult = widget.generationData['documentUploadResult'] as DocumentUploadResult?;
      final documentContent = widget.generationData['documentContent'] as String?;
      
      // Start project creation with progress tracking
      await _createProjectWithProgress(
        projectDescription,
        contextAnswers,
        documentUploadResult,
        documentContent,
      );
      
    } catch (error) {
      print('Error generating project: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create project: $error'),
            backgroundColor: Colors.red,
          ),
        );
        // Navigate back to dashboard on error
        context.go('/dashboard');
      }
    }
  }

  Future<void> _createProjectWithProgress(
    String projectDescription,
    Map<String, dynamic> contextAnswers,
    DocumentUploadResult? documentUploadResult,
    String? documentContent,
  ) async {
    
    // Step 1: Analyzing (2 seconds)
    await _updateStep(GenerationStep.analyzing, 'Analyzing project requirements with AI...', [
      'Reading your project description...',
      'Identifying key requirements...',
      'Understanding project scope...',
      'Analyzing complexity factors...',
      'Categorizing project type...',
    ], const Duration(seconds: 2));

    // Step 2: Structuring (2 seconds)  
    await _updateStep(GenerationStep.structuring, 'Creating optimal phase structure...', [
      'Creating project phases...',
      'Organizing workflow structure...',
      'Defining phase dependencies...',
      'Setting milestone markers...',
      'Optimizing phase distribution...',
    ], const Duration(seconds: 2));

    // Step 3: Detailing (3 seconds - this is where the heavy work happens)
    await _updateStep(GenerationStep.detailing, 'Generating detailed tasks and timelines...', [
      'Calling Claude AI for project breakdown...',
      'Generating detailed tasks...',
      'Estimating task durations...',
      'Creating task dependencies...',
      'Assigning priority levels...',
      'Adding task descriptions...',
    ], const Duration(seconds: 1));

    // This is where the actual project creation happens
    setState(() {
      _currentPhaseDescription = 'Creating project structure...';
    });
    
    final projectId = await ref.read(projectNotifierProvider.notifier).createProjectWithContext(
      projectDescription,
      contextAnswers,
      document: documentUploadResult,
      documentContent: documentContent,
    );
    
    print('Project created successfully with ID: $projectId');

    // Step 4: Finalizing (2 seconds)
    await _updateStep(GenerationStep.finalizing, 'Finalizing project breakdown...', [
      'Saving project to database...',
      'Organizing project phases...',
      'Finalizing task structure...',
      'Preparing project data...',
      'Completing generation...',
    ], const Duration(seconds: 2));

    // Step 5: Completed
    if (mounted) {
      setState(() {
        _completedSteps.add(_currentMessage);
        _currentStep = GenerationStep.completed;
        _currentMessage = 'Project generation completed!';
        _currentPhaseDescription = 'Project ready!';
        _createdProjectId = projectId;
      });
      
      // Wait for success animation then navigate
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        context.go('/tasks');
      }
    }
  }

  Future<void> _updateStep(
    GenerationStep step,
    String message,
    List<String> phaseDescriptions,
    Duration duration,
  ) async {
    if (!mounted) return;
    
    setState(() {
      if (_currentStep != GenerationStep.completed) {
        _completedSteps.add(_currentMessage);
      }
      _currentStep = step;
      _currentMessage = message;
      _currentPhaseDescription = phaseDescriptions.first;
    });

    // Cycle through phase descriptions
    final timePerDescription = Duration(
      milliseconds: duration.inMilliseconds ~/ phaseDescriptions.length,
    );

    for (int i = 0; i < phaseDescriptions.length; i++) {
      if (mounted) {
        setState(() {
          _currentPhaseDescription = phaseDescriptions[i];
        });
        await Future.delayed(timePerDescription);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProjectGenerationProgressScreen(
      projectId: _createdProjectId ?? '',
      projectTitle: widget.generationData['projectTitle'] as String? ?? 'New Project',
      currentStep: _currentStep,
      message: _currentMessage,
      completedSteps: _completedSteps,
      isCompleted: _createdProjectId != null,
      currentPhaseDescription: _currentPhaseDescription,
    );
  }
}