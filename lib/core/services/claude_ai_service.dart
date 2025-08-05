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
    print('  API key: ${apiKey.length >= 10 ? '${apiKey.substring(0, 10)}...' : 'API_KEY_TOO_SHORT'}');
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
      final response = await _makeApiRequestWithRetry(() => _dio.post(
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
      ));
      
      final content = response.data['content'][0]['text'];
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw Exception('Invalid JSON response from Claude API');
      }
      
      final jsonString = content.substring(jsonStart, jsonEnd);
      
      return ProjectAssessment.fromJson(Map<String, dynamic>.from(
        jsonDecode(jsonString)
      ));
    } catch (e) {
      // Enhanced error handling with better user messaging
      String errorMessage = 'Claude AI API error';
      
      if (e is DioException && e.response?.statusCode == 529) {
        errorMessage = 'Claude AI servers are temporarily overloaded. Using demo mode for now.';
      } else if (e is DioException) {
        errorMessage = 'Claude AI API error (${e.response?.statusCode}). Using demo mode.';
      }
      
      if (AppConstants.isProduction) {
        // TODO: Log to production error tracking service (Crashlytics, Sentry, etc.)
        print('$errorMessage (Production)');
      } else {
        print('$errorMessage: $e');
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
      final response = await _makeApiRequestWithRetry(() => _dio.post(
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
      ));
      
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
    Map<String, dynamic> contextAnswers, {
    String? documentContent,
  }) async {
    // Demo mode or no valid API key - return mock data
    if (AppConstants.useDemoMode || !AppConstants.hasValidApiKey) {
      await Future.delayed(const Duration(seconds: 3)); // Simulate API delay
      return _createMockProjectBreakdown(projectDescription);
    }

    print('🚀 Starting enhanced multi-step project generation...');
    
    // Step 1: Enhanced Project Analysis with Full Context
    final projectAnalysis = await _analyzeProjectWithFullContext(
      projectDescription, 
      contextAnswers, 
      documentContent
    );
    print('✅ Step 1: Project analysis completed');
    
    // Step 2: Generate Phase Structure
    final phaseStructure = await _generatePhaseStructure(
      projectDescription,
      contextAnswers,
      documentContent,
      projectAnalysis,
    );
    print('✅ Step 2: Phase structure generated with ${phaseStructure.length} phases');
    
    // Step 3: Generate Detailed Tasks for Each Phase
    final phases = <ProjectPhaseBreakdown>[];
    for (int i = 0; i < phaseStructure.length; i++) {
      final phase = phaseStructure[i];
      print('🔄 Step 3.${i+1}: Generating tasks for phase "${phase.name}"...');
      
      final detailedPhase = await _generatePhaseWithDetailedTasks(
        phase,
        projectDescription,
        contextAnswers,
        documentContent,
        projectAnalysis,
        phases, // Previously generated phases for context
      );
      phases.add(detailedPhase);
      print('✅ Generated ${detailedPhase.tasks.length} tasks for "${phase.name}"');
    }
    
    print('🎉 Enhanced project generation completed with ${phases.length} phases');
    
    return ProjectBreakdown(
      phases: phases,
      totalEstimatedDays: phases.fold(0, (sum, phase) => sum + phase.estimatedDays),
      recommendations: [
        'Review and adjust task dependencies as needed',
        'Consider adding buffer time for complex phases',
        'Regular team check-ins to track progress'
      ],
    );
  }

  // Original single-call method kept for backward compatibility
  Future<ProjectBreakdown> generateProjectBreakdownLegacy(
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
      final response = await _makeApiRequestWithRetry(() => _dio.post(
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
      ));
      
      final content = response.data['content'][0]['text'];
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw Exception('Invalid JSON response from Claude API');
      }
      
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

  // ENHANCED MULTI-STEP PROJECT GENERATION METHODS

  /// Step 1: Analyze project with full context including documents
  Future<ProjectAnalysis> _analyzeProjectWithFullContext(
    String projectDescription,
    Map<String, dynamic> contextAnswers,
    String? documentContent,
  ) async {
    final prompt = '''
Analyze this project comprehensively with all available context:

## Project Description
${projectDescription}

## Context Information
${_formatContextAnswers(contextAnswers)}

${documentContent != null ? '## Additional Documentation\n${documentContent}\n' : ''}

Based on this complete information, provide a thorough analysis including:

1. **Project Type & Scope**: Detailed categorization and scope assessment
2. **Technical Requirements**: Technology stack, architecture patterns, infrastructure needs
3. **Complexity Assessment**: Overall difficulty rating (1-10) with justification
4. **Key Success Factors**: Critical elements that will determine project success
5. **Risk Analysis**: Potential challenges, dependencies, and mitigation strategies
6. **Resource Estimation**: Team size, skills required, timeline considerations
7. **Stakeholder Impact**: Who will be affected and how
8. **Business Value**: Expected outcomes and benefits

Format as JSON:
{
  "projectType": "string",
  "scope": "string",
  "technicalRequirements": {
    "technologies": ["tech1", "tech2"],
    "architecture": "string",
    "infrastructure": ["req1", "req2"]
  },
  "complexity": {
    "rating": number,
    "justification": "string",
    "challenges": ["challenge1", "challenge2"]
  },
  "successFactors": ["factor1", "factor2"],
  "risks": [
    {
      "risk": "string",
      "impact": "high|medium|low",
      "mitigation": "string"
    }
  ],
  "resources": {
    "teamSize": number,
    "skillsRequired": ["skill1", "skill2"],
    "estimatedDuration": "string"
  },
  "businessValue": {
    "outcomes": ["outcome1", "outcome2"],
    "benefits": ["benefit1", "benefit2"]
  }
}
''';

    try {
      final response = await _makeApiRequestWithRetry(() => _dio.post(
        ApiConstants.claudeMessages,
        data: {
          'model': AppConstants.claudeModel,
          'max_tokens': 2000,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        },
      ));
      
      final content = response.data['content'][0]['text'];
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw Exception('Invalid JSON response from Claude API');
      }
      
      final jsonString = content.substring(jsonStart, jsonEnd);
      return ProjectAnalysis.fromJson(jsonDecode(jsonString));
    } catch (e) {
      print('Error in project analysis: $e');
      return _createMockProjectAnalysis();
    }
  }

  /// Step 2: Generate phase structure based on analysis
  Future<List<PhaseStructure>> _generatePhaseStructure(
    String projectDescription,
    Map<String, dynamic> contextAnswers,
    String? documentContent,
    ProjectAnalysis analysis,
  ) async {
    final prompt = '''
Based on the comprehensive project analysis, create an optimal phase structure:

## Project Context
**Description**: ${projectDescription}
**Type**: ${analysis.projectType}
**Complexity**: ${analysis.complexity.rating}/10
**Technical Requirements**: ${analysis.technicalRequirements.technologies.join(', ')}

## Context Details
${_formatContextAnswers(contextAnswers)}

${documentContent != null ? '## Documentation\n${documentContent}\n' : ''}

## Analysis Summary
**Success Factors**: ${analysis.successFactors.join(', ')}
**Key Risks**: ${analysis.risks.map((r) => r.risk).join(', ')}

Create an optimal phase breakdown that:
1. Follows logical development progression
2. Manages risks identified in the analysis  
3. Delivers value incrementally
4. Accounts for dependencies and parallel work
5. Matches the project complexity and scope

Format as JSON:
{
  "phases": [
    {
      "id": "phase_id",
      "name": "Phase Name",
      "description": "Detailed phase description",
      "objectives": ["objective1", "objective2"],
      "deliverables": ["deliverable1", "deliverable2"], 
      "estimatedDays": number,
      "criticalPath": boolean,
      "dependencies": ["phase_id1", "phase_id2"],
      "risks": ["risk1", "risk2"]
    }
  ]
}
''';

    try {
      final response = await _makeApiRequestWithRetry(() => _dio.post(
        ApiConstants.claudeMessages,
        data: {
          'model': AppConstants.claudeModel,
          'max_tokens': 1500,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        },
      ));
      
      final content = response.data['content'][0]['text'];
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw Exception('Invalid JSON response from Claude API');
      }
      
      final jsonString = content.substring(jsonStart, jsonEnd);
      final result = jsonDecode(jsonString);
      
      return (result['phases'] as List)
          .map((phase) => PhaseStructure.fromJson(phase))
          .toList();
    } catch (e) {
      print('Error in phase structure generation: $e');
      return _createMockPhaseStructure();
    }
  }

  /// Step 3: Generate detailed tasks for a specific phase
  Future<ProjectPhaseBreakdown> _generatePhaseWithDetailedTasks(
    PhaseStructure phaseStructure,
    String projectDescription,
    Map<String, dynamic> contextAnswers,
    String? documentContent,
    ProjectAnalysis analysis,
    List<ProjectPhaseBreakdown> previousPhases,
  ) async {
    final previousPhaseSummary = previousPhases.map((p) => 
      '${p.name}: ${p.tasks.length} tasks planned'
    ).join(', ');

    final prompt = '''
Generate detailed, actionable tasks for this specific project phase:

## Project Context
**Description**: ${projectDescription}
**Type**: ${analysis.projectType}
**Technical Stack**: ${analysis.technicalRequirements.technologies.join(', ')}

## Target Phase
**Name**: ${phaseStructure.name}
**Description**: ${phaseStructure.description}
**Objectives**: ${phaseStructure.objectives.join(', ')}
**Deliverables**: ${phaseStructure.deliverables.join(', ')}
**Estimated Duration**: ${phaseStructure.estimatedDays} days

## Context Information
${_formatContextAnswers(contextAnswers)}

${documentContent != null ? '## Documentation Reference\n${documentContent}\n' : ''}

## Previous Phases Context
${previousPhases.isNotEmpty ? previousPhaseSummary : 'This is the first phase'}

## Analysis Insights
**Key Risks for this Phase**: ${phaseStructure.risks.join(', ')}
**Success Factors**: ${analysis.successFactors.join(', ')}

Create detailed, actionable tasks that:
1. Directly contribute to phase objectives and deliverables
2. Are properly sized (4-40 hours each)
3. Have clear acceptance criteria
4. Include proper dependencies and sequencing
5. Account for the identified risks and requirements
6. Build upon work from previous phases
7. Follow industry best practices for ${analysis.projectType} projects

Format as JSON:
{
  "id": "${phaseStructure.id}",
  "name": "${phaseStructure.name}",
  "description": "${phaseStructure.description}",
  "estimatedDays": ${phaseStructure.estimatedDays},
  "tasks": [
    {
      "id": "task_id",
      "title": "Specific, actionable task title",
      "description": "Detailed description with acceptance criteria and implementation notes",
      "estimatedHours": number,
      "priority": "urgent|high|medium|low",
      "skillsRequired": ["skill1", "skill2"],
      "dependencies": ["task_id1", "task_id2"],
      "deliverables": ["deliverable1", "deliverable2"],
      "acceptanceCriteria": ["criteria1", "criteria2"]
    }
  ]
}
''';

    try {
      final response = await _makeApiRequestWithRetry(() => _dio.post(
        ApiConstants.claudeMessages,
        data: {
          'model': AppConstants.claudeModel,
          'max_tokens': 3000,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        },
      ));
      
      final content = response.data['content'][0]['text'];
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw Exception('Invalid JSON response from Claude API');
      }
      
      final jsonString = content.substring(jsonStart, jsonEnd);
      return EnhancedPhaseBreakdown.fromJson(jsonDecode(jsonString)).toProjectPhaseBreakdown();
    } catch (e) {
      print('Error generating tasks for phase ${phaseStructure.name}: $e');
      return _createMockPhaseBreakdown(phaseStructure);
    }
  }

  /// Helper method to format context answers for prompts
  String _formatContextAnswers(Map<String, dynamic> contextAnswers) {
    final buffer = StringBuffer();
    contextAnswers.forEach((key, value) {
      buffer.writeln('**${key}**: ${value}');
    });
    return buffer.toString();
  }

  /// Mock methods for error fallbacks
  ProjectAnalysis _createMockProjectAnalysis() {
    return ProjectAnalysis(
      projectType: 'mobile',
      scope: 'Medium-scale mobile application development',
      technicalRequirements: TechnicalRequirements(
        technologies: ['Flutter', 'Firebase', 'REST APIs'],
        architecture: 'Client-server with cloud backend',
        infrastructure: ['Firebase Hosting', 'Cloud Functions', 'Firestore'],
      ),
      complexity: ComplexityAssessment(
        rating: 7,
        justification: 'Moderate complexity with standard mobile features',
        challenges: ['User authentication', 'Real-time synchronization'],
      ),
      successFactors: ['Clear requirements', 'User feedback integration'],
      risks: [
        RiskAssessment(
          risk: 'Scope creep',
          impact: 'medium',
          mitigation: 'Regular stakeholder reviews',
        ),
      ],
      resources: ResourceEstimation(
        teamSize: 3,
        skillsRequired: ['Flutter', 'Backend development', 'UI/UX'],
        estimatedDuration: '3-4 months',
      ),
      businessValue: BusinessValue(
        outcomes: ['Improved user engagement', 'Streamlined processes'],
        benefits: ['Cost reduction', 'Scalability'],
      ),
    );
  }

  List<PhaseStructure> _createMockPhaseStructure() {
    return [
      PhaseStructure(
        id: 'phase_1',
        name: 'Project Foundation',
        description: 'Establish project foundation and requirements',
        objectives: ['Define requirements', 'Set up development environment'],
        deliverables: ['Requirements document', 'Development setup'],
        estimatedDays: 10,
        criticalPath: true,
        dependencies: [],
        risks: ['Unclear requirements'],
      ),
      PhaseStructure(
        id: 'phase_2', 
        name: 'Core Development',
        description: 'Implement core application features',
        objectives: ['Build main features', 'Integrate backend services'],
        deliverables: ['Working application', 'API integration'],
        estimatedDays: 20,
        criticalPath: true,
        dependencies: ['phase_1'],
        risks: ['Technical complexity'],
      ),
    ];
  }

  ProjectPhaseBreakdown _createMockPhaseBreakdown(PhaseStructure structure) {
    return ProjectPhaseBreakdown(
      id: structure.id,
      name: structure.name,
      description: structure.description,
      estimatedDays: structure.estimatedDays,
      tasks: [
        TaskBreakdown(
          id: '${structure.id}_task_1',
          title: 'Setup and planning for ${structure.name}',
          description: 'Initial setup and detailed planning',
          estimatedHours: 8.0,
          priority: 'high',
          dependencies: [],
        ),
      ],
    );
  }

  /// Helper method to make API requests with retry logic for temporary server errors
  Future<Response> _makeApiRequestWithRetry(Future<Response> Function() request, {int maxRetries = 3}) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempts++;
        
        if (e is DioException) {
          // Handle specific server errors that might be temporary
          if (e.response?.statusCode == 529 || // Server overloaded
              e.response?.statusCode == 502 || // Bad gateway
              e.response?.statusCode == 503 || // Service unavailable
              e.response?.statusCode == 504) { // Gateway timeout
            
            if (attempts < maxRetries) {
              final delay = Duration(seconds: attempts * 2); // Exponential backoff
              print('⚠️  API returned ${e.response?.statusCode}, retrying in ${delay.inSeconds}s (attempt $attempts/$maxRetries)');
              await Future.delayed(delay);
              continue;
            }
          }
        }
        
        // If not a retryable error or max attempts reached, rethrow
        rethrow;
      }
    }
    
    throw Exception('Max retry attempts reached');
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

