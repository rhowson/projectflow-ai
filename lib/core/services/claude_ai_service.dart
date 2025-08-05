import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import '../constants/app_constants.dart';
import '../constants/api_constants.dart';

part 'claude_ai_service.g.dart';

class ClaudeAIService {
  final Dio _dio;
  
  ClaudeAIService({required String apiKey}) : _dio = Dio() {
    _dio.options.baseUrl = AppConstants.claudeBaseUrl;
    _dio.options.headers[ApiConstants.authorizationHeader] = apiKey;
    _dio.options.headers[ApiConstants.contentTypeHeader] = ApiConstants.jsonContentType;
    _dio.options.headers[ApiConstants.anthropicVersionHeader] = AppConstants.claudeVersion;
    _dio.options.connectTimeout = AppConstants.connectionTimeout;
    _dio.options.receiveTimeout = AppConstants.receiveTimeout;
    _dio.options.sendTimeout = AppConstants.sendTimeout;
    
    // Debug logging for troubleshooting
    print('Claude AI Service initialized:');
    print('  API key: ${apiKey.substring(0, 10)}...');
    print('  Demo mode: ${AppConstants.useDemoMode}');
    print('  Has valid API key: ${AppConstants.hasValidApiKey}');
    print('  Environment: ${AppConstants.environment}');
    print('  Is production: ${AppConstants.isProduction}');
  }

  Future<ProjectAssessment> assessProject(String projectDescription, {String? documentContent}) async {
    // Demo mode or no valid API key - return mock data
    if (AppConstants.useDemoMode || !AppConstants.hasValidApiKey) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API delay
      return _createMockAssessment(projectDescription);
    }
    
    final prompt = '''
    Analyze this project description and provide a structured assessment:
    
    Project: {description}
    ${documentContent != null ? '\n\nAdditional Document Content:\n{documentContent}\n' : ''}
    
    Please provide:
    1. Project type and category
    2. Estimated complexity (1-10)
    3. Key phases needed
    4. Essential questions to gather context
    5. Potential risks and challenges
    
    Format the response as JSON with the following structure:
    {
      "projectType": "string",
      "complexity": number,
      "phases": ["phase1", "phase2"],
      "contextQuestions": ["question1", "question2"],
      "risks": ["risk1", "risk2"]
    }
    ''';

