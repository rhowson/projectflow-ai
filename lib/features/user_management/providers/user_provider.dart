import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/user_service.dart';

/// Provider for user service
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// Provider for current authenticated user
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final userService = ref.read(userServiceProvider);
  return userService.watchCurrentUser();
});

/// Provider for getting a specific user by ID
final userByIdProvider = StreamProvider.family<AppUser?, String>((ref, userId) {
  final userService = ref.read(userServiceProvider);
  return userService.watchUser(userId);
});

/// Provider for Firebase Auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for current Firebase user
final firebaseUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Notifier for user search functionality
class UserSearchNotifier extends StateNotifier<AsyncValue<List<AppUser>>> {
  UserSearchNotifier(this._userService) : super(const AsyncValue.data([]));

  final UserService _userService;

  /// Searches users by query
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    
    try {
      final results = await _userService.searchUsers(query);
      state = AsyncValue.data(results);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Clears search results
  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

/// Provider for user search
final userSearchProvider = StateNotifierProvider<UserSearchNotifier, AsyncValue<List<AppUser>>>((ref) {
  final userService = ref.read(userServiceProvider);
  return UserSearchNotifier(userService);
});

/// Notifier for user statistics
class UserStatisticsNotifier extends StateNotifier<AsyncValue<UserStatistics>> {
  UserStatisticsNotifier(this._userService) : super(const AsyncValue.loading()) {
    _loadStatistics();
  }

  final UserService _userService;

  Future<void> _loadStatistics() async {
    try {
      final stats = await _userService.getUserStatistics();
      state = AsyncValue.data(stats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refreshes user statistics
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadStatistics();
  }
}

/// Provider for user statistics
final userStatisticsProvider = StateNotifierProvider<UserStatisticsNotifier, AsyncValue<UserStatistics>>((ref) {
  final userService = ref.read(userServiceProvider);
  return UserStatisticsNotifier(userService);
});

/// Provider for recently active users
final recentlyActiveUsersProvider = FutureProvider.family<List<AppUser>, int>((ref, limit) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getRecentlyActiveUsers(limit: limit);
});

/// Provider for users by role
final usersByRoleProvider = FutureProvider.family<List<AppUser>, UserRole>((ref, role) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getUsersByRole(role);
});

/// Provider for users by status
final usersByStatusProvider = FutureProvider.family<List<AppUser>, UserStatus>((ref, status) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getUsersByStatus(status);
});

/// Notifier for user management operations
class UserManagementNotifier extends StateNotifier<AsyncValue<void>> {
  UserManagementNotifier(this._userService, this._ref) : super(const AsyncValue.data(null));

  final UserService _userService;
  final Ref _ref;

  /// Creates a new user account
  Future<AppUser> createUser({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? photoUrl,
    UserRole role = UserRole.member,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final newUser = AppUser.createNew(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        photoUrl: photoUrl,
        role: role,
      );
      
      final createdUser = await _userService.createUser(newUser);
      state = const AsyncValue.data(null);
      
      // Invalidate related providers
      _ref.invalidate(userStatisticsProvider);
      _ref.invalidate(recentlyActiveUsersProvider);
      
      return createdUser;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Updates the current user's profile
  Future<void> updateProfile(AppUser updatedUser) async {
    state = const AsyncValue.loading();
    
    try {
      await _userService.updateUser(updatedUser);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Updates user preferences
  Future<void> updatePreferences(String userId, UserPreferences preferences) async {
    state = const AsyncValue.loading();
    
    try {
      await _userService.updateUserPreferences(userId, preferences);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Updates basic profile information
  Future<void> updateBasicProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? displayName,
    String? phoneNumber,
    String? jobTitle,
    String? department,
    String? company,
    String? bio,
    String? location,
    String? timezone,
    List<String>? skills,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _userService.updateBasicProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
        phoneNumber: phoneNumber,
        jobTitle: jobTitle,
        department: department,
        company: company,
        bio: bio,
        location: location,
        timezone: timezone,
        skills: skills,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Updates profile photo
  Future<void> updateProfilePhoto(String userId, String photoUrl) async {
    state = const AsyncValue.loading();
    
    try {
      await _userService.updateProfilePhoto(userId, photoUrl);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Completes user onboarding
  Future<void> completeOnboarding(String userId) async {
    state = const AsyncValue.loading();
    
    try {
      await _userService.completeOnboarding(userId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Updates last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await _userService.updateLastActive(userId);
    } catch (e) {
      // Silently fail for last active updates
    }
  }

  /// Enables/disables two-factor authentication
  Future<void> updateTwoFactorStatus(String userId, bool enabled) async {
    state = const AsyncValue.loading();
    
    try {
      await _userService.updateTwoFactorStatus(userId, enabled);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Deactivates a user account
  Future<void> deactivateUser(String userId) async {
    state = const AsyncValue.loading();
    
    try {
      await _userService.deactivateUser(userId);
      state = const AsyncValue.data(null);
      
      // Invalidate related providers
      _ref.invalidate(userStatisticsProvider);
      _ref.invalidate(usersByStatusProvider(UserStatus.active));
      _ref.invalidate(usersByStatusProvider(UserStatus.inactive));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Reactivates a user account
  Future<void> reactivateUser(String userId) async {
    state = const AsyncValue.loading();
    
    try {
      await _userService.reactivateUser(userId);
      state = const AsyncValue.data(null);
      
      // Invalidate related providers
      _ref.invalidate(userStatisticsProvider);
      _ref.invalidate(usersByStatusProvider(UserStatus.active));
      _ref.invalidate(usersByStatusProvider(UserStatus.inactive));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Suspends a user account
  Future<void> suspendUser(String userId) async {
    state = const AsyncValue.loading();
    
    try {
      await _userService.suspendUser(userId);
      state = const AsyncValue.data(null);
      
      // Invalidate related providers
      _ref.invalidate(userStatisticsProvider);
      _ref.invalidate(usersByStatusProvider(UserStatus.suspended));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Deletes a user account
  Future<void> deleteUser(String userId) async {
    state = const AsyncValue.loading();
    
    try {
      await _userService.deleteUser(userId);
      state = const AsyncValue.data(null);
      
      // Invalidate all user-related providers
      _ref.invalidate(userStatisticsProvider);
      _ref.invalidate(recentlyActiveUsersProvider);
      _ref.invalidate(usersByStatusProvider);
      _ref.invalidate(usersByRoleProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for user management operations
final userManagementProvider = StateNotifierProvider<UserManagementNotifier, AsyncValue<void>>((ref) {
  final userService = ref.read(userServiceProvider);
  return UserManagementNotifier(userService, ref);
});

/// Helper providers for accessing current user data

/// Provider for current user's preferences
final currentUserPreferencesProvider = Provider<UserPreferences?>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.when(
    data: (user) => user?.preferences,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for current user's role
final currentUserRoleProvider = Provider<UserRole?>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.when(
    data: (user) => user?.role,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for checking if current user is admin
final isCurrentUserAdminProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.when(
    data: (user) => user?.isAdmin ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for checking if current user has premium access
final currentUserHasPremiumProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.when(
    data: (user) => user?.hasPremiumAccess ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for checking if current user can manage teams
final currentUserCanManageTeamsProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.when(
    data: (user) => user?.canManageTeams ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for checking if current user is online
final isCurrentUserOnlineProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.when(
    data: (user) => user?.isOnline ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});