// ENHANCED DATA CLASSES FOR MULTI-STEP GENERATION

@JsonSerializable()
class ProjectAnalysis {
  final String projectType;
  final String scope;
  final TechnicalRequirements technicalRequirements;
  final ComplexityAssessment complexity;
  final List<String> successFactors;
  final List<RiskAssessment> risks;
  final ResourceEstimation resources;
  final BusinessValue businessValue;

  const ProjectAnalysis({
    required this.projectType,
    required this.scope,
    required this.technicalRequirements,
    required this.complexity,
    required this.successFactors,
    required this.risks,
    required this.resources,
    required this.businessValue,
  });

  factory ProjectAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ProjectAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectAnalysisToJson(this);
}

@JsonSerializable()
class TechnicalRequirements {
  final List<String> technologies;
  final String architecture;
  final List<String> infrastructure;

  const TechnicalRequirements({
    required this.technologies,
    required this.architecture,
    required this.infrastructure,
  });

  factory TechnicalRequirements.fromJson(Map<String, dynamic> json) =>
      _$TechnicalRequirementsFromJson(json);
  Map<String, dynamic> toJson() => _$TechnicalRequirementsToJson(this);
}

@JsonSerializable()
class ComplexityAssessment {
  final int rating;
  final String justification;
  final List<String> challenges;

