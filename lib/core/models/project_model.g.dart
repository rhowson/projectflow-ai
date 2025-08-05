// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: $enumDecode(_$ProjectStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      ownerId: json['ownerId'] as String,
      teamMemberIds: (json['teamMemberIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      phases: (json['phases'] as List<dynamic>)
          .map((e) => ProjectPhase.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata:
          ProjectMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': _$ProjectStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'ownerId': instance.ownerId,
      'teamMemberIds': instance.teamMemberIds,
      'phases': instance.phases,
      'metadata': instance.metadata,
    };

const _$ProjectStatusEnumMap = {
  ProjectStatus.planning: 'planning',
  ProjectStatus.inProgress: 'inProgress',
  ProjectStatus.completed: 'completed',
  ProjectStatus.onHold: 'onHold',
  ProjectStatus.cancelled: 'cancelled',
};

ProjectPhase _$ProjectPhaseFromJson(Map<String, dynamic> json) => ProjectPhase(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecode(_$PhaseStatusEnumMap, json['status']),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$ProjectPhaseToJson(ProjectPhase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'tasks': instance.tasks,
      'status': _$PhaseStatusEnumMap[instance.status]!,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
    };

const _$PhaseStatusEnumMap = {
  PhaseStatus.notStarted: 'notStarted',
  PhaseStatus.inProgress: 'inProgress',
  PhaseStatus.completed: 'completed',
  PhaseStatus.onHold: 'onHold',
};

ProjectMetadata _$ProjectMetadataFromJson(Map<String, dynamic> json) =>
    ProjectMetadata(
      type: $enumDecode(_$ProjectTypeEnumMap, json['type']),
      priority: $enumDecode(_$PriorityEnumMap, json['priority']),
      estimatedHours: (json['estimatedHours'] as num).toDouble(),
      teamId: json['teamId'] as String?,
      customFields: json['customFields'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ProjectMetadataToJson(ProjectMetadata instance) =>
    <String, dynamic>{
      'type': _$ProjectTypeEnumMap[instance.type]!,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'estimatedHours': instance.estimatedHours,
      'teamId': instance.teamId,
      'customFields': instance.customFields,
    };

const _$ProjectTypeEnumMap = {
  ProjectType.web: 'web',
  ProjectType.mobile: 'mobile',
  ProjectType.desktop: 'desktop',
  ProjectType.backend: 'backend',
  ProjectType.fullStack: 'fullStack',
  ProjectType.other: 'other',
};

const _$PriorityEnumMap = {
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
  Priority.urgent: 'urgent',
};

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: $enumDecode(_$TaskStatusEnumMap, json['status']),
      priority: $enumDecode(_$PriorityEnumMap, json['priority']),
      assignedToId: json['assignedToId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      attachmentIds: (json['attachmentIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dependencyIds: (json['dependencyIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      estimatedHours: (json['estimatedHours'] as num).toDouble(),
      actualHours: (json['actualHours'] as num).toDouble(),
      comments: (json['comments'] as List<dynamic>)
          .map((e) => TaskComment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'assignedToId': instance.assignedToId,
      'createdAt': instance.createdAt.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'attachmentIds': instance.attachmentIds,
      'dependencyIds': instance.dependencyIds,
      'estimatedHours': instance.estimatedHours,
      'actualHours': instance.actualHours,
      'comments': instance.comments,
    };

const _$TaskStatusEnumMap = {
  TaskStatus.todo: 'todo',
  TaskStatus.inProgress: 'inProgress',
  TaskStatus.review: 'review',
  TaskStatus.completed: 'completed',
  TaskStatus.blocked: 'blocked',
};

TaskComment _$TaskCommentFromJson(Map<String, dynamic> json) => TaskComment(
      id: json['id'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TaskCommentToJson(TaskComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'authorId': instance.authorId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
