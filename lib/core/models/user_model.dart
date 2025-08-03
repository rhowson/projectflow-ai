import 'package:json_annotation/json_annotation.dart';
import 'task_model.dart';

part 'user_model.g.dart';

/// Comprehensive user model for ProjectFlow AI application
/// Handles all user-related data including profile, preferences, and team memberships
@JsonSerializable()
class AppUser {
  /// Unique identifier for the user
  final String id;
  
  /// User's email address (primary identifier)
  final String email;
  
  /// Display name for the user
  final String displayName;
  
  /// First name of the user
  final String firstName;
  
  /// Last name of the user
  final String lastName;
  
  /// URL to user's profile photo
  final String? photoUrl;
  
  /// User's phone number
  final String? phoneNumber;
  
  /// User's job title or position
  final String? jobTitle;
  
  /// User's department or team
  final String? department;
  
  /// Company or organization name
  final String? company;
  
  /// User's bio or description
  final String? bio;
  
  /// User's location (city, country)
  final String? location;
  
  /// User's timezone
  final String timezone;
  
  /// When the user account was created
  final DateTime createdAt;
  
  /// When the user last logged in
  final DateTime? lastLoginAt;
  
  /// When the user was last active
  final DateTime? lastActiveAt;
  
  /// User's role in the system
  final UserRole role;
  
  /// Current status of the user account
  final UserStatus status;
  
  /// User's preferences and settings
  final UserPreferences preferences;
  
  /// List of team IDs the user belongs to
  final List<String> teamIds;
  
  /// List of project IDs the user has access to
  final List<String> projectIds;
  
  /// User's skills and expertise
  final List<String> skills;
  
  /// Additional metadata for future extensions
  final Map<String, dynamic> metadata;
  
  /// Flag indicating if the user has completed onboarding
  final bool hasCompletedOnboarding;
  
  /// Flag indicating if the user's email is verified
  final bool isEmailVerified;
  
  /// Flag indicating if the user has enabled two-factor authentication
  final bool hasTwoFactorEnabled;
  
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.phoneNumber,
    this.jobTitle,
    this.department,
    this.company,
    this.bio,
    this.location,
    required this.timezone,
    required this.createdAt,
    this.lastLoginAt,
    this.lastActiveAt,
    required this.role,
    required this.status,
    required this.preferences,
    required this.teamIds,
    required this.projectIds,
    required this.skills,
    required this.metadata,
    required this.hasCompletedOnboarding,
    required this.isEmailVerified,
    required this.hasTwoFactorEnabled,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  /// Creates a new user with updated fields
  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? phoneNumber,
    String? jobTitle,
    String? department,
    String? company,
    String? bio,
    String? location,
    String? timezone,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? lastActiveAt,
    UserRole? role,
    UserStatus? status,
    UserPreferences? preferences,
    List<String>? teamIds,
    List<String>? projectIds,
    List<String>? skills,
    Map<String, dynamic>? metadata,
    bool? hasCompletedOnboarding,
    bool? isEmailVerified,
    bool? hasTwoFactorEnabled,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      company: company ?? this.company,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      role: role ?? this.role,
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      teamIds: teamIds ?? this.teamIds,
      projectIds: projectIds ?? this.projectIds,
      skills: skills ?? this.skills,
      metadata: metadata ?? this.metadata,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      hasTwoFactorEnabled: hasTwoFactorEnabled ?? this.hasTwoFactorEnabled,
    );
  }

  /// Returns the user's initials for avatar display
  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0].toUpperCase()}${lastName[0].toUpperCase()}';
    }
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0].toUpperCase()}${parts[1][0].toUpperCase()}';
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
  }

  /// Returns the user's full name
  String get fullName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    }
    return displayName;
  }

  /// Checks if the user is currently active
  bool get isActive => status == UserStatus.active;

  /// Checks if the user is an admin
  bool get isAdmin => role == UserRole.admin || role == UserRole.owner;

  /// Checks if the user has premium features
  bool get hasPremiumAccess => 
      role == UserRole.admin || 
      role == UserRole.owner || 
      role == UserRole.premium;

  /// Checks if the user can manage teams
  bool get canManageTeams => 
      role == UserRole.admin || 
      role == UserRole.owner || 
      role == UserRole.manager;

  /// Checks if the user is online (active within last 5 minutes)
  bool get isOnline {
    if (lastActiveAt == null) return false;
    return DateTime.now().difference(lastActiveAt!).inMinutes < 5;
  }

  /// Factory constructor for creating a new user account
  factory AppUser.createNew({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? photoUrl,
    UserRole role = UserRole.member,
  }) {
    return AppUser(
      id: id,
      email: email,
      displayName: '$firstName $lastName',
      firstName: firstName,
      lastName: lastName,
      photoUrl: photoUrl,
      phoneNumber: null,
      jobTitle: null,
      department: null,
      company: null,
      bio: null,
      location: null,
      timezone: 'UTC',
      createdAt: DateTime.now(),
      lastLoginAt: null,
      lastActiveAt: null,
      role: role,
      status: UserStatus.active,
      preferences: UserPreferences.defaultPreferences(),
      teamIds: [],
      projectIds: [],
      skills: [],
      metadata: {},
      hasCompletedOnboarding: false,
      isEmailVerified: false,
      hasTwoFactorEnabled: false,
    );
  }
}

