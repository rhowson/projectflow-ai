// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamMember _$TeamMemberFromJson(Map<String, dynamic> json) => TeamMember(
      id: json['id'] as String,
      userId: json['userId'] as String,
      projectId: json['projectId'] as String,
      role: $enumDecode(_$TeamRoleEnumMap, json['role']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isActive: json['isActive'] as bool,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TeamMemberToJson(TeamMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'projectId': instance.projectId,
      'role': _$TeamRoleEnumMap[instance.role]!,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'isActive': instance.isActive,
      'permissions': instance.permissions,
    };

const _$TeamRoleEnumMap = {
  TeamRole.owner: 'owner',
  TeamRole.admin: 'admin',
  TeamRole.member: 'member',
  TeamRole.viewer: 'viewer',
};
