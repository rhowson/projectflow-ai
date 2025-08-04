import 'package:json_annotation/json_annotation.dart';

part 'project_model.g.dart';

@JsonSerializable()
class Project {
  final String id;
  final String title;
  final String description;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String ownerId; // User ID of project owner
  final List<String> teamMemberIds;
  final List<ProjectPhase> phases;
  final ProjectMetadata metadata;
  
  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.dueDate,
    required this.ownerId,
    required this.teamMemberIds,
    required this.phases,
    required this.metadata,
  });

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  Project copyWith({
    String? id,
    String? title,
    String? description,
    ProjectStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
    String? ownerId,
    List<String>? teamMemberIds,
    List<ProjectPhase>? phases,
    ProjectMetadata? metadata,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      ownerId: ownerId ?? this.ownerId,
      teamMemberIds: teamMemberIds ?? this.teamMemberIds,
      phases: phases ?? this.phases,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum ProjectStatus { planning, inProgress, completed, onHold, cancelled }

@JsonSerializable()
class ProjectPhase {
  final String id;
  final String name;
  final String description;
  final List<Task> tasks;
  final PhaseStatus status;
  final DateTime? startDate;
  final DateTime? endDate;

  const ProjectPhase({
    required this.id,
    required this.name,
    required this.description,
    required this.tasks,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory ProjectPhase.fromJson(Map<String, dynamic> json) => _$ProjectPhaseFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectPhaseToJson(this);
}

enum PhaseStatus { notStarted, inProgress, completed, onHold }

@JsonSerializable()
class ProjectMetadata {
  final ProjectType type;
  final Priority priority;
  final double estimatedHours;
  final Map<String, dynamic> customFields;

  const ProjectMetadata({
    required this.type,
    required this.priority,
    required this.estimatedHours,
    required this.customFields,
  });

  factory ProjectMetadata.fromJson(Map<String, dynamic> json) => _$ProjectMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectMetadataToJson(this);
}

enum ProjectType { web, mobile, desktop, backend, fullStack, other }
enum Priority { low, medium, high, urgent }

extension ProjectTypeExtension on ProjectType {
  static ProjectType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'web':
        return ProjectType.web;
      case 'mobile':
        return ProjectType.mobile;
      case 'desktop':
        return ProjectType.desktop;
      case 'backend':
        return ProjectType.backend;
      case 'fullstack':
      case 'full-stack':
        return ProjectType.fullStack;
      default:
        return ProjectType.other;
    }
  }
}

// Task model referenced in ProjectPhase
@JsonSerializable()
class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final Priority priority;
  final String? assignedToId;
  final DateTime createdAt;
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
}

enum TaskStatus { todo, inProgress, review, completed, blocked }

@JsonSerializable()
class TaskComment {
  final String id;
  final String content;
  final String authorId;
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