    try {
      final response = await _dio.post(
        ApiConstants.claudeMessages,
        data: {
          'model': AppConstants.claudeModel,
          'max_tokens': 1000,
          'messages': [
            {
              'role': 'user',
              'content': prompt
                  .replaceAll('{description}', projectDescription)
                  .replaceAll('{documentContent}', documentContent ?? ''),
            }
          ],
        },
      );
      
      final content = response.data['content'][0]['text'];
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      final jsonString = content.substring(jsonStart, jsonEnd);
      
      return ProjectAssessment.fromJson(Map<String, dynamic>.from(
        jsonDecode(jsonString)
      ));
    } catch (e) {
      // In production, log error and fallback to demo mode
      if (AppConstants.isProduction) {
        // TODO: Log to production error tracking service (Crashlytics, Sentry, etc.)
        print('Claude AI API error in production: $e');
      } else {
        print('Claude AI API error, falling back to demo mode: $e');
      }
      await Future.delayed(const Duration(seconds: 1));
      return _createMockAssessment(projectDescription);
    }
  }

  Future<List<ContextQuestion>> generateContextQuestions(
    ProjectAssessment assessment,
  ) async {
    print('🤖 Generating context questions:');
    print('  Demo mode: ${AppConstants.useDemoMode}');
    print('  Has valid key: ${AppConstants.hasValidApiKey}');
    print('  API key length: ${AppConstants.claudeApiKey.length}');
    print('  API key prefix: ${AppConstants.claudeApiKey.startsWith('sk-ant-api')}');
    
    // Demo mode or no valid API key - return mock data
    if (AppConstants.useDemoMode || !AppConstants.hasValidApiKey) {
      print('❌ Using DEMO MODE for context questions');
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
      return _createMockContextQuestions(assessment);
    }
    
    print('✅ Using LIVE API for context questions');
    
    const prompt = '''
    Based on this project assessment, generate 5-8 specific context questions that would help better understand the project requirements:
    
    Project Type: {projectType}
    Complexity: {complexity}
    Phases: {phases}
    
    Generate questions that are:
    1. Specific to the project type
    2. Help clarify requirements
    3. Identify constraints and preferences
    4. Understand target audience/users
    5. Determine technical requirements
    
    Format as JSON array:
    [
      {
        "id": "unique_id",
        "question": "Question text",
        "type": "text|multipleChoice|boolean",
        "options": ["option1", "option2"] // only for multipleChoice
      }
    ]
    ''';

    try {
      final response = await _dio.post(
        ApiConstants.claudeMessages,
        data: {
          'model': AppConstants.claudeModel,
          'max_tokens': 1200,
          'messages': [
            {
              'role': 'user',
              'content': prompt
                  .replaceAll('{projectType}', assessment.projectType)
                  .replaceAll('{complexity}', assessment.complexity.toString())
                  .replaceAll('{phases}', assessment.phases.join(', ')),
            }
          ],
        },
      );
      
      final content = response.data['content'][0]['text'];
      final jsonStart = content.indexOf('[');
      final jsonEnd = content.lastIndexOf(']') + 1;
      final jsonString = content.substring(jsonStart, jsonEnd);
      
      final List<dynamic> questionsJson = jsonDecode(jsonString);
      return questionsJson
          .map((json) => ContextQuestion.fromJson(json))
          .toList();
    } catch (e) {
      // Fallback to demo mode on API error
      print('Claude AI API error, falling back to demo mode: $e');
      await Future.delayed(const Duration(seconds: 1));
      return _createMockContextQuestions(assessment);
    }
  }

  Future<ProjectBreakdown> generateProjectBreakdown(
    String projectDescription,
    Map<String, dynamic> contextAnswers,
  ) async {
    // Demo mode or no valid API key - return mock data
    if (AppConstants.useDemoMode || !AppConstants.hasValidApiKey) {
      await Future.delayed(const Duration(seconds: 3)); // Simulate API delay
      return _createMockProjectBreakdown(projectDescription);
    }
    
    const prompt = '''
    Create a comprehensive project breakdown based on the description and context:
    
    Project Description: {description}
    Context Answers: {context}
    
    Provide a detailed breakdown including:
    1. Project phases with descriptions
    2. Tasks for each phase with estimates
    3. Dependencies between tasks
    4. Recommended timeline
    5. Resource requirements
    
    Format as JSON:
    {
      "phases": [
        {
          "id": "phase_id",
          "name": "Phase Name",
          "description": "Phase description",
          "estimatedDays": number,
          "tasks": [
            {
              "id": "task_id",
              "title": "Task title",
              "description": "Task description",
              "estimatedHours": number,
              "priority": "low|medium|high|urgent",
              "dependencies": ["task_id1", "task_id2"]
            }
          ]
        }
      ],
      "totalEstimatedDays": number,
      "recommendations": ["recommendation1", "recommendation2"]
    }
    ''';

    try {
      final response = await _dio.post(
        ApiConstants.claudeMessages,
        data: {
          'model': AppConstants.claudeModel,
          'max_tokens': 2000,
          'messages': [
            {
              'role': 'user',
              'content': prompt
                  .replaceAll('{description}', projectDescription)
                  .replaceAll('{context}', contextAnswers.toString()),
            }
          ],
        },
      );
      
      final content = response.data['content'][0]['text'];
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      final jsonString = content.substring(jsonStart, jsonEnd);
      
      return ProjectBreakdown.fromJson(Map<String, dynamic>.from(
        jsonDecode(jsonString)
      ));
    } catch (e) {
      // Fallback to demo mode on API error
      print('Claude AI API error, falling back to demo mode: $e');
      await Future.delayed(const Duration(seconds: 1));
      return _createMockProjectBreakdown(projectDescription);
    }
  }

  // Mock methods for demo mode
  ProjectAssessment _createMockAssessment(String description) {
    return const ProjectAssessment(
      projectType: 'mobile',
      complexity: 7,
      phases: [
        'Planning & Design',
        'Backend Development',
        'Frontend Development',
        'Testing & QA',
        'Deployment'
      ],
      contextQuestions: [
        'What platforms should we target?',
        'What is your expected timeline?',
        'Do you have existing design assets?'
      ],
      risks: [
        'Complex user authentication requirements',
        'Third-party API integration challenges',
        'Performance optimization for mobile devices'
      ],
    );
  }

  List<ContextQuestion> _createMockContextQuestions(ProjectAssessment assessment) {
    return const [
      ContextQuestion(
        id: 'q1',
        question: 'What platforms should the app support?',
        type: QuestionType.multipleChoice,
        options: ['iOS only', 'Android only', 'Both iOS and Android', 'Web as well'],
      ),
      ContextQuestion(
        id: 'q2',
        question: 'What is your expected timeline for completion?',
        type: QuestionType.multipleChoice,
        options: ['1-3 months', '3-6 months', '6-12 months', 'More than 12 months'],
      ),
      ContextQuestion(
        id: 'q3',
        question: 'Do you have existing design assets or wireframes?',
        type: QuestionType.boolean,
      ),
      ContextQuestion(
        id: 'q4',
        question: 'What is the expected number of users?',
        type: QuestionType.multipleChoice,
        options: ['< 1,000', '1,000 - 10,000', '10,000 - 100,000', '> 100,000'],
      ),
      ContextQuestion(
        id: 'q5',
        question: 'Do you need user authentication?',
        type: QuestionType.boolean,
      ),
    ];
  }

  ProjectBreakdown _createMockProjectBreakdown(String description) {
    return const ProjectBreakdown(
      phases: [
        ProjectPhaseBreakdown(
          id: 'phase_1',
          name: 'Planning & Design',
          description: 'Project planning, wireframing, and UI/UX design',
          estimatedDays: 14,
          tasks: [
            TaskBreakdown(
              id: 'task_1_1',
              title: 'Create project wireframes',
              description: 'Design wireframes for all main screens',
              estimatedHours: 16.0,
              priority: 'high',
              dependencies: [],
            ),
            TaskBreakdown(
              id: 'task_1_2',
              title: 'Design UI components',
              description: 'Create reusable UI components and design system',
              estimatedHours: 24.0,
              priority: 'high',
              dependencies: ['task_1_1'],
            ),
            TaskBreakdown(
              id: 'task_1_3',
              title: 'Technical architecture planning',
              description: 'Plan the technical architecture and technology stack',
              estimatedHours: 12.0,
              priority: 'high',
              dependencies: [],
            ),
          ],
        ),
        ProjectPhaseBreakdown(
          id: 'phase_2',
          name: 'Backend Development',
          description: 'Server-side development, database setup, and API creation',
          estimatedDays: 21,
          tasks: [
            TaskBreakdown(
              id: 'task_2_1',
              title: 'Set up database',
              description: 'Design and implement database schema',
              estimatedHours: 16.0,
              priority: 'high',
              dependencies: ['task_1_3'],
            ),
            TaskBreakdown(
              id: 'task_2_2',
              title: 'Implement user authentication',
              description: 'Create user registration and login system',
              estimatedHours: 20.0,
              priority: 'high',
              dependencies: ['task_2_1'],
            ),
            TaskBreakdown(
              id: 'task_2_3',
              title: 'Create REST APIs',
              description: 'Implement core API endpoints',
              estimatedHours: 32.0,
              priority: 'high',
              dependencies: ['task_2_1'],
            ),
          ],
        ),
        ProjectPhaseBreakdown(
          id: 'phase_3',
          name: 'Frontend Development',
          description: 'Mobile app development and UI implementation',
          estimatedDays: 28,
          tasks: [
            TaskBreakdown(
              id: 'task_3_1',
              title: 'Set up Flutter project',
              description: 'Initialize Flutter project with necessary dependencies',
              estimatedHours: 8.0,
              priority: 'high',
              dependencies: ['task_1_2'],
            ),
            TaskBreakdown(
              id: 'task_3_2',
              title: 'Implement authentication screens',
              description: 'Create login and registration screens',
              estimatedHours: 20.0,
              priority: 'high',
              dependencies: ['task_3_1', 'task_2_2'],
            ),
            TaskBreakdown(
              id: 'task_3_3',
              title: 'Implement main features',
              description: 'Build core app functionality',
              estimatedHours: 48.0,
              priority: 'high',
              dependencies: ['task_3_1', 'task_2_3'],
            ),
          ],
        ),
      ],
      totalEstimatedDays: 63,
      recommendations: [
        'Consider using Firebase for faster backend setup',
        'Implement comprehensive error handling',
        'Plan for offline functionality from the beginning',
        'Set up continuous integration early',
      ],
    );
  }
}

