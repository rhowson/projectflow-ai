import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/team_model.dart';
import '../../../core/services/team_service.dart';
import '../../user_management/providers/user_provider.dart';

/// Provider for team service
final teamServiceProvider = Provider<TeamService>((ref) {
  final userService = ref.read(userServiceProvider);
  return TeamService(userService: userService);
});

/// Provider for getting a specific team by ID
final teamByIdProvider = StreamProvider.family<Team?, String>((ref, teamId) {
  final teamService = ref.read(teamServiceProvider);
  return teamService.watchTeam(teamId);
});

/// Provider for getting teams for a specific user
final userTeamsProvider = StreamProvider.family<List<Team>, String>((ref, userId) {
  final teamService = ref.read(teamServiceProvider);
  return teamService.watchUserTeams(userId);
});

/// Notifier for team creation and management
class TeamManagementNotifier extends StateNotifier<AsyncValue<void>> {
  TeamManagementNotifier(this._teamService, this._ref) : super(const AsyncValue.data(null));

  final TeamService _teamService;
  final Ref _ref;

  /// Creates a new team
  Future<Team> createTeam({
    required String name,
    required String description,
    required String ownerId,
    String? logoUrl,
    String? organizationId,
    TeamPlan plan = TeamPlan.free,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final team = await _teamService.createTeam(
        name: name,
        description: description,
        ownerId: ownerId,
        logoUrl: logoUrl,
        organizationId: organizationId,
        plan: plan,
      );
      
      state = const AsyncValue.data(null);
      
      // Invalidate related providers
      _ref.invalidate(userTeamsProvider(ownerId));
      
      return team;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Updates team information
  Future<void> updateTeam(Team team) async {
    state = const AsyncValue.loading();
    
    try {
      await _teamService.updateTeam(team);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Updates team settings
  Future<void> updateTeamSettings(String teamId, TeamSettings settings) async {
    state = const AsyncValue.loading();
    
    try {
      await _teamService.updateTeamSettings(teamId, settings);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Removes a member from a team
  Future<void> removeMemberFromTeam(String teamId, String memberUserId, String removedById) async {
    state = const AsyncValue.loading();
    
    try {
      await _teamService.removeMemberFromTeam(teamId, memberUserId, removedById);
      state = const AsyncValue.data(null);
      
      // Invalidate related providers
      _ref.invalidate(userTeamsProvider(memberUserId));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Updates a team member's role
  Future<void> updateMemberRole(String teamId, String memberUserId, TeamRole newRole, String updatedById) async {
    state = const AsyncValue.loading();
    
    try {
      await _teamService.updateMemberRole(teamId, memberUserId, newRole, updatedById);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Transfers team ownership
  Future<void> transferOwnership(String teamId, String newOwnerId, String currentOwnerId) async {
    state = const AsyncValue.loading();
    
    try {
      await _teamService.transferOwnership(teamId, newOwnerId, currentOwnerId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Archives a team
  Future<void> archiveTeam(String teamId, String archivedById) async {
    state = const AsyncValue.loading();
    
    try {
      await _teamService.archiveTeam(teamId, archivedById);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Deletes a team
  Future<void> deleteTeam(String teamId, String deletedById) async {
    state = const AsyncValue.loading();
    
    try {
      await _teamService.deleteTeam(teamId, deletedById);
      state = const AsyncValue.data(null);
      
      // Invalidate related providers
      _ref.invalidate(userTeamsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for team management operations
final teamManagementProvider = StateNotifierProvider<TeamManagementNotifier, AsyncValue<void>>((ref) {
  final teamService = ref.read(teamServiceProvider);
  return TeamManagementNotifier(teamService, ref);
});

/// Notifier for team invitation management
class TeamInvitationNotifier extends StateNotifier<AsyncValue<void>> {
  TeamInvitationNotifier(this._teamService, this._ref) : super(const AsyncValue.data(null));

  final TeamService _teamService;
  final Ref _ref;

  /// Invites a user to join a team
  Future<TeamInvitation> inviteUserToTeam({
    required String teamId,
    required String email,
    required String invitedById,
    required TeamRole role,
    String? message,
    String? customTitle,
    int expirationDays = 7,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final invitation = await _teamService.inviteUserToTeam(
        teamId: teamId,
        email: email,
        invitedById: invitedById,
        role: role,
        message: message,
        customTitle: customTitle,
        expirationDays: expirationDays,
      );
      
      state = const AsyncValue.data(null);
      
      // Invalidate invitation providers
      _ref.invalidate(pendingInvitationsForTeamProvider(teamId));
      _ref.invalidate(invitationsSentByUserProvider(invitedById));
      
      return invitation;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Accepts a team invitation
  Future<void> acceptTeamInvitation(String invitationId, String userId) async {
    state = const AsyncValue.loading();
    
    try {
      await _teamService.acceptTeamInvitation(invitationId, userId);
      state = const AsyncValue.data(null);
      
      // Invalidate related providers
      _ref.invalidate(userTeamsProvider(userId));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Declines a team invitation
  Future<void> declineTeamInvitation(String invitationId) async {
    state = const AsyncValue.loading();
    
    try {
      await _teamService.declineTeamInvitation(invitationId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Cancels a team invitation
  Future<void> cancelTeamInvitation(String invitationId, String cancelledById) async {
    state = const AsyncValue.loading();
    
    try {
      await _teamService.cancelTeamInvitation(invitationId, cancelledById);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for team invitation management
final teamInvitationProvider = StateNotifierProvider<TeamInvitationNotifier, AsyncValue<void>>((ref) {
  final teamService = ref.read(teamServiceProvider);
  return TeamInvitationNotifier(teamService, ref);
});

/// Provider for team invitations for a specific email
final invitationsForEmailProvider = FutureProvider.family<List<TeamInvitation>, String>((ref, email) async {
  final teamService = ref.read(teamServiceProvider);
  return await teamService.getInvitationsForEmail(email);
});

/// Provider for team invitations sent by a user
final invitationsSentByUserProvider = FutureProvider.family<List<TeamInvitation>, String>((ref, userId) async {
  final teamService = ref.read(teamServiceProvider);
  return await teamService.getInvitationsSentByUser(userId);
});

/// Provider for pending invitations for a team
final pendingInvitationsForTeamProvider = FutureProvider.family<List<TeamInvitation>, String>((ref, teamId) async {
  final teamService = ref.read(teamServiceProvider);
  return await teamService.getPendingInvitationsForTeam(teamId);
});

/// Helper providers for team data

/// Provider for checking if current user owns a specific team
final isTeamOwnerProvider = Provider.family<bool, String>((ref, teamId) {
  final team = ref.watch(teamByIdProvider(teamId));
  final currentUser = ref.watch(currentUserProvider);
  
  return team.when(
    data: (teamData) => currentUser.when(
      data: (user) => teamData?.ownerId == user?.id,
      loading: () => false,
      error: (_, __) => false,
    ),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for checking if current user can manage a specific team
final canManageTeamProvider = Provider.family<bool, String>((ref, teamId) {
  final team = ref.watch(teamByIdProvider(teamId));
  final currentUser = ref.watch(currentUserProvider);
  
  return team.when(
    data: (teamData) => currentUser.when(
      data: (user) {
        if (teamData == null || user == null) return false;
        final member = teamData.getMember(user.id);
        return member?.canManageMembers ?? false;
      },
      loading: () => false,
      error: (_, __) => false,
    ),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for getting current user's role in a specific team
final userRoleInTeamProvider = Provider.family<TeamRole?, String>((ref, teamId) {
  final team = ref.watch(teamByIdProvider(teamId));
  final currentUser = ref.watch(currentUserProvider);
  
  return team.when(
    data: (teamData) => currentUser.when(
      data: (user) {
        if (teamData == null || user == null) return null;
        final member = teamData.getMember(user.id);
        return member?.role;
      },
      loading: () => null,
      error: (_, __) => null,
    ),
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for checking if a team is at capacity
final isTeamAtCapacityProvider = Provider.family<bool, String>((ref, teamId) {
  final team = ref.watch(teamByIdProvider(teamId));
  
  return team.when(
    data: (teamData) => teamData?.isAtCapacity ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for getting team member count
final teamMemberCountProvider = Provider.family<int, String>((ref, teamId) {
  final team = ref.watch(teamByIdProvider(teamId));
  
  return team.when(
    data: (teamData) => teamData?.activeMemberCount ?? 0,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for getting teams that current user owns
final ownedTeamsProvider = Provider<AsyncValue<List<Team>>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  
  return currentUser.when(
    data: (user) {
      if (user == null) return const AsyncValue.data([]);
      
      final userTeams = ref.watch(userTeamsProvider(user.id));
      return userTeams.when(
        data: (teams) => AsyncValue.data(
          teams.where((team) => team.ownerId == user.id).toList(),
        ),
        loading: () => const AsyncValue.loading(),
        error: (e, stack) => AsyncValue.error(e, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, stack) => AsyncValue.error(e, stack),
  );
});

/// Provider for getting teams that current user is a member of (but doesn't own)
final memberTeamsProvider = Provider<AsyncValue<List<Team>>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  
  return currentUser.when(
    data: (user) {
      if (user == null) return const AsyncValue.data([]);
      
      final userTeams = ref.watch(userTeamsProvider(user.id));
      return userTeams.when(
        data: (teams) => AsyncValue.data(
          teams.where((team) => team.ownerId != user.id).toList(),
        ),
        loading: () => const AsyncValue.loading(),
        error: (e, stack) => AsyncValue.error(e, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, stack) => AsyncValue.error(e, stack),
  );
});

// currentUserProvider is already imported from user_management/providers/user_provider.dart