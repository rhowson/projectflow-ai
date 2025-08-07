// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      jobTitle: json['jobTitle'] as String?,
      department: json['department'] as String?,
      company: json['company'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      timezone: json['timezone'] as String,
      createdAt: const DateTimeConverter().fromJson(json['createdAt']),
      lastLoginAt: const DateTimeConverter().fromJson(json['lastLoginAt']),
      lastActiveAt: const DateTimeConverter().fromJson(json['lastActiveAt']),
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      status: $enumDecode(_$UserStatusEnumMap, json['status']),
      preferences:
          UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
      teamIds:
          (json['teamIds'] as List<dynamic>).map((e) => e as String).toList(),
      projectIds: (json['projectIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      skills:
          (json['skills'] as List<dynamic>).map((e) => e as String).toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool,
      isEmailVerified: json['isEmailVerified'] as bool,
      hasTwoFactorEnabled: json['hasTwoFactorEnabled'] as bool,
      authProvider: json['authProvider'] as String?,
    );

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'photoUrl': instance.photoUrl,
      'phoneNumber': instance.phoneNumber,
      'jobTitle': instance.jobTitle,
      'department': instance.department,
      'company': instance.company,
      'bio': instance.bio,
      'location': instance.location,
      'timezone': instance.timezone,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'lastLoginAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.lastLoginAt, const DateTimeConverter().toJson),
      'lastActiveAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.lastActiveAt, const DateTimeConverter().toJson),
      'role': _$UserRoleEnumMap[instance.role]!,
      'status': _$UserStatusEnumMap[instance.status]!,
      'preferences': instance.preferences,
      'teamIds': instance.teamIds,
      'projectIds': instance.projectIds,
      'skills': instance.skills,
      'metadata': instance.metadata,
      'hasCompletedOnboarding': instance.hasCompletedOnboarding,
      'isEmailVerified': instance.isEmailVerified,
      'hasTwoFactorEnabled': instance.hasTwoFactorEnabled,
      'authProvider': instance.authProvider,
    };

const _$UserRoleEnumMap = {
  UserRole.member: 'member',
  UserRole.premium: 'premium',
  UserRole.manager: 'manager',
  UserRole.admin: 'admin',
  UserRole.owner: 'owner',
  UserRole.viewer: 'viewer',
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.inactive: 'inactive',
  UserStatus.suspended: 'suspended',
  UserStatus.pending: 'pending',
  UserStatus.blocked: 'blocked',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      themeMode: $enumDecode(_$AppThemeModeEnumMap, json['themeMode']),
      language: json['language'] as String,
      pushNotifications: json['pushNotifications'] as bool,
      emailNotifications: json['emailNotifications'] as bool,
      soundEnabled: json['soundEnabled'] as bool,
      desktopNotifications: json['desktopNotifications'] as bool,
      notificationFrequency: $enumDecode(
          _$NotificationFrequencyEnumMap, json['notificationFrequency']),
      autoCompleteTasksInDone: json['autoCompleteTasksInDone'] as bool,
      showProjectProgress: json['showProjectProgress'] as bool,
      enableDragAndDrop: json['enableDragAndDrop'] as bool,
      compactTaskView: json['compactTaskView'] as bool,
      showTaskEstimates: json['showTaskEstimates'] as bool,
      defaultTaskPriority:
          $enumDecode(_$PriorityEnumMap, json['defaultTaskPriority']),
      dateFormat: $enumDecode(_$DateFormatEnumMap, json['dateFormat']),
      timeFormat: $enumDecode(_$TimeFormatEnumMap, json['timeFormat']),
      startOfWeek: (json['startOfWeek'] as num).toInt(),
      workingHoursStart: (json['workingHoursStart'] as num).toInt(),
      workingHoursEnd: (json['workingHoursEnd'] as num).toInt(),
      workingDays: (json['workingDays'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      defaultExportFormat:
          $enumDecode(_$ExportFormatEnumMap, json['defaultExportFormat']),
      enableAnalytics: json['enableAnalytics'] as bool,
      enableAutoBackup: json['enableAutoBackup'] as bool,
      featureFlags: Map<String, bool>.from(json['featureFlags'] as Map),
      customShortcuts: Map<String, String>.from(json['customShortcuts'] as Map),
      dashboardPreferences: DashboardPreferences.fromJson(
          json['dashboardPreferences'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
      'language': instance.language,
      'pushNotifications': instance.pushNotifications,
      'emailNotifications': instance.emailNotifications,
      'soundEnabled': instance.soundEnabled,
      'desktopNotifications': instance.desktopNotifications,
      'notificationFrequency':
          _$NotificationFrequencyEnumMap[instance.notificationFrequency]!,
      'autoCompleteTasksInDone': instance.autoCompleteTasksInDone,
      'showProjectProgress': instance.showProjectProgress,
      'enableDragAndDrop': instance.enableDragAndDrop,
      'compactTaskView': instance.compactTaskView,
      'showTaskEstimates': instance.showTaskEstimates,
      'defaultTaskPriority': _$PriorityEnumMap[instance.defaultTaskPriority]!,
      'dateFormat': _$DateFormatEnumMap[instance.dateFormat]!,
      'timeFormat': _$TimeFormatEnumMap[instance.timeFormat]!,
      'startOfWeek': instance.startOfWeek,
      'workingHoursStart': instance.workingHoursStart,
      'workingHoursEnd': instance.workingHoursEnd,
      'workingDays': instance.workingDays,
      'defaultExportFormat':
          _$ExportFormatEnumMap[instance.defaultExportFormat]!,
      'enableAnalytics': instance.enableAnalytics,
      'enableAutoBackup': instance.enableAutoBackup,
      'featureFlags': instance.featureFlags,
      'customShortcuts': instance.customShortcuts,
      'dashboardPreferences': instance.dashboardPreferences,
    };

const _$AppThemeModeEnumMap = {
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
  AppThemeMode.system: 'system',
};

const _$NotificationFrequencyEnumMap = {
  NotificationFrequency.immediate: 'immediate',
  NotificationFrequency.hourly: 'hourly',
  NotificationFrequency.daily: 'daily',
  NotificationFrequency.weekly: 'weekly',
  NotificationFrequency.disabled: 'disabled',
};

const _$PriorityEnumMap = {
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
  Priority.urgent: 'urgent',
};

const _$DateFormatEnumMap = {
  DateFormat.monthDayYear: 'mm/dd/yyyy',
  DateFormat.dayMonthYear: 'dd/mm/yyyy',
  DateFormat.yearMonthDay: 'yyyy-mm-dd',
  DateFormat.dayMonthNameYear: 'dd MMM yyyy',
};

const _$TimeFormatEnumMap = {
  TimeFormat.hour12: '12',
  TimeFormat.hour24: '24',
};

const _$ExportFormatEnumMap = {
  ExportFormat.pdf: 'pdf',
  ExportFormat.csv: 'csv',
  ExportFormat.xlsx: 'xlsx',
  ExportFormat.json: 'json',
};

DashboardPreferences _$DashboardPreferencesFromJson(
        Map<String, dynamic> json) =>
    DashboardPreferences(
      showRecentProjects: json['showRecentProjects'] as bool,
      showTaskSummary: json['showTaskSummary'] as bool,
      showTeamActivity: json['showTeamActivity'] as bool,
      showAnalytics: json['showAnalytics'] as bool,
      showCalendar: json['showCalendar'] as bool,
      recentProjectsLimit: (json['recentProjectsLimit'] as num).toInt(),
      defaultView: $enumDecode(_$DashboardViewEnumMap, json['defaultView']),
      widgetOrder: (json['widgetOrder'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DashboardPreferencesToJson(
        DashboardPreferences instance) =>
    <String, dynamic>{
      'showRecentProjects': instance.showRecentProjects,
      'showTaskSummary': instance.showTaskSummary,
      'showTeamActivity': instance.showTeamActivity,
      'showAnalytics': instance.showAnalytics,
      'showCalendar': instance.showCalendar,
      'recentProjectsLimit': instance.recentProjectsLimit,
      'defaultView': _$DashboardViewEnumMap[instance.defaultView]!,
      'widgetOrder': instance.widgetOrder,
    };

const _$DashboardViewEnumMap = {
  DashboardView.grid: 'grid',
  DashboardView.list: 'list',
  DashboardView.kanban: 'kanban',
};
