// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_ai_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectAssessment _$ProjectAssessmentFromJson(Map<String, dynamic> json) =>
    ProjectAssessment(
      projectType: json['projectType'] as String,
      complexity: (json['complexity'] as num).toInt(),
      phases:
          (json['phases'] as List<dynamic>).map((e) => e as String).toList(),
      contextQuestions: (json['contextQuestions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      risks: (json['risks'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ProjectAssessmentToJson(ProjectAssessment instance) =>
    <String, dynamic>{
      'projectType': instance.projectType,
      'complexity': instance.complexity,
      'phases': instance.phases,
      'contextQuestions': instance.contextQuestions,
      'risks': instance.risks,
    };

ContextQuestion _$ContextQuestionFromJson(Map<String, dynamic> json) =>
    ContextQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      type: $enumDecode(_$QuestionTypeEnumMap, json['type']),
      options:
          (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ContextQuestionToJson(ContextQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'type': _$QuestionTypeEnumMap[instance.type]!,
      'options': instance.options,
    };

const _$QuestionTypeEnumMap = {
  QuestionType.text: 'text',
  QuestionType.multipleChoice: 'multipleChoice',
  QuestionType.boolean: 'boolean',
};

ProjectBreakdown _$ProjectBreakdownFromJson(Map<String, dynamic> json) =>
    ProjectBreakdown(
      phases: (json['phases'] as List<dynamic>)
          .map((e) => ProjectPhaseBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalEstimatedDays: (json['totalEstimatedDays'] as num).toInt(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ProjectBreakdownToJson(ProjectBreakdown instance) =>
    <String, dynamic>{
      'phases': instance.phases,
      'totalEstimatedDays': instance.totalEstimatedDays,
      'recommendations': instance.recommendations,
    };

ProjectPhaseBreakdown _$ProjectPhaseBreakdownFromJson(
        Map<String, dynamic> json) =>
    ProjectPhaseBreakdown(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      estimatedDays: (json['estimatedDays'] as num).toInt(),
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => TaskBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProjectPhaseBreakdownToJson(
        ProjectPhaseBreakdown instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'estimatedDays': instance.estimatedDays,
      'tasks': instance.tasks,
    };

TaskBreakdown _$TaskBreakdownFromJson(Map<String, dynamic> json) =>
    TaskBreakdown(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      estimatedHours: (json['estimatedHours'] as num).toDouble(),
      priority: json['priority'] as String,
      dependencies: (json['dependencies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TaskBreakdownToJson(TaskBreakdown instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'estimatedHours': instance.estimatedHours,
      'priority': instance.priority,
      'dependencies': instance.dependencies,
    };