  const ComplexityAssessment({
    required this.rating,
    required this.justification,
    required this.challenges,
  });

  factory ComplexityAssessment.fromJson(Map<String, dynamic> json) =>
      _$ComplexityAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$ComplexityAssessmentToJson(this);
}

@JsonSerializable()
class RiskAssessment {
  final String risk;
  final String impact;
  final String mitigation;

  const RiskAssessment({
    required this.risk,
    required this.impact,
    required this.mitigation,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) =>
      _$RiskAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$RiskAssessmentToJson(this);
}

@JsonSerializable()
class ResourceEstimation {
  final int teamSize;
  final List<String> skillsRequired;
  final String estimatedDuration;

  const ResourceEstimation({
    required this.teamSize,
    required this.skillsRequired,
    required this.estimatedDuration,
  });

  factory ResourceEstimation.fromJson(Map<String, dynamic> json) =>
      _$ResourceEstimationFromJson(json);
  Map<String, dynamic> toJson() => _$ResourceEstimationToJson(this);
}

@JsonSerializable()
class BusinessValue {
  final List<String> outcomes;
  final List<String> benefits;

  const BusinessValue({
    required this.outcomes,
    required this.benefits,
  });

  factory BusinessValue.fromJson(Map<String, dynamic> json) =>
      _$BusinessValueFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessValueToJson(this);
}

@JsonSerializable()
class PhaseStructure {
  final String id;
  final String name;
  final String description;
  final List<String> objectives;
  final List<String> deliverables;
  final int estimatedDays;
  final bool criticalPath;
  final List<String> dependencies;
  final List<String> risks;

