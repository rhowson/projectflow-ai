// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

const _$PriorityEnumMap = {
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
  Priority.urgent: 'urgent',
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
