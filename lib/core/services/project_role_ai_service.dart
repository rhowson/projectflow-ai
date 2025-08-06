import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/project_model.dart';
import '../models/project_role_model.dart';

class ProjectRoleAIService {
  static const String baseUrl = 'https://api.anthropic.com/v1';
  final Dio _dio;

  ProjectRoleAIService({required String apiKey}) : _dio = Dio() {
    _dio.options.headers['Authorization'] = 'Bearer $apiKey';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['anthropic-version'] = '2023-06-01';
  }

  /// Generate project roles based on project details using AI
  Future<List<AIRoleSuggestion>> generateProjectRoles(Project project) async {
    const prompt = '''
    Analyze this project and suggest specific project roles that would be needed to successfully complete it.

    Project Details:
    - Title: {title}
    - Description: {description}
    - Type: {projectType}
    - Phases: {phases}
    - Estimated Complexity: {complexity}

    Please analyze the project and suggest 3-8 specific roles that would be essential for this project. For each role, provide:

    1. Role Name (specific to the project context)
    2. Description (what this role does in THIS specific project)
    3. Required Skills (3-5 key skills)
    4. Reasoning (why this role is needed for this specific project)
    5. Permissions (from: view_project, edit_tasks, manage_team, create_phases, delete_tasks, manage_deadlines, view_reports, manage_files)
    6. Suggested Color (hex color appropriate for the role)
    7. Priority (1=most critical, 10=least critical)
    8. Time Commitment (hours per week estimate)

    Format as JSON array:
    [
      {
        "name": "Role Name",
        "description": "Role description specific to this project",
        "requiredSkills": ["skill1", "skill2", "skill3"],
        "reasoning": "Why this role is essential for this project",
        "permissions": ["permission1", "permission2"],
        "suggestedColor": "#HEX_COLOR",
        "priority": 1,
        "timeCommitment": 20.0
      }
    ]

    Focus on roles that are:
    - Specific to this project type and scope
    - Actually needed based on the project phases and complexity
    - Realistic for the project size
    - Clear in their responsibilities
    ''';

    // Extract project details
    final projectType = project.metadata.type?.toString().split('.').last ?? 'General';
    final phases = project.phases.map((p) => p.name).join(', ');
    final complexity = project.metadata.estimatedHours / 40; // Rough complexity indicator

    final formattedPrompt = prompt
        .replaceAll('{title}', project.title)
        .replaceAll('{description}', project.description)
        .replaceAll('{projectType}', projectType)
        .replaceAll('{phases}', phases)
        .replaceAll('{complexity}', complexity.toStringAsFixed(1));

    try {
      final response = await _dio.post(
        '$baseUrl/messages',
        data: {
          'model': 'claude-3-sonnet-20240229',
          'max_tokens': 2000,
          'messages': [
            {
              'role': 'user',
              'content': formattedPrompt,
            }
          ],
        },
      );

      // Extract the JSON from Claude's response
      final content = response.data['content'][0]['text'] as String;
      
      // Find JSON array in the response
      final jsonStart = content.indexOf('[');
      final jsonEnd = content.lastIndexOf(']') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('No valid JSON found in AI response');
      }
      
      final jsonString = content.substring(jsonStart, jsonEnd);
      final List<dynamic> rolesJson = jsonDecode(jsonString);
      
      return rolesJson.map((json) => AIRoleSuggestion.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error generating roles: $e');
      // Return fallback roles based on project type
      return _getFallbackRoles(project);
    }
  }

  /// Generate roles for a specific project phase
  Future<List<AIRoleSuggestion>> generatePhaseSpecificRoles(
    Project project,
    ProjectPhase phase,
  ) async {
    const prompt = '''
    For this specific project phase, suggest specialized roles that would be needed:

    Project: {title}
    Phase: {phaseName}
    Phase Description: {phaseDescription}
    Tasks in Phase: {tasks}

    Suggest 2-4 specialized roles needed specifically for this phase. Focus on:
    - Phase-specific responsibilities
    - Skills needed for this particular phase
    - Realistic time commitments for this phase duration

    Format as JSON array with the same structure as before.
    ''';

    final tasks = phase.tasks.map((t) => t.title).join(', ');
    final formattedPrompt = prompt
        .replaceAll('{title}', project.title)
        .replaceAll('{phaseName}', phase.name)
        .replaceAll('{phaseDescription}', phase.description)
        .replaceAll('{tasks}', tasks);

    try {
      final response = await _dio.post(
        '$baseUrl/messages',
        data: {
          'model': 'claude-3-sonnet-20240229',
          'max_tokens': 1500,
          'messages': [
            {
              'role': 'user',
              'content': formattedPrompt,
            }
          ],
        },
      );

      final content = response.data['content'][0]['text'] as String;
      final jsonStart = content.indexOf('[');
      final jsonEnd = content.lastIndexOf(']') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('No valid JSON found in AI response');
      }
      
      final jsonString = content.substring(jsonStart, jsonEnd);
      final List<dynamic> rolesJson = jsonDecode(jsonString);
      
      return rolesJson.map((json) => AIRoleSuggestion.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error generating phase roles: $e');
      return _getFallbackPhaseRoles(phase);
    }
  }

  /// Fallback roles when AI generation fails
  List<AIRoleSuggestion> _getFallbackRoles(Project project) {
    return [
      AIRoleSuggestion(
        name: 'Project Manager',
        description: 'Oversees project execution, manages timelines, and coordinates team activities',
        requiredSkills: ['Project Management', 'Communication', 'Planning'],
        reasoning: 'Every project needs someone to coordinate activities and manage progress',
        permissions: ['view_project', 'edit_tasks', 'manage_team', 'create_phases', 'manage_deadlines', 'view_reports'],
        suggestedColor: '#7B68EE',
        priority: 1,
        timeCommitment: 25.0,
      ),
      AIRoleSuggestion(
        name: 'Lead Developer',
        description: 'Leads technical implementation and guides development decisions',
        requiredSkills: ['Technical Leadership', 'Development', 'Architecture'],
        reasoning: 'Technical projects require someone to lead development efforts',
        permissions: ['view_project', 'edit_tasks', 'manage_files', 'view_reports'],
        suggestedColor: '#10B981',
        priority: 2,
        timeCommitment: 30.0,
      ),
      AIRoleSuggestion(
        name: 'Quality Assurance',
        description: 'Ensures deliverables meet quality standards and requirements',
        requiredSkills: ['Testing', 'Quality Control', 'Attention to Detail'],
        reasoning: 'Quality control is essential for project success',
        permissions: ['view_project', 'edit_tasks', 'view_reports'],
        suggestedColor: '#F59E0B',
        priority: 3,
        timeCommitment: 15.0,
      ),
    ];
  }

  /// Fallback phase-specific roles
  List<AIRoleSuggestion> _getFallbackPhaseRoles(ProjectPhase phase) {
    return [
      AIRoleSuggestion(
        name: '${phase.name} Specialist',
        description: 'Specialist focused on ${phase.name.toLowerCase()} activities',
        requiredSkills: ['Specialization', 'Execution', 'Quality'],
        reasoning: 'This phase requires specialized attention',
        permissions: ['view_project', 'edit_tasks'],
        suggestedColor: '#6366F1',
        priority: 1,
        timeCommitment: 20.0,
      ),
    ];
  }
}

class ProjectRoleAIException implements Exception {
  final String message;
  ProjectRoleAIException(this.message);

  @override
  String toString() => 'ProjectRoleAIException: $message';
}