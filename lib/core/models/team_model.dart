import 'package:json_annotation/json_annotation.dart';

part 'team_model.g.dart';

/// Comprehensive team model for ProjectFlow AI application
/// Handles team organization, member management, and collaboration features
@JsonSerializable()
class Team {
  /// Unique identifier for the team
  final String id;
  
  /// Team name
  final String name;
  
  /// Team description or purpose
  final String description;
  
  /// URL to team's logo or image
  final String? logoUrl;
  
  /// Organization or company name this team belongs to
  final String? organizationId;
  
  /// User ID of the team owner
  final String ownerId;
  
  /// When the team was created
  final DateTime createdAt;
  
  /// When the team was last updated
  final DateTime updatedAt;
  
  /// Team settings and configuration
  final TeamSettings settings;
  
  /// List of team member details
  final List<TeamMember> members;
  
  /// List of project IDs this team has access to
  final List<String> projectIds;
  
  /// Team's current status
  final TeamStatus status;
  
  /// Team's subscription or plan level
  final TeamPlan plan;
  
  /// Additional metadata for future extensions
  final Map<String, dynamic> metadata;
  
  const Team({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.organizationId,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    required this.settings,
    required this.members,
    required this.projectIds,
    required this.status,
    required this.plan,
    required this.metadata,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);

  /// Creates a new team with updated fields
  Team copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? organizationId,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    TeamSettings? settings,
    List<TeamMember>? members,
    List<String>? projectIds,
    TeamStatus? status,
    TeamPlan? plan,
    Map<String, dynamic>? metadata,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      organizationId: organizationId ?? this.organizationId,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      members: members ?? this.members,
      projectIds: projectIds ?? this.projectIds,
      status: status ?? this.status,
      plan: plan ?? this.plan,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Gets the total number of active members
  int get activeMemberCount => members.where((m) => m.status == TeamMemberStatus.active).length;
  
  /// Gets the team owner member object
  TeamMember? get owner => members.firstWhere((m) => m.userId == ownerId);
  
  /// Checks if a user is a member of this team
  bool hasMember(String userId) => members.any((m) => m.userId == userId);
  
  /// Gets a specific team member by user ID
  TeamMember? getMember(String userId) {
    try {
      return members.firstWhere((m) => m.userId == userId);
    } catch (e) {
      return null;
    }
  }
  
  /// Checks if the team is at capacity based on plan limits
  bool get isAtCapacity {
    final limit = plan.memberLimit;
    return limit != null && activeMemberCount >= limit;
  }
  
  /// Factory constructor for creating a new team
  factory Team.createNew({
    required String id,
    required String name,
    required String description,
    required String ownerId,
    String? logoUrl,
    String? organizationId,
    TeamPlan plan = TeamPlan.free,
  }) {
    final now = DateTime.now();
    return Team(
      id: id,
      name: name,
      description: description,
      logoUrl: logoUrl,
      organizationId: organizationId,
      ownerId: ownerId,
      createdAt: now,
      updatedAt: now,
      settings: TeamSettings.defaultSettings(),
      members: [
        TeamMember.createOwner(
          userId: ownerId,
          addedAt: now,
        ),
      ],
      projectIds: [],
      status: TeamStatus.active,
      plan: plan,
      metadata: {},
    );
  }
}

/// Individual team member details
@JsonSerializable()
class TeamMember {
  /// User ID of the team member
  final String userId;
  
  /// Member's role within the team
  final TeamRole role;
  
  /// Member's status in the team
  final TeamMemberStatus status;
  
  /// When the member was added to the team
  final DateTime addedAt;
  
  /// User ID of who added this member
  final String? addedById;
  
  /// When the member was last active in team context
  final DateTime? lastActiveAt;
  
  /// Member-specific permissions overrides
  final List<String> permissions;
  
  /// Custom title or position within the team
  final String? customTitle;
  
  /// Member's notification preferences for this team
  final TeamNotificationSettings notificationSettings;
  
