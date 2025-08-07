import 'package:json_annotation/json_annotation.dart';
import '../utils/datetime_converter.dart';

part 'project_context_model.g.dart';

@JsonSerializable()
class ProjectContext {
  final String projectId;
  final List<ContextQuestion> contextQuestions;
  final List<ProjectDocument> documents;
  @DateTimeConverter()
  final DateTime lastUpdated;
  final String? summary;

  const ProjectContext({
    required this.projectId,
    required this.contextQuestions,
    required this.documents,
    required this.lastUpdated,
    this.summary,
  });

  factory ProjectContext.fromJson(Map<String, dynamic> json) => _$ProjectContextFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectContextToJson(this);

  ProjectContext copyWith({
    String? projectId,
    List<ContextQuestion>? contextQuestions,
    List<ProjectDocument>? documents,
    DateTime? lastUpdated,
    String? summary,
  }) {
    return ProjectContext(
      projectId: projectId ?? this.projectId,
      contextQuestions: contextQuestions ?? this.contextQuestions,
      documents: documents ?? this.documents,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      summary: summary ?? this.summary,
    );
  }

  bool get hasContent => contextQuestions.isNotEmpty || documents.isNotEmpty;
  int get totalItems => contextQuestions.length + documents.length;
}

@JsonSerializable()
class ContextQuestion {
  final String id;
  final String question;
  final String answer;
  final ContextQuestionType type;
  @DateTimeConverter()
  final DateTime answeredAt;
  final bool isRequired;

  const ContextQuestion({
    required this.id,
    required this.question,
    required this.answer,
    required this.type,
    required this.answeredAt,
    this.isRequired = false,
  });

  factory ContextQuestion.fromJson(Map<String, dynamic> json) => _$ContextQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$ContextQuestionToJson(this);
}

enum ContextQuestionType { 
  projectScope, 
  technicalRequirements, 
  timeline, 
  resources, 
  constraints, 
  other 
}

@JsonSerializable()
class ProjectDocument {
  final String id;
  final String name;
  final String path;
  final String mimeType;
  final int sizeInBytes;
  @DateTimeConverter()
  final DateTime uploadedAt;
  final String uploadedBy;
  final DocumentType type;
  final String? description;

  const ProjectDocument({
    required this.id,
    required this.name,
    required this.path,
    required this.mimeType,
    required this.sizeInBytes,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.type,
    this.description,
  });

  factory ProjectDocument.fromJson(Map<String, dynamic> json) => _$ProjectDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectDocumentToJson(this);

  String get formattedSize {
    if (sizeInBytes < 1024) return '${sizeInBytes}B';
    if (sizeInBytes < 1024 * 1024) return '${(sizeInBytes / 1024).toStringAsFixed(1)}KB';
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get fileExtension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }
}

enum DocumentType { 
  requirement, 
  design, 
  specification, 
  reference, 
  asset, 
  other 
}

extension DocumentTypeExtension on DocumentType {
  String get displayName {
    switch (this) {
      case DocumentType.requirement:
        return 'Requirement';
      case DocumentType.design:
        return 'Design';
      case DocumentType.specification:
        return 'Specification';
      case DocumentType.reference:
        return 'Reference';
      case DocumentType.asset:
        return 'Asset';
      case DocumentType.other:
        return 'Other';
    }
  }
}

extension ContextQuestionTypeExtension on ContextQuestionType {
  String get displayName {
    switch (this) {
      case ContextQuestionType.projectScope:
        return 'Project Scope';
      case ContextQuestionType.technicalRequirements:
        return 'Technical Requirements';
      case ContextQuestionType.timeline:
        return 'Timeline';
      case ContextQuestionType.resources:
        return 'Resources';
      case ContextQuestionType.constraints:
        return 'Constraints';
      case ContextQuestionType.other:
        return 'Other';
    }
  }
}