import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Service for managing user operations in ProjectFlow AI
/// Handles user CRUD operations, authentication, and profile management
class UserService {
  static const String _usersCollection = 'users';
  
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  UserService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  /// Gets the current authenticated user's profile
  Future<AppUser?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;
    
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .get();
      
      if (!doc.exists) return null;
      
      return AppUser.fromJson(doc.data()!);
    } catch (e) {
      throw UserServiceException('Failed to get current user: $e');
    }
  }

  /// Gets a user by their ID
  Future<AppUser?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      
      if (!doc.exists) return null;
      
      return AppUser.fromJson(doc.data()!);
    } catch (e) {
      throw UserServiceException('Failed to get user by ID: $e');
    }
  }

  /// Gets users by their email addresses
  Future<List<AppUser>> getUsersByEmails(List<String> emails) async {
    if (emails.isEmpty) return [];
    
    try {
      final chunks = _chunkList(emails, 10); // Firestore 'in' query limit
      final users = <AppUser>[];
      
      for (final chunk in chunks) {
        final query = await _firestore
            .collection(_usersCollection)
            .where('email', whereIn: chunk)
            .get();
        
        users.addAll(
          query.docs.map((doc) => AppUser.fromJson(doc.data())),
        );
      }
      
      return users;
    } catch (e) {
      throw UserServiceException('Failed to get users by emails: $e');
    }
  }

  /// Creates a new user profile
  Future<AppUser> createUser(AppUser user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toJson());
      
      return user;
    } catch (e) {
      throw UserServiceException('Failed to create user: $e');
    }
  }

  /// Updates an existing user profile
  Future<AppUser> updateUser(AppUser user) async {
    try {
      final updatedUser = user.copyWith(
        // Always update the last active timestamp when updating
        lastActiveAt: DateTime.now(),
      );
      
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .update(updatedUser.toJson());
      
      return updatedUser;
    } catch (e) {
      throw UserServiceException('Failed to update user: $e');
    }
  }

  /// Updates specific user fields (partial update)
  Future<void> updateUserFields(String userId, Map<String, dynamic> fields) async {
    try {
      // Add timestamp for any update
      fields['lastActiveAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(fields);
    } catch (e) {
      throw UserServiceException('Failed to update user fields: $e');
    }
  }

  /// Updates user preferences
  Future<void> updateUserPreferences(String userId, UserPreferences preferences) async {
    try {
      await updateUserFields(userId, {
        'preferences': preferences.toJson(),
      });
    } catch (e) {
      throw UserServiceException('Failed to update user preferences: $e');
    }
  }

  /// Updates user's last login timestamp
  Future<void> updateLastLogin(String userId) async {
    try {
      await updateUserFields(userId, {
        'lastLoginAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw UserServiceException('Failed to update last login: $e');
    }
  }

  /// Updates user's last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await updateUserFields(userId, {
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw UserServiceException('Failed to update last active: $e');
    }
  }

  /// Marks user's email as verified
  Future<void> markEmailAsVerified(String userId) async {
    try {
      await updateUserFields(userId, {
        'isEmailVerified': true,
      });
    } catch (e) {
      throw UserServiceException('Failed to mark email as verified: $e');
    }
  }

  /// Enables/disables two-factor authentication
  Future<void> updateTwoFactorStatus(String userId, bool enabled) async {
    try {
      await updateUserFields(userId, {
        'hasTwoFactorEnabled': enabled,
      });
    } catch (e) {
      throw UserServiceException('Failed to update two-factor status: $e');
    }
  }

  /// Completes user onboarding
  Future<void> completeOnboarding(String userId) async {
    try {
      await updateUserFields(userId, {
        'hasCompletedOnboarding': true,
      });
    } catch (e) {
      throw UserServiceException('Failed to complete onboarding: $e');
    }
  }

  /// Adds a user to a team
  Future<void> addUserToTeam(String userId, String teamId) async {
    try {
      await updateUserFields(userId, {
        'teamIds': FieldValue.arrayUnion([teamId]),
      });
    } catch (e) {
      throw UserServiceException('Failed to add user to team: $e');
    }
  }

  /// Removes a user from a team
  Future<void> removeUserFromTeam(String userId, String teamId) async {
    try {
      await updateUserFields(userId, {
        'teamIds': FieldValue.arrayRemove([teamId]),
      });
    } catch (e) {
      throw UserServiceException('Failed to remove user from team: $e');
    }
  }

  /// Adds a user to a project
  Future<void> addUserToProject(String userId, String projectId) async {
    try {
      await updateUserFields(userId, {
        'projectIds': FieldValue.arrayUnion([projectId]),
      });
    } catch (e) {
      throw UserServiceException('Failed to add user to project: $e');
    }
  }

  /// Removes a user from a project
  Future<void> removeUserFromProject(String userId, String projectId) async {
    try {
      await updateUserFields(userId, {
        'projectIds': FieldValue.arrayRemove([projectId]),
      });
    } catch (e) {
      throw UserServiceException('Failed to remove user from project: $e');
    }
  }

  /// Updates user's profile photo
  Future<void> updateProfilePhoto(String userId, String photoUrl) async {
    try {
      await updateUserFields(userId, {
        'photoUrl': photoUrl,
      });
    } catch (e) {
      throw UserServiceException('Failed to update profile photo: $e');
    }
  }

  /// Updates user's basic profile information
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
    try {
      final updates = <String, dynamic>{};
      
      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (displayName != null) updates['displayName'] = displayName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (jobTitle != null) updates['jobTitle'] = jobTitle;
      if (department != null) updates['department'] = department;
      if (company != null) updates['company'] = company;
      if (bio != null) updates['bio'] = bio;
      if (location != null) updates['location'] = location;
      if (timezone != null) updates['timezone'] = timezone;
      if (skills != null) updates['skills'] = skills;
      
      if (updates.isNotEmpty) {
        await updateUserFields(userId, updates);
      }
    } catch (e) {
      throw UserServiceException('Failed to update basic profile: $e');
    }
  }

  /// Searches users by name or email
  Future<List<AppUser>> searchUsers(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final queryLower = query.toLowerCase();
      
      // Search by display name (case-insensitive)
      final nameQuery = await _firestore
          .collection(_usersCollection)
          .where('displayName', isGreaterThanOrEqualTo: queryLower)
          .where('displayName', isLessThan: queryLower + '\uf8ff')
          .limit(limit)
          .get();
      
      // Search by email (case-insensitive)
      final emailQuery = await _firestore
          .collection(_usersCollection)
          .where('email', isGreaterThanOrEqualTo: queryLower)
          .where('email', isLessThan: queryLower + '\uf8ff')
          .limit(limit)
          .get();
      
      final users = <String, AppUser>{}; // Use map to avoid duplicates
      
      for (final doc in nameQuery.docs) {
        users[doc.id] = AppUser.fromJson(doc.data());
      }
      
      for (final doc in emailQuery.docs) {
        users[doc.id] = AppUser.fromJson(doc.data());
      }
      
      return users.values.toList();
    } catch (e) {
      throw UserServiceException('Failed to search users: $e');
    }
  }

  /// Gets users by their current status
  Future<List<AppUser>> getUsersByStatus(UserStatus status, {int limit = 50}) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('status', isEqualTo: status.name)
          .limit(limit)
          .get();
      
      return query.docs
          .map((doc) => AppUser.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw UserServiceException('Failed to get users by status: $e');
    }
  }

  /// Gets users by their role
  Future<List<AppUser>> getUsersByRole(UserRole role, {int limit = 50}) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: role.name)
          .limit(limit)
          .get();
      
      return query.docs
          .map((doc) => AppUser.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw UserServiceException('Failed to get users by role: $e');
    }
  }

  /// Gets recently active users
  Future<List<AppUser>> getRecentlyActiveUsers({
    int limit = 20,
    Duration withinDuration = const Duration(days: 7),
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(withinDuration);
      
      final query = await _firestore
          .collection(_usersCollection)
          .where('lastActiveAt', isGreaterThan: Timestamp.fromDate(cutoffDate))
          .orderBy('lastActiveAt', descending: true)
          .limit(limit)
          .get();
      
      return query.docs
          .map((doc) => AppUser.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw UserServiceException('Failed to get recently active users: $e');
    }
  }

  /// Gets user statistics
  Future<UserStatistics> getUserStatistics() async {
    try {
      // Total users
      final totalUsersQuery = await _firestore
          .collection(_usersCollection)
          .count()
          .get();
      
      // Active users (last 30 days)
      final activeUsersQuery = await _firestore
          .collection(_usersCollection)
          .where('lastActiveAt', isGreaterThan: 
              Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))))
          .count()
          .get();
      
      // New users (last 7 days)
      final newUsersQuery = await _firestore
          .collection(_usersCollection)
          .where('createdAt', isGreaterThan: 
              Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))))
          .count()
          .get();
      
      return UserStatistics(
        totalUsers: totalUsersQuery.count ?? 0,
        activeUsersLast30Days: activeUsersQuery.count ?? 0,
        newUsersLast7Days: newUsersQuery.count ?? 0,
      );
    } catch (e) {
      throw UserServiceException('Failed to get user statistics: $e');
    }
  }

  /// Deactivates a user account
  Future<void> deactivateUser(String userId) async {
    try {
      await updateUserFields(userId, {
        'status': UserStatus.inactive.name,
      });
    } catch (e) {
      throw UserServiceException('Failed to deactivate user: $e');
    }
  }

  /// Reactivates a user account
  Future<void> reactivateUser(String userId) async {
    try {
      await updateUserFields(userId, {
        'status': UserStatus.active.name,
      });
    } catch (e) {
      throw UserServiceException('Failed to reactivate user: $e');
    }
  }

  /// Suspends a user account
  Future<void> suspendUser(String userId) async {
    try {
      await updateUserFields(userId, {
        'status': UserStatus.suspended.name,
      });
    } catch (e) {
      throw UserServiceException('Failed to suspend user: $e');
    }
  }

  /// Stream of user changes for real-time updates
  Stream<AppUser?> watchUser(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return AppUser.fromJson(doc.data()!);
        });
  }

  /// Stream of current user changes
  Stream<AppUser?> watchCurrentUser() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      return watchUser(user.uid);
    });
  }

  /// Deletes a user account (soft delete by setting status)
  Future<void> deleteUser(String userId) async {
    try {
      // Soft delete by setting status to inactive
      // In a real implementation, you might want to anonymize data
      await updateUserFields(userId, {
        'status': UserStatus.inactive.name,
        'email': 'deleted_${DateTime.now().millisecondsSinceEpoch}@deleted.com',
        'displayName': 'Deleted User',
        'firstName': 'Deleted',
        'lastName': 'User',
      });
    } catch (e) {
      throw UserServiceException('Failed to delete user: $e');
    }
  }

  /// Helper method to chunk lists for Firestore 'in' queries
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }
}

/// User statistics model
class UserStatistics {
  final int totalUsers;
  final int activeUsersLast30Days;
  final int newUsersLast7Days;
  
  const UserStatistics({
    required this.totalUsers,
    required this.activeUsersLast30Days,
    required this.newUsersLast7Days,
  });
  
  double get activeUserPercentage => 
      totalUsers > 0 ? (activeUsersLast30Days / totalUsers) * 100 : 0.0;
}

/// Custom exception for user service operations
class UserServiceException implements Exception {
  final String message;
  
  const UserServiceException(this.message);
  
  @override
  String toString() => 'UserServiceException: $message';
}