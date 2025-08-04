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
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      summary: json['summary'] as String?,
    );

Map<String, dynamic> _$ProjectContextToJson(ProjectContext instance) =>
    <String, dynamic>{
      'projectId': instance.projectId,
      'contextQuestions': instance.contextQuestions,
      'documents': instance.documents,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'summary': instance.summary,
    };

ContextQuestion _$ContextQuestionFromJson(Map<String, dynamic> json) =>
    ContextQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      type: $enumDecode(_$ContextQuestionTypeEnumMap, json['type']),
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      isRequired: json['isRequired'] as bool? ?? false,
    );

Map<String, dynamic> _$ContextQuestionToJson(ContextQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
      'type': _$ContextQuestionTypeEnumMap[instance.type]!,
      'answeredAt': instance.answeredAt.toIso8601String(),
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
      sizeInBytes: json['sizeInBytes'] as int,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
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
      'uploadedAt': instance.uploadedAt.toIso8601String(),
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

K $enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}