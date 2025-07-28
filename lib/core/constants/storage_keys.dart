class StorageKeys {
  // User preferences
  static const String isDarkMode = 'is_dark_mode';
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String emailUpdatesEnabled = 'email_updates_enabled';
  
  // Authentication
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String isLoggedIn = 'is_logged_in';
  
  // App state
  static const String lastOpenedProject = 'last_opened_project';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String appVersion = 'app_version';
  
  // Cache keys
  static const String projectsCache = 'projects_cache';
  static const String tasksCache = 'tasks_cache';
  static const String teamMembersCache = 'team_members_cache';
  
  // Settings
  static const String defaultProjectType = 'default_project_type';
  static const String autoSaveEnabled = 'auto_save_enabled';
  static const String syncEnabled = 'sync_enabled';
}