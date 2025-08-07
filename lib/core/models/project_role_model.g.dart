// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_role_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectRole _$ProjectRoleFromJson(Map<String, dynamic> json) => ProjectRole(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      color: json['color'] as String,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isAssignable: json['isAssignable'] as bool,
      isAIGenerated: json['isAIGenerated'] as bool,
      priority: (json['priority'] as num).toInt(),
      createdAt: const DateTimeConverter().fromJson(json['createdAt']),
      createdBy: json['createdBy'] as String,
      requiredSkills: (json['requiredSkills'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      timeCommitment: (json['timeCommitment'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProjectRoleToJson(ProjectRole instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'name': instance.name,
      'description': instance.description,
      'color': instance.color,
      'permissions': instance.permissions,
      'isAssignable': instance.isAssignable,
      'isAIGenerated': instance.isAIGenerated,
      'priority': instance.priority,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'createdBy': instance.createdBy,
      'requiredSkills': instance.requiredSkills,
      'timeCommitment': instance.timeCommitment,
    };

ProjectRoleAssignment _$ProjectRoleAssignmentFromJson(
        Map<String, dynamic> json) =>
    ProjectRoleAssignment(
      id: json['id'] as String,
      projectRoleId: json['projectRoleId'] as String,
      userId: json['userId'] as String,
      projectId: json['projectId'] as String,
      assignedAt: const DateTimeConverter().fromJson(json['assignedAt']),
      assignedBy: json['assignedBy'] as String,
      status: $enumDecode(_$AssignmentStatusEnumMap, json['status']),
      customTitle: json['customTitle'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ProjectRoleAssignmentToJson(
        ProjectRoleAssignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectRoleId': instance.projectRoleId,
      'userId': instance.userId,
      'projectId': instance.projectId,
      'assignedAt': const DateTimeConverter().toJson(instance.assignedAt),
      'assignedBy': instance.assignedBy,
      'status': _$AssignmentStatusEnumMap[instance.status]!,
      'customTitle': instance.customTitle,
      'notes': instance.notes,
    };

const _$AssignmentStatusEnumMap = {
  AssignmentStatus.active: 'active',
  AssignmentStatus.pending: 'pending',
  AssignmentStatus.inactive: 'inactive',
  AssignmentStatus.completed: 'completed',
};

AIRoleSuggestion _$AIRoleSuggestionFromJson(Map<String, dynamic> json) =>
    AIRoleSuggestion(
      name: json['name'] as String,
      description: json['description'] as String,
      requiredSkills: (json['requiredSkills'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      reasoning: json['reasoning'] as String,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      suggestedColor: json['suggestedColor'] as String,
      priority: (json['priority'] as num).toInt(),
      timeCommitment: (json['timeCommitment'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AIRoleSuggestionToJson(AIRoleSuggestion instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'requiredSkills': instance.requiredSkills,
      'reasoning': instance.reasoning,
      'permissions': instance.permissions,
      'suggestedColor': instance.suggestedColor,
      'priority': instance.priority,
      'timeCommitment': instance.timeCommitment,
    };
