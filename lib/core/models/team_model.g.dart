// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      logoUrl: json['logoUrl'] as String?,
      organizationId: json['organizationId'] as String?,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      settings: TeamSettings.fromJson(json['settings'] as Map<String, dynamic>),
      members: (json['members'] as List<dynamic>)
          .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      projectIds: (json['projectIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: $enumDecode(_$TeamStatusEnumMap, json['status']),
      plan: $enumDecode(_$TeamPlanEnumMap, json['plan']),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'logoUrl': instance.logoUrl,
      'organizationId': instance.organizationId,
      'ownerId': instance.ownerId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'settings': instance.settings,
      'members': instance.members,
      'projectIds': instance.projectIds,
      'status': _$TeamStatusEnumMap[instance.status]!,
      'plan': _$TeamPlanEnumMap[instance.plan]!,
      'metadata': instance.metadata,
    };

const _$TeamStatusEnumMap = {
  TeamStatus.active: 'active',
  TeamStatus.archived: 'archived',
  TeamStatus.suspended: 'suspended',
};

const _$TeamPlanEnumMap = {
  TeamPlan.free: 'free',
  TeamPlan.starter: 'starter',
  TeamPlan.professional: 'professional',
  TeamPlan.enterprise: 'enterprise',
};

TeamMember _$TeamMemberFromJson(Map<String, dynamic> json) => TeamMember(
      userId: json['userId'] as String,
      role: $enumDecode(_$TeamRoleEnumMap, json['role']),
      status: $enumDecode(_$TeamMemberStatusEnumMap, json['status']),
      addedAt: DateTime.parse(json['addedAt'] as String),
      addedById: json['addedById'] as String?,
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      customTitle: json['customTitle'] as String?,
      notificationSettings: TeamNotificationSettings.fromJson(
          json['notificationSettings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TeamMemberToJson(TeamMember instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'role': _$TeamRoleEnumMap[instance.role]!,
      'status': _$TeamMemberStatusEnumMap[instance.status]!,
      'addedAt': instance.addedAt.toIso8601String(),
      'addedById': instance.addedById,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'permissions': instance.permissions,
      'customTitle': instance.customTitle,
      'notificationSettings': instance.notificationSettings,
    };

const _$TeamRoleEnumMap = {
  TeamRole.owner: 'owner',
  TeamRole.admin: 'admin',
  TeamRole.manager: 'manager',
  TeamRole.member: 'member',
  TeamRole.viewer: 'viewer',
  TeamRole.collaborator: 'collaborator',
};

const _$TeamMemberStatusEnumMap = {
  TeamMemberStatus.active: 'active',
  TeamMemberStatus.pending: 'pending',
  TeamMemberStatus.inactive: 'inactive',
  TeamMemberStatus.suspended: 'suspended',
  TeamMemberStatus.left: 'left',
};

TeamSettings _$TeamSettingsFromJson(Map<String, dynamic> json) => TeamSettings(
      allowMemberInvites: json['allowMemberInvites'] as bool,
      requireInviteApproval: json['requireInviteApproval'] as bool,
      defaultMemberRole:
          $enumDecode(_$TeamRoleEnumMap, json['defaultMemberRole']),
      visibility: $enumDecode(_$TeamVisibilityEnumMap, json['visibility']),
      allowExternalCollaborators: json['allowExternalCollaborators'] as bool,
      requireTwoFactor: json['requireTwoFactor'] as bool,
      defaultProjectPermissions:
          (json['defaultProjectPermissions'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      requireApprovalForTasks: json['requireApprovalForTasks'] as bool,
      enableNotifications: json['enableNotifications'] as bool,
      timeZone: json['timeZone'] as String,
      workingHours:
          WorkingHours.fromJson(json['workingHours'] as Map<String, dynamic>),
      fileStorageSettings: FileStorageSettings.fromJson(
          json['fileStorageSettings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TeamSettingsToJson(TeamSettings instance) =>
    <String, dynamic>{
      'allowMemberInvites': instance.allowMemberInvites,
      'requireInviteApproval': instance.requireInviteApproval,
      'defaultMemberRole': _$TeamRoleEnumMap[instance.defaultMemberRole]!,
      'visibility': _$TeamVisibilityEnumMap[instance.visibility]!,
      'allowExternalCollaborators': instance.allowExternalCollaborators,
      'requireTwoFactor': instance.requireTwoFactor,
      'defaultProjectPermissions': instance.defaultProjectPermissions,
      'requireApprovalForTasks': instance.requireApprovalForTasks,
      'enableNotifications': instance.enableNotifications,
      'timeZone': instance.timeZone,
      'workingHours': instance.workingHours,
      'fileStorageSettings': instance.fileStorageSettings,
    };

const _$TeamVisibilityEnumMap = {
  TeamVisibility.private: 'private',
  TeamVisibility.internal: 'internal',
  TeamVisibility.public: 'public',
};

WorkingHours _$WorkingHoursFromJson(Map<String, dynamic> json) => WorkingHours(
      startHour: (json['startHour'] as num).toInt(),
      endHour: (json['endHour'] as num).toInt(),
      workingDays: (json['workingDays'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      timeZone: json['timeZone'] as String,
    );

Map<String, dynamic> _$WorkingHoursToJson(WorkingHours instance) =>
    <String, dynamic>{
      'startHour': instance.startHour,
      'endHour': instance.endHour,
      'workingDays': instance.workingDays,
      'timeZone': instance.timeZone,
    };

FileStorageSettings _$FileStorageSettingsFromJson(Map<String, dynamic> json) =>
    FileStorageSettings(
      maxFileSizeMB: (json['maxFileSizeMB'] as num).toInt(),
      allowedFileTypes: (json['allowedFileTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      storageLimitGB: (json['storageLimitGB'] as num).toInt(),
      enableVersionControl: json['enableVersionControl'] as bool,
      autoDeleteAfterDays: (json['autoDeleteAfterDays'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FileStorageSettingsToJson(
        FileStorageSettings instance) =>
    <String, dynamic>{
      'maxFileSizeMB': instance.maxFileSizeMB,
      'allowedFileTypes': instance.allowedFileTypes,
      'storageLimitGB': instance.storageLimitGB,
      'enableVersionControl': instance.enableVersionControl,
      'autoDeleteAfterDays': instance.autoDeleteAfterDays,
    };

TeamNotificationSettings _$TeamNotificationSettingsFromJson(
        Map<String, dynamic> json) =>
    TeamNotificationSettings(
      taskAssignments: json['taskAssignments'] as bool,
      projectUpdates: json['projectUpdates'] as bool,
      teamMentions: json['teamMentions'] as bool,
      dueDateReminders: json['dueDateReminders'] as bool,
      teamAnnouncements: json['teamAnnouncements'] as bool,
      emailFrequency:
          $enumDecode(_$NotificationFrequencyEnumMap, json['emailFrequency']),
      pushFrequency:
          $enumDecode(_$NotificationFrequencyEnumMap, json['pushFrequency']),
    );

Map<String, dynamic> _$TeamNotificationSettingsToJson(
        TeamNotificationSettings instance) =>
    <String, dynamic>{
      'taskAssignments': instance.taskAssignments,
      'projectUpdates': instance.projectUpdates,
      'teamMentions': instance.teamMentions,
      'dueDateReminders': instance.dueDateReminders,
      'teamAnnouncements': instance.teamAnnouncements,
      'emailFrequency':
          _$NotificationFrequencyEnumMap[instance.emailFrequency]!,
      'pushFrequency': _$NotificationFrequencyEnumMap[instance.pushFrequency]!,
    };

const _$NotificationFrequencyEnumMap = {
  NotificationFrequency.immediate: 'immediate',
  NotificationFrequency.hourly: 'hourly',
  NotificationFrequency.daily: 'daily',
  NotificationFrequency.weekly: 'weekly',
  NotificationFrequency.disabled: 'disabled',
};

TeamInvitation _$TeamInvitationFromJson(Map<String, dynamic> json) =>
    TeamInvitation(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      email: json['email'] as String,
      invitedById: json['invitedById'] as String,
      role: $enumDecode(_$TeamRoleEnumMap, json['role']),
      status: $enumDecode(_$InvitationStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
      message: json['message'] as String?,
      customTitle: json['customTitle'] as String?,
    );

Map<String, dynamic> _$TeamInvitationToJson(TeamInvitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'email': instance.email,
      'invitedById': instance.invitedById,
      'role': _$TeamRoleEnumMap[instance.role]!,
      'status': _$InvitationStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'respondedAt': instance.respondedAt?.toIso8601String(),
      'message': instance.message,
      'customTitle': instance.customTitle,
    };

const _$InvitationStatusEnumMap = {
  InvitationStatus.pending: 'pending',
  InvitationStatus.accepted: 'accepted',
  InvitationStatus.declined: 'declined',
  InvitationStatus.expired: 'expired',
  InvitationStatus.cancelled: 'cancelled',
};