  const PhaseStructure({
    required this.id,
    required this.name,
    required this.description,
    required this.objectives,
    required this.deliverables,
    required this.estimatedDays,
    required this.criticalPath,
    required this.dependencies,
    required this.risks,
  });

  factory PhaseStructure.fromJson(Map<String, dynamic> json) =>
      _$PhaseStructureFromJson(json);
  Map<String, dynamic> toJson() => _$PhaseStructureToJson(this);
}

@JsonSerializable()
class EnhancedPhaseBreakdown {
  final String id;
  final String name;
  final String description;
  final int estimatedDays;
  final List<EnhancedTaskBreakdown> tasks;

  const EnhancedPhaseBreakdown({
    required this.id,
    required this.name,
    required this.description,
    required this.estimatedDays,
    required this.tasks,
  });

  factory EnhancedPhaseBreakdown.fromJson(Map<String, dynamic> json) =>
      _$EnhancedPhaseBreakdownFromJson(json);
  Map<String, dynamic> toJson() => _$EnhancedPhaseBreakdownToJson(this);

  // Convert to standard ProjectPhaseBreakdown for compatibility
  ProjectPhaseBreakdown toProjectPhaseBreakdown() {
    return ProjectPhaseBreakdown(
      id: id,
      name: name,
      description: description,
      estimatedDays: estimatedDays,
      tasks: tasks.map((task) => task.toTaskBreakdown()).toList(),
    );
  }
}

@JsonSerializable()
class EnhancedTaskBreakdown {
  final String id;
  final String title;
  final String description;
  final double estimatedHours;
  final String priority;
  final List<String> skillsRequired;
  final List<String> dependencies;
  final List<String> deliverables;
  final List<String> acceptanceCriteria;

  const EnhancedTaskBreakdown({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedHours,
    required this.priority,
    required this.skillsRequired,
    required this.dependencies,
    required this.deliverables,
    required this.acceptanceCriteria,
  });

  factory EnhancedTaskBreakdown.fromJson(Map<String, dynamic> json) =>
      _$EnhancedTaskBreakdownFromJson(json);
  Map<String, dynamic> toJson() => _$EnhancedTaskBreakdownToJson(this);

  // Convert to standard TaskBreakdown for compatibility
  TaskBreakdown toTaskBreakdown() {
    final enhancedDescription = '''
$description

**Skills Required**: ${skillsRequired.join(', ')}
**Deliverables**: ${deliverables.join(', ')}
**Acceptance Criteria**:
${acceptanceCriteria.map((criteria) => '• $criteria').join('\n')}
''';

    return TaskBreakdown(
      id: id,
      title: title,
      description: enhancedDescription,
      estimatedHours: estimatedHours,
      priority: priority,
      dependencies: dependencies,
    );
  }
}

class ClaudeAIException implements Exception {
  final String message;
  
  const ClaudeAIException(this.message);
  
  @override
  String toString() => 'ClaudeAIException: $message';
}