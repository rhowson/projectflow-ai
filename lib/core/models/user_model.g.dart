// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      preferences:
          UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'role': _$UserRoleEnumMap[instance.role]!,
      'preferences': instance.preferences,
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.manager: 'manager',
  UserRole.member: 'member',
  UserRole.viewer: 'viewer',
};

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      darkMode: json['darkMode'] as bool,
      language: json['language'] as String,
      notifications: json['notifications'] as bool,
      emailUpdates: json['emailUpdates'] as bool,
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'darkMode': instance.darkMode,
      'language': instance.language,
      'notifications': instance.notifications,
      'emailUpdates': instance.emailUpdates,
    };