  const TeamMember({
    required this.userId,
    required this.role,
    required this.status,
    required this.addedAt,
    this.addedById,
    this.lastActiveAt,
    required this.permissions,
    this.customTitle,
    required this.notificationSettings,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => _$TeamMemberFromJson(json);
  Map<String, dynamic> toJson() => _$TeamMemberToJson(this);

  TeamMember copyWith({
    String? userId,
    TeamRole? role,
    TeamMemberStatus? status,
    DateTime? addedAt,
    String? addedById,
    DateTime? lastActiveAt,
    List<String>? permissions,
    String? customTitle,
    TeamNotificationSettings? notificationSettings,
  }) {
    return TeamMember(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      status: status ?? this.status,
      addedAt: addedAt ?? this.addedAt,
      addedById: addedById ?? this.addedById,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      permissions: permissions ?? this.permissions,
      customTitle: customTitle ?? this.customTitle,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }

  /// Factory constructor for creating team owner
  factory TeamMember.createOwner({
    required String userId,
    required DateTime addedAt,
  }) {
    return TeamMember(
      userId: userId,
      role: TeamRole.owner,
      status: TeamMemberStatus.active,
      addedAt: addedAt,
      addedById: null,
      lastActiveAt: null,
      permissions: [], // Owners have all permissions by default
      customTitle: null,
      notificationSettings: TeamNotificationSettings.defaultSettings(),
    );
  }

  /// Factory constructor for creating regular team member
  factory TeamMember.createMember({
    required String userId,
    required String addedById,
    TeamRole role = TeamRole.member,
    String? customTitle,
  }) {
    return TeamMember(
      userId: userId,
      role: role,
      status: TeamMemberStatus.pending,
      addedAt: DateTime.now(),
      addedById: addedById,
      lastActiveAt: null,
      permissions: [],
      customTitle: customTitle,
      notificationSettings: TeamNotificationSettings.defaultSettings(),
    );
  }

  /// Checks if member has a specific permission
  bool hasPermission(String permission) {
    // Owners and admins have all permissions
    if (role == TeamRole.owner || role == TeamRole.admin) {
      return true;
    }
    
    return permissions.contains(permission);
  }

  /// Checks if member can manage other members
  bool get canManageMembers => role == TeamRole.owner || role == TeamRole.admin || hasPermission('manage_members');

  /// Checks if member can manage projects
  bool get canManageProjects => role == TeamRole.owner || role == TeamRole.admin || hasPermission('manage_projects');

  /// Checks if member is active
  bool get isActive => status == TeamMemberStatus.active;
}

/// Team settings and configuration
@JsonSerializable()
class TeamSettings {
  /// Allow members to invite other members
  final bool allowMemberInvites;
  
  /// Require approval for new member invites
  final bool requireInviteApproval;
  
  /// Default role for new members
  final TeamRole defaultMemberRole;
  
  /// Team visibility setting
  final TeamVisibility visibility;
  
  /// Allow external collaborators
  final bool allowExternalCollaborators;
  
  /// Require two-factor authentication for all members
  final bool requireTwoFactor;
  
  /// Default project permissions for new members
  final List<String> defaultProjectPermissions;
  
  /// Time zone for team scheduling
  final String timeZone;
  
  /// Working hours configuration
  final WorkingHours workingHours;
  
  /// File sharing and storage settings
  final FileStorageSettings fileStorageSettings;
  
  const TeamSettings({
    required this.allowMemberInvites,
    required this.requireInviteApproval,
    required this.defaultMemberRole,
    required this.visibility,
    required this.allowExternalCollaborators,
    required this.requireTwoFactor,
    required this.defaultProjectPermissions,
    required this.timeZone,
    required this.workingHours,
    required this.fileStorageSettings,
  });

  factory TeamSettings.fromJson(Map<String, dynamic> json) => _$TeamSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$TeamSettingsToJson(this);

  factory TeamSettings.defaultSettings() {
    return TeamSettings(
      allowMemberInvites: true,
      requireInviteApproval: false,
      defaultMemberRole: TeamRole.member,
      visibility: TeamVisibility.private,
      allowExternalCollaborators: false,
      requireTwoFactor: false,
      defaultProjectPermissions: ['view_projects', 'comment_on_tasks'],
      timeZone: 'UTC',
      workingHours: WorkingHours.defaultHours(),
      fileStorageSettings: FileStorageSettings.defaultSettings(),
    );
  }

  TeamSettings copyWith({
    bool? allowMemberInvites,
    bool? requireInviteApproval,
    TeamRole? defaultMemberRole,
    TeamVisibility? visibility,
    bool? allowExternalCollaborators,
    bool? requireTwoFactor,
    List<String>? defaultProjectPermissions,
    String? timeZone,
    WorkingHours? workingHours,
    FileStorageSettings? fileStorageSettings,
  }) {
    return TeamSettings(
      allowMemberInvites: allowMemberInvites ?? this.allowMemberInvites,
      requireInviteApproval: requireInviteApproval ?? this.requireInviteApproval,
      defaultMemberRole: defaultMemberRole ?? this.defaultMemberRole,
      visibility: visibility ?? this.visibility,
      allowExternalCollaborators: allowExternalCollaborators ?? this.allowExternalCollaborators,
      requireTwoFactor: requireTwoFactor ?? this.requireTwoFactor,
      defaultProjectPermissions: defaultProjectPermissions ?? this.defaultProjectPermissions,
      timeZone: timeZone ?? this.timeZone,
      workingHours: workingHours ?? this.workingHours,
      fileStorageSettings: fileStorageSettings ?? this.fileStorageSettings,
    );
  }
}

/// Working hours configuration for teams
@JsonSerializable()
class WorkingHours {
  /// Start hour (0-23)
  final int startHour;
  
  /// End hour (0-23)
  final int endHour;
  
  /// Working days (1=Monday, 7=Sunday)
  final List<int> workingDays;
  
  /// Timezone for working hours
  final String timeZone;
  
  const WorkingHours({
    required this.startHour,
    required this.endHour,
    required this.workingDays,
    required this.timeZone,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) => _$WorkingHoursFromJson(json);
  Map<String, dynamic> toJson() => _$WorkingHoursToJson(this);

  factory WorkingHours.defaultHours() {
    return const WorkingHours(
      startHour: 9,
      endHour: 17,
      workingDays: [1, 2, 3, 4, 5], // Monday to Friday
      timeZone: 'UTC',
    );
  }

  WorkingHours copyWith({
    int? startHour,
    int? endHour,
    List<int>? workingDays,
    String? timeZone,
  }) {
    return WorkingHours(
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      workingDays: workingDays ?? this.workingDays,
      timeZone: timeZone ?? this.timeZone,
    );
  }
}

/// File storage settings for teams
@JsonSerializable()
class FileStorageSettings {
  /// Maximum file size in MB
  final int maxFileSizeMB;
  
  /// Allowed file types
  final List<String> allowedFileTypes;
  
  /// Total storage limit in GB
  final int storageLimitGB;
  
  /// Enable version control for files
  final bool enableVersionControl;
  
  /// Auto-delete files after days (null = never)
  final int? autoDeleteAfterDays;
  
  const FileStorageSettings({
    required this.maxFileSizeMB,
    required this.allowedFileTypes,
    required this.storageLimitGB,
    required this.enableVersionControl,
    this.autoDeleteAfterDays,
  });

  factory FileStorageSettings.fromJson(Map<String, dynamic> json) => _$FileStorageSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$FileStorageSettingsToJson(this);

  factory FileStorageSettings.defaultSettings() {
    return const FileStorageSettings(
      maxFileSizeMB: 100,
      allowedFileTypes: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'jpg', 'jpeg', 'png', 'gif'],
      storageLimitGB: 5,
      enableVersionControl: true,
      autoDeleteAfterDays: null,
    );
  }

  FileStorageSettings copyWith({
    int? maxFileSizeMB,
    List<String>? allowedFileTypes,
    int? storageLimitGB,
    bool? enableVersionControl,
    int? autoDeleteAfterDays,
  }) {
    return FileStorageSettings(
      maxFileSizeMB: maxFileSizeMB ?? this.maxFileSizeMB,
      allowedFileTypes: allowedFileTypes ?? this.allowedFileTypes,
      storageLimitGB: storageLimitGB ?? this.storageLimitGB,
      enableVersionControl: enableVersionControl ?? this.enableVersionControl,
      autoDeleteAfterDays: autoDeleteAfterDays ?? this.autoDeleteAfterDays,
    );
  }
}

/// Team member notification settings
@JsonSerializable()
class TeamNotificationSettings {
  /// Receive notifications for task assignments
  final bool taskAssignments;
  
  /// Receive notifications for project updates
  final bool projectUpdates;
  
  /// Receive notifications for team mentions
  final bool teamMentions;
  
  /// Receive notifications for due date reminders
  final bool dueDateReminders;
  
  /// Receive notifications for team announcements
  final bool teamAnnouncements;
  
  /// Email notification frequency
  final NotificationFrequency emailFrequency;
  
  /// Push notification frequency
  final NotificationFrequency pushFrequency;
  
  const TeamNotificationSettings({
    required this.taskAssignments,
    required this.projectUpdates,
    required this.teamMentions,
    required this.dueDateReminders,
    required this.teamAnnouncements,
    required this.emailFrequency,
    required this.pushFrequency,
  });

  factory TeamNotificationSettings.fromJson(Map<String, dynamic> json) => _$TeamNotificationSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$TeamNotificationSettingsToJson(this);

  factory TeamNotificationSettings.defaultSettings() {
    return const TeamNotificationSettings(
      taskAssignments: true,
      projectUpdates: true,
      teamMentions: true,
      dueDateReminders: true,
      teamAnnouncements: true,
      emailFrequency: NotificationFrequency.daily,
      pushFrequency: NotificationFrequency.immediate,
    );
  }

  TeamNotificationSettings copyWith({
    bool? taskAssignments,
    bool? projectUpdates,
    bool? teamMentions,
    bool? dueDateReminders,
    bool? teamAnnouncements,
    NotificationFrequency? emailFrequency,
    NotificationFrequency? pushFrequency,
  }) {
    return TeamNotificationSettings(
      taskAssignments: taskAssignments ?? this.taskAssignments,
      projectUpdates: projectUpdates ?? this.projectUpdates,
      teamMentions: teamMentions ?? this.teamMentions,
      dueDateReminders: dueDateReminders ?? this.dueDateReminders,
      teamAnnouncements: teamAnnouncements ?? this.teamAnnouncements,
      emailFrequency: emailFrequency ?? this.emailFrequency,
      pushFrequency: pushFrequency ?? this.pushFrequency,
    );
  }
}

/// Team invitation model for managing member invitations
@JsonSerializable()
class TeamInvitation {
  /// Unique invitation ID
  final String id;
  
  /// Team ID this invitation is for
  final String teamId;
  
  /// Email address of the invitee
  final String email;
  
  /// User ID of who sent the invitation
  final String invitedById;
  
  /// Role the invitee will have when they accept
  final TeamRole role;
  
  /// Current status of the invitation
  final InvitationStatus status;
  
  /// When the invitation was created
  final DateTime createdAt;
  
  /// When the invitation expires
  final DateTime expiresAt;
  
  /// When the invitation was responded to
  final DateTime? respondedAt;
  
  /// Optional personal message with the invitation
  final String? message;
  
  /// Custom title for the invitee
  final String? customTitle;
  
  const TeamInvitation({
    required this.id,
    required this.teamId,
    required this.email,
    required this.invitedById,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
    this.message,
    this.customTitle,
  });

  factory TeamInvitation.fromJson(Map<String, dynamic> json) => _$TeamInvitationFromJson(json);
  Map<String, dynamic> toJson() => _$TeamInvitationToJson(this);

  TeamInvitation copyWith({
    String? id,
    String? teamId,
    String? email,
    String? invitedById,
    TeamRole? role,
    InvitationStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? respondedAt,
    String? message,
    String? customTitle,
  }) {
    return TeamInvitation(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      email: email ?? this.email,
      invitedById: invitedById ?? this.invitedById,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message ?? this.message,
      customTitle: customTitle ?? this.customTitle,
    );
  }

  /// Checks if the invitation has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  /// Checks if the invitation is still pending
  bool get isPending => status == InvitationStatus.pending && !isExpired;

  /// Factory constructor for creating new invitation
  factory TeamInvitation.createNew({
    required String id,
    required String teamId,
    required String email,
    required String invitedById,
    required TeamRole role,
    String? message,
    String? customTitle,
    int expirationDays = 7,
  }) {
    final now = DateTime.now();
    return TeamInvitation(
      id: id,
      teamId: teamId,
      email: email,
      invitedById: invitedById,
      role: role,
      status: InvitationStatus.pending,
      createdAt: now,
      expiresAt: now.add(Duration(days: expirationDays)),
      respondedAt: null,
      message: message,
      customTitle: customTitle,
    );
  }
}

/// Enums for team management

/// Team roles with different permission levels
enum TeamRole {
  /// Team owner with full control
  @JsonValue('owner')
  owner,
  
  /// Administrator with management permissions
  @JsonValue('admin')
  admin,
  
  /// Manager with limited management permissions
  @JsonValue('manager')
  manager,
  
  /// Regular team member
  @JsonValue('member')
  member,
  
  /// Read-only access
  @JsonValue('viewer')
  viewer,
  
  /// External collaborator with limited access
  @JsonValue('collaborator')
  collaborator
}

/// Team member status
enum TeamMemberStatus {
  /// Active team member
  @JsonValue('active')
  active,
  
  /// Pending invitation acceptance
  @JsonValue('pending')
  pending,
  
  /// Inactive but still a member
  @JsonValue('inactive')
  inactive,
  
  /// Suspended from team
  @JsonValue('suspended')
  suspended,
  
  /// Left the team
  @JsonValue('left')
  left
}

/// Team status
enum TeamStatus {
  /// Active team
  @JsonValue('active')
  active,
  
  /// Archived team
  @JsonValue('archived')
  archived,
  
  /// Suspended team
  @JsonValue('suspended')
  suspended
}

/// Team visibility options
enum TeamVisibility {
  /// Private team - invite only
  @JsonValue('private')
  private,
  
  /// Internal - visible to organization members
  @JsonValue('internal')
  internal,
  
  /// Public - visible to everyone
  @JsonValue('public')
  public
}

/// Team subscription plans
enum TeamPlan {
  /// Free plan with basic features
  @JsonValue('free')
  free,
  
  /// Starter plan for small teams
  @JsonValue('starter')
  starter,
  
  /// Professional plan for growing teams
  @JsonValue('professional')
  professional,
  
  /// Enterprise plan for large organizations
  @JsonValue('enterprise')
  enterprise
}

/// Invitation status
enum InvitationStatus {
  /// Invitation sent and pending
  @JsonValue('pending')
  pending,
  
  /// Invitation accepted
  @JsonValue('accepted')
  accepted,
  
  /// Invitation declined
  @JsonValue('declined')
  declined,
  
  /// Invitation expired
  @JsonValue('expired')
  expired,
  
  /// Invitation cancelled
  @JsonValue('cancelled')
  cancelled
}

/// Notification frequency options (reusing from user_model.dart)
enum NotificationFrequency {
  @JsonValue('immediate')
  immediate,
  @JsonValue('hourly')
  hourly,
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('disabled')
  disabled
}

/// Extension for TeamPlan to provide plan details
extension TeamPlanExtension on TeamPlan {
  /// Maximum number of members allowed (null = unlimited)
  int? get memberLimit {
    switch (this) {
      case TeamPlan.free:
        return 5;
      case TeamPlan.starter:
        return 15;
      case TeamPlan.professional:
        return 50;
      case TeamPlan.enterprise:
        return null; // Unlimited
    }
  }
  
  /// Storage limit in GB
  int get storageLimit {
    switch (this) {
      case TeamPlan.free:
        return 5;
      case TeamPlan.starter:
        return 25;
      case TeamPlan.professional:
        return 100;
      case TeamPlan.enterprise:
        return 1000;
    }
  }
  
  /// Available features for this plan
  List<String> get features {
    switch (this) {
      case TeamPlan.free:
        return ['basic_projects', 'task_management', 'file_sharing'];
      case TeamPlan.starter:
        return ['basic_projects', 'task_management', 'file_sharing', 'team_collaboration', 'basic_analytics'];
      case TeamPlan.professional:
        return ['advanced_projects', 'task_management', 'file_sharing', 'team_collaboration', 'advanced_analytics', 'integrations', 'custom_fields'];
      case TeamPlan.enterprise:
        return ['enterprise_projects', 'task_management', 'file_sharing', 'team_collaboration', 'enterprise_analytics', 'all_integrations', 'custom_fields', 'sso', 'advanced_security'];
    }
  }
}