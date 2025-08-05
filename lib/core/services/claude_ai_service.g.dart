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

ProjectAnalysis _$ProjectAnalysisFromJson(Map<String, dynamic> json) =>
    ProjectAnalysis(
      projectType: json['projectType'] as String,
      scope: json['scope'] as String,
      technicalRequirements: TechnicalRequirements.fromJson(
          json['technicalRequirements'] as Map<String, dynamic>),
      complexity: ComplexityAssessment.fromJson(
          json['complexity'] as Map<String, dynamic>),
      successFactors: (json['successFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      risks: (json['risks'] as List<dynamic>)
          .map((e) => RiskAssessment.fromJson(e as Map<String, dynamic>))
          .toList(),
      resources: ResourceEstimation.fromJson(
          json['resources'] as Map<String, dynamic>),
      businessValue:
          BusinessValue.fromJson(json['businessValue'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectAnalysisToJson(ProjectAnalysis instance) =>
    <String, dynamic>{
      'projectType': instance.projectType,
      'scope': instance.scope,
      'technicalRequirements': instance.technicalRequirements,
      'complexity': instance.complexity,
      'successFactors': instance.successFactors,
      'risks': instance.risks,
      'resources': instance.resources,
      'businessValue': instance.businessValue,
    };

TechnicalRequirements _$TechnicalRequirementsFromJson(
        Map<String, dynamic> json) =>
    TechnicalRequirements(
      technologies: (json['technologies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      architecture: json['architecture'] as String,
      infrastructure: (json['infrastructure'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TechnicalRequirementsToJson(
        TechnicalRequirements instance) =>
    <String, dynamic>{
      'technologies': instance.technologies,
      'architecture': instance.architecture,
      'infrastructure': instance.infrastructure,
    };

ComplexityAssessment _$ComplexityAssessmentFromJson(
        Map<String, dynamic> json) =>
    ComplexityAssessment(
      rating: (json['rating'] as num).toInt(),
      justification: json['justification'] as String,
      challenges: (json['challenges'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ComplexityAssessmentToJson(
        ComplexityAssessment instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'justification': instance.justification,
      'challenges': instance.challenges,
    };

RiskAssessment _$RiskAssessmentFromJson(Map<String, dynamic> json) =>
    RiskAssessment(
      risk: json['risk'] as String,
      impact: json['impact'] as String,
      mitigation: json['mitigation'] as String,
    );

Map<String, dynamic> _$RiskAssessmentToJson(RiskAssessment instance) =>
    <String, dynamic>{
      'risk': instance.risk,
      'impact': instance.impact,
      'mitigation': instance.mitigation,
    };

ResourceEstimation _$ResourceEstimationFromJson(Map<String, dynamic> json) =>
    ResourceEstimation(
      teamSize: (json['teamSize'] as num).toInt(),
      skillsRequired: (json['skillsRequired'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      estimatedDuration: json['estimatedDuration'] as String,
    );

Map<String, dynamic> _$ResourceEstimationToJson(ResourceEstimation instance) =>
    <String, dynamic>{
      'teamSize': instance.teamSize,
      'skillsRequired': instance.skillsRequired,
      'estimatedDuration': instance.estimatedDuration,
    };

BusinessValue _$BusinessValueFromJson(Map<String, dynamic> json) =>
    BusinessValue(
      outcomes:
          (json['outcomes'] as List<dynamic>).map((e) => e as String).toList(),
      benefits:
          (json['benefits'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$BusinessValueToJson(BusinessValue instance) =>
    <String, dynamic>{
      'outcomes': instance.outcomes,
      'benefits': instance.benefits,
    };

PhaseStructure _$PhaseStructureFromJson(Map<String, dynamic> json) =>
    PhaseStructure(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      objectives: (json['objectives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      deliverables: (json['deliverables'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      estimatedDays: (json['estimatedDays'] as num).toInt(),
      criticalPath: json['criticalPath'] as bool,
      dependencies: (json['dependencies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      risks: (json['risks'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$PhaseStructureToJson(PhaseStructure instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'objectives': instance.objectives,
      'deliverables': instance.deliverables,
      'estimatedDays': instance.estimatedDays,
      'criticalPath': instance.criticalPath,
      'dependencies': instance.dependencies,
      'risks': instance.risks,
    };

EnhancedPhaseBreakdown _$EnhancedPhaseBreakdownFromJson(
        Map<String, dynamic> json) =>
    EnhancedPhaseBreakdown(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      estimatedDays: (json['estimatedDays'] as num).toInt(),
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => EnhancedTaskBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EnhancedPhaseBreakdownToJson(
        EnhancedPhaseBreakdown instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'estimatedDays': instance.estimatedDays,
      'tasks': instance.tasks,
    };

EnhancedTaskBreakdown _$EnhancedTaskBreakdownFromJson(
        Map<String, dynamic> json) =>
    EnhancedTaskBreakdown(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      estimatedHours: (json['estimatedHours'] as num).toDouble(),
      priority: json['priority'] as String,
      skillsRequired: (json['skillsRequired'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dependencies: (json['dependencies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      deliverables: (json['deliverables'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      acceptanceCriteria: (json['acceptanceCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$EnhancedTaskBreakdownToJson(
        EnhancedTaskBreakdown instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'estimatedHours': instance.estimatedHours,
      'priority': instance.priority,
      'skillsRequired': instance.skillsRequired,
      'dependencies': instance.dependencies,
      'deliverables': instance.deliverables,
      'acceptanceCriteria': instance.acceptanceCriteria,
    };
