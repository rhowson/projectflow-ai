// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_context_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectContext _$ProjectContextFromJson(Map<String, dynamic> json) =>
    ProjectContext(
      projectId: json['projectId'] as String,
      contextQuestions: (json['contextQuestions'] as List<dynamic>)
          .map((e) => ContextQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      documents: (json['documents'] as List<dynamic>)
          .map((e) => ProjectDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: const DateTimeConverter().fromJson(json['lastUpdated']),
      summary: json['summary'] as String?,
    );

Map<String, dynamic> _$ProjectContextToJson(ProjectContext instance) =>
    <String, dynamic>{
      'projectId': instance.projectId,
      'contextQuestions': instance.contextQuestions,
      'documents': instance.documents,
      'lastUpdated': const DateTimeConverter().toJson(instance.lastUpdated),
      'summary': instance.summary,
    };

ContextQuestion _$ContextQuestionFromJson(Map<String, dynamic> json) =>
    ContextQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      type: $enumDecode(_$ContextQuestionTypeEnumMap, json['type']),
      answeredAt: const DateTimeConverter().fromJson(json['answeredAt']),
      isRequired: json['isRequired'] as bool? ?? false,
    );

Map<String, dynamic> _$ContextQuestionToJson(ContextQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
      'type': _$ContextQuestionTypeEnumMap[instance.type]!,
      'answeredAt': const DateTimeConverter().toJson(instance.answeredAt),
      'isRequired': instance.isRequired,
    };

const _$ContextQuestionTypeEnumMap = {
  ContextQuestionType.projectScope: 'projectScope',
  ContextQuestionType.technicalRequirements: 'technicalRequirements',
  ContextQuestionType.timeline: 'timeline',
  ContextQuestionType.resources: 'resources',
  ContextQuestionType.constraints: 'constraints',
  ContextQuestionType.other: 'other',
};

ProjectDocument _$ProjectDocumentFromJson(Map<String, dynamic> json) =>
    ProjectDocument(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      mimeType: json['mimeType'] as String,
      sizeInBytes: (json['sizeInBytes'] as num).toInt(),
      uploadedAt: const DateTimeConverter().fromJson(json['uploadedAt']),
      uploadedBy: json['uploadedBy'] as String,
      type: $enumDecode(_$DocumentTypeEnumMap, json['type']),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ProjectDocumentToJson(ProjectDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'path': instance.path,
      'mimeType': instance.mimeType,
      'sizeInBytes': instance.sizeInBytes,
      'uploadedAt': const DateTimeConverter().toJson(instance.uploadedAt),
      'uploadedBy': instance.uploadedBy,
      'type': _$DocumentTypeEnumMap[instance.type]!,
      'description': instance.description,
    };

const _$DocumentTypeEnumMap = {
  DocumentType.requirement: 'requirement',
  DocumentType.design: 'design',
  DocumentType.specification: 'specification',
  DocumentType.reference: 'reference',
  DocumentType.asset: 'asset',
  DocumentType.other: 'other',
};
