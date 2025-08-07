import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/claude_ai_service.dart';
import '../../../core/constants/app_constants.dart';

class ContextData {
  final ProjectAssessment assessment;
  final List<ContextQuestion> questions;
  
  const ContextData({
    required this.assessment,
    required this.questions,
  });
}

class ContextQuestionsNotifier extends StateNotifier<AsyncValue<ContextData>> {
  final ClaudeAIService _claudeService;
  
  ContextQuestionsNotifier(this._claudeService) : super(const AsyncValue.loading());

  Future<void> generateQuestions(
    String projectDescription, {
    String? documentContent,
    List<DocumentContextPoint>? extractedContext,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      print('Generating context questions for project...');
      print('Extracted context points: ${extractedContext?.length ?? 0}');
      
      // Step 1: Assess the project
      final assessment = await _claudeService.assessProject(
        projectDescription,
        documentContent: documentContent,
      );
      print('Project assessed: ${assessment.projectType}');
      
      // Step 2: Generate context questions based on assessment and existing context
      final questions = await _claudeService.generateContextQuestions(
        assessment,
        existingContext: extractedContext,
      );
      print('Generated ${questions.length} context questions');
      
      // Create context data with both assessment and questions
      final contextData = ContextData(
        assessment: assessment,
        questions: questions,
      );
      
      state = AsyncValue.data(contextData);
      
    } catch (error, stackTrace) {
      print('Error generating context questions: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void reset() {
    state = const AsyncValue.loading();
  }
}

// Provider for the context questions notifier
final contextQuestionsProvider = StateNotifierProvider<ContextQuestionsNotifier, AsyncValue<ContextData>>((ref) {
  final claudeService = ref.watch(claudeAIServiceProvider);
  return ContextQuestionsNotifier(claudeService);
});

// Provider for Claude AI service (reused from project_provider.dart)
final claudeAIServiceProvider = Provider<ClaudeAIService>((ref) {
  return ClaudeAIService(apiKey: AppConstants.claudeApiKey);
});