/// User roles defining permissions and access levels
enum UserRole { 
  /// Basic user with limited access
  @JsonValue('member')
  member,
  
  /// Premium user with enhanced features
  @JsonValue('premium')
  premium,
  
  /// Manager with team management capabilities
  @JsonValue('manager')
  manager,
  
  /// Administrator with full system access
  @JsonValue('admin')
  admin,
  
  /// Organization owner with complete control
  @JsonValue('owner')
  owner,
  
  /// Read-only access for viewing content
  @JsonValue('viewer')
  viewer
}

/// User account status
enum UserStatus {
  /// Active user account
  @JsonValue('active')
  active,
  
  /// Inactive user account
  @JsonValue('inactive')
  inactive,
  
  /// Suspended user account
  @JsonValue('suspended')
  suspended,
  
  /// Pending activation or verification
  @JsonValue('pending')
  pending,
  
  /// Temporarily blocked account
  @JsonValue('blocked')
  blocked
}

/// Comprehensive user preferences and settings
@JsonSerializable()
class UserPreferences {
  /// Theme preference: light, dark, or system
  final AppThemeMode themeMode;
  
  /// User's preferred language code (e.g., 'en', 'es', 'fr')
  final String language;
  
  /// Enable/disable push notifications
  final bool pushNotifications;
  
  /// Enable/disable email notifications
  final bool emailNotifications;
  
  /// Enable/disable in-app sound effects
  final bool soundEnabled;
  
  /// Enable/disable desktop notifications
  final bool desktopNotifications;
  
  /// Frequency of notification summaries
  final NotificationFrequency notificationFrequency;
  
  /// Automatically mark tasks as completed when moved to done
  final bool autoCompleteTasksInDone;
  
  /// Show project progress in dashboard cards
  final bool showProjectProgress;
  
  /// Enable drag and drop for task management
  final bool enableDragAndDrop;
  
  /// Compact view mode for task lists
  final bool compactTaskView;
  
  /// Show task estimates in hours
  final bool showTaskEstimates;
  
  /// Default task priority for new tasks
  final Priority defaultTaskPriority;
  
  /// Preferred date format
  final DateFormat dateFormat;
  
  /// Preferred time format (12/24 hour)
  final TimeFormat timeFormat;
  
  /// Start of work week (Monday = 1, Sunday = 7)
  final int startOfWeek;
  
  /// Working hours start time (24-hour format)
  final int workingHoursStart;
  
  /// Working hours end time (24-hour format)
  final int workingHoursEnd;
  
  /// Working days of the week
  final List<int> workingDays;
  
  /// Export format preferences
  final ExportFormat defaultExportFormat;
  
  /// Enable analytics and usage tracking
  final bool enableAnalytics;
  
