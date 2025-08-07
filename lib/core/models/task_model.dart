import 'package:json_annotation/json_annotation.dart';
import '../utils/datetime_converter.dart';

part 'task_model.g.dart';

@JsonSerializable()
class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final Priority priority;
  final String? assignedToId;
  @DateTimeConverter()
  final DateTime createdAt;
  @DateTimeConverter()
  final DateTime? dueDate;
  final List<String> attachmentIds;
  final List<String> dependencyIds;
  final double estimatedHours;
  final double actualHours;
  final List<TaskComment> comments;
  
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assignedToId,
    required this.createdAt,
    this.dueDate,
    required this.attachmentIds,
    required this.dependencyIds,
    required this.estimatedHours,
    required this.actualHours,
    required this.comments,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    Priority? priority,
    String? assignedToId,
    DateTime? createdAt,
    DateTime? dueDate,
    List<String>? attachmentIds,
    List<String>? dependencyIds,
    double? estimatedHours,
    double? actualHours,
    List<TaskComment>? comments,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedToId: assignedToId ?? this.assignedToId,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      dependencyIds: dependencyIds ?? this.dependencyIds,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      comments: comments ?? this.comments,
    );
  }
}

enum TaskStatus { todo, inProgress, review, completed, blocked }
enum Priority { low, medium, high, urgent }

@JsonSerializable()
class TaskComment {
  final String id;
  final String content;
  final String authorId;
  @DateTimeConverter()
  final DateTime createdAt;

  const TaskComment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.createdAt,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) => _$TaskCommentFromJson(json);
  Map<String, dynamic> toJson() => _$TaskCommentToJson(this);
}