@JsonSerializable()
class ProjectAssessment {
  final String projectType;
  final int complexity;
  final List<String> phases;
  final List<String> contextQuestions;
  final List<String> risks;
  
  const ProjectAssessment({
    required this.projectType,
    required this.complexity,
    required this.phases,
    required this.contextQuestions,
    required this.risks,
  });
  
  factory ProjectAssessment.fromJson(Map<String, dynamic> json) =>
      _$ProjectAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectAssessmentToJson(this);
}

@JsonSerializable()
class ContextQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<String>? options;
  
  const ContextQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
  });
  
  factory ContextQuestion.fromJson(Map<String, dynamic> json) =>
      _$ContextQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$ContextQuestionToJson(this);
}

enum QuestionType { text, multipleChoice, boolean }

@JsonSerializable()
class ProjectBreakdown {
  final List<ProjectPhaseBreakdown> phases;
  final int totalEstimatedDays;
  final List<String> recommendations;
  
  const ProjectBreakdown({
    required this.phases,
    required this.totalEstimatedDays,
    required this.recommendations,
  });
  
  factory ProjectBreakdown.fromJson(Map<String, dynamic> json) =>
      _$ProjectBreakdownFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectBreakdownToJson(this);
}

@JsonSerializable()
class ProjectPhaseBreakdown {
  final String id;
  final String name;
  final String description;
  final int estimatedDays;
  final List<TaskBreakdown> tasks;
  
  const ProjectPhaseBreakdown({
    required this.id,
    required this.name,
    required this.description,
    required this.estimatedDays,
    required this.tasks,
  });
  
  factory ProjectPhaseBreakdown.fromJson(Map<String, dynamic> json) =>
      _$ProjectPhaseBreakdownFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectPhaseBreakdownToJson(this);
}

@JsonSerializable()
class TaskBreakdown {
  final String id;
  final String title;
  final String description;
  final double estimatedHours;
  final String priority;
  final List<String> dependencies;
  
  const TaskBreakdown({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedHours,
    required this.priority,
    required this.dependencies,
  });
  
  factory TaskBreakdown.fromJson(Map<String, dynamic> json) =>
      _$TaskBreakdownFromJson(json);
  Map<String, dynamic> toJson() => _$TaskBreakdownToJson(this);
}

class ClaudeAIException implements Exception {
  final String message;
  
  const ClaudeAIException(this.message);
  
  @override
  String toString() => 'ClaudeAIException: $message';
}