  /// Enable automatic data backup
  final bool enableAutoBackup;
  
  /// Feature flags for experimental features
  final Map<String, bool> featureFlags;
  
  /// Custom keyboard shortcuts
  final Map<String, String> customShortcuts;
  
  /// Dashboard widget preferences
  final DashboardPreferences dashboardPreferences;
  
  const UserPreferences({
    required this.themeMode,
    required this.language,
    required this.pushNotifications,
    required this.emailNotifications,
    required this.soundEnabled,
    required this.desktopNotifications,
    required this.notificationFrequency,
    required this.autoCompleteTasksInDone,
    required this.showProjectProgress,
    required this.enableDragAndDrop,
    required this.compactTaskView,
    required this.showTaskEstimates,
    required this.defaultTaskPriority,
    required this.dateFormat,
    required this.timeFormat,
    required this.startOfWeek,
    required this.workingHoursStart,
    required this.workingHoursEnd,
    required this.workingDays,
    required this.defaultExportFormat,
    required this.enableAnalytics,
    required this.enableAutoBackup,
    required this.featureFlags,
    required this.customShortcuts,
    required this.dashboardPreferences,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => 
      _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  /// Creates default preferences for new users
  factory UserPreferences.defaultPreferences() {
    return UserPreferences(
      themeMode: AppThemeMode.system,
      language: 'en',
      pushNotifications: true,
      emailNotifications: true,
      soundEnabled: true,
      desktopNotifications: true,
      notificationFrequency: NotificationFrequency.daily,
      autoCompleteTasksInDone: true,
      showProjectProgress: true,
      enableDragAndDrop: true,
      compactTaskView: false,
      showTaskEstimates: true,
      defaultTaskPriority: Priority.medium,
      dateFormat: DateFormat.monthDayYear,
      timeFormat: TimeFormat.hour12,
      startOfWeek: 1, // Monday
      workingHoursStart: 9,
      workingHoursEnd: 17,
      workingDays: [1, 2, 3, 4, 5], // Monday to Friday
      defaultExportFormat: ExportFormat.pdf,
      enableAnalytics: true,
      enableAutoBackup: true,
      featureFlags: {},
      customShortcuts: {},
      dashboardPreferences: DashboardPreferences.defaultPreferences(),
    );
  }

  UserPreferences copyWith({
    AppThemeMode? themeMode,
    String? language,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? soundEnabled,
    bool? desktopNotifications,
    NotificationFrequency? notificationFrequency,
    bool? autoCompleteTasksInDone,
    bool? showProjectProgress,
    bool? enableDragAndDrop,
    bool? compactTaskView,
    bool? showTaskEstimates,
    Priority? defaultTaskPriority,
    DateFormat? dateFormat,
    TimeFormat? timeFormat,
    int? startOfWeek,
    int? workingHoursStart,
    int? workingHoursEnd,
    List<int>? workingDays,
    ExportFormat? defaultExportFormat,
    bool? enableAnalytics,
    bool? enableAutoBackup,
    Map<String, bool>? featureFlags,
    Map<String, String>? customShortcuts,
    DashboardPreferences? dashboardPreferences,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      desktopNotifications: desktopNotifications ?? this.desktopNotifications,
      notificationFrequency: notificationFrequency ?? this.notificationFrequency,
      autoCompleteTasksInDone: autoCompleteTasksInDone ?? this.autoCompleteTasksInDone,
      showProjectProgress: showProjectProgress ?? this.showProjectProgress,
      enableDragAndDrop: enableDragAndDrop ?? this.enableDragAndDrop,
      compactTaskView: compactTaskView ?? this.compactTaskView,
      showTaskEstimates: showTaskEstimates ?? this.showTaskEstimates,
      defaultTaskPriority: defaultTaskPriority ?? this.defaultTaskPriority,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      startOfWeek: startOfWeek ?? this.startOfWeek,
      workingHoursStart: workingHoursStart ?? this.workingHoursStart,
      workingHoursEnd: workingHoursEnd ?? this.workingHoursEnd,
      workingDays: workingDays ?? this.workingDays,
      defaultExportFormat: defaultExportFormat ?? this.defaultExportFormat,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableAutoBackup: enableAutoBackup ?? this.enableAutoBackup,
      featureFlags: featureFlags ?? this.featureFlags,
      customShortcuts: customShortcuts ?? this.customShortcuts,
      dashboardPreferences: dashboardPreferences ?? this.dashboardPreferences,
    );
  }
}

/// Theme mode preferences
enum AppThemeMode {
  @JsonValue('light')
  light,
  @JsonValue('dark')
  dark,
  @JsonValue('system')
  system
}

/// Notification frequency options
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

/// Date format preferences
enum DateFormat {
  @JsonValue('mm/dd/yyyy')
  monthDayYear,
  @JsonValue('dd/mm/yyyy')
  dayMonthYear,
  @JsonValue('yyyy-mm-dd')
  yearMonthDay,
  @JsonValue('dd MMM yyyy')
  dayMonthNameYear
}

/// Time format preferences
enum TimeFormat {
  @JsonValue('12')
  hour12,
  @JsonValue('24')
  hour24
}

/// Export format preferences
enum ExportFormat {
  @JsonValue('pdf')
  pdf,
  @JsonValue('csv')
  csv,
  @JsonValue('xlsx')
  xlsx,
  @JsonValue('json')
  json
}

/// Dashboard layout and widget preferences
@JsonSerializable()
class DashboardPreferences {
  /// Show/hide recent projects widget
  final bool showRecentProjects;
  
  /// Show/hide task summary widget
  final bool showTaskSummary;
  
  /// Show/hide team activity widget
  final bool showTeamActivity;
  
  /// Show/hide analytics widget
  final bool showAnalytics;
  
  /// Show/hide calendar widget
  final bool showCalendar;
  
  /// Number of recent projects to display
  final int recentProjectsLimit;
  
  /// Default dashboard view (grid/list)
  final DashboardView defaultView;
  
  /// Widget order on dashboard
  final List<String> widgetOrder;
  
  const DashboardPreferences({
    required this.showRecentProjects,
    required this.showTaskSummary,
    required this.showTeamActivity,
    required this.showAnalytics,
    required this.showCalendar,
    required this.recentProjectsLimit,
    required this.defaultView,
    required this.widgetOrder,
  });

  factory DashboardPreferences.fromJson(Map<String, dynamic> json) => 
      _$DashboardPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardPreferencesToJson(this);

  factory DashboardPreferences.defaultPreferences() {
    return const DashboardPreferences(
      showRecentProjects: true,
      showTaskSummary: true,
      showTeamActivity: true,
      showAnalytics: false,
      showCalendar: true,
      recentProjectsLimit: 5,
      defaultView: DashboardView.grid,
      widgetOrder: [
        'recent_projects',
        'task_summary',
        'team_activity',
        'calendar',
        'analytics'
      ],
    );
  }

  DashboardPreferences copyWith({
    bool? showRecentProjects,
    bool? showTaskSummary,
    bool? showTeamActivity,
    bool? showAnalytics,
    bool? showCalendar,
    int? recentProjectsLimit,
    DashboardView? defaultView,
    List<String>? widgetOrder,
  }) {
    return DashboardPreferences(
      showRecentProjects: showRecentProjects ?? this.showRecentProjects,
      showTaskSummary: showTaskSummary ?? this.showTaskSummary,
      showTeamActivity: showTeamActivity ?? this.showTeamActivity,
      showAnalytics: showAnalytics ?? this.showAnalytics,
      showCalendar: showCalendar ?? this.showCalendar,
      recentProjectsLimit: recentProjectsLimit ?? this.recentProjectsLimit,
      defaultView: defaultView ?? this.defaultView,
      widgetOrder: widgetOrder ?? this.widgetOrder,
    );
  }
}

/// Dashboard view options
enum DashboardView {
  @JsonValue('grid')
  grid,
  @JsonValue('list')
  list,
  @JsonValue('kanban')
  kanban
}