import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/team_model.dart';
import '../../../core/services/team_service.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for team service
final teamServiceProvider = Provider<TeamService>((ref) {
  return TeamService();
});

/// Team notifier for managing team operations
class TeamNotifier extends StateNotifier<AsyncValue<List<Team>>> {
  final TeamService _teamService;
  final String _userId;

  TeamNotifier(this._teamService, this._userId) : super(const AsyncValue.loading()) {
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await _teamService.getUserTeams(_userId);
      state = AsyncValue.data(teams);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createTeam({
    required String name,
    required String description,
    required String ownerId,
  }) async {
    try {
      final team = await _teamService.createTeam(
        name: name,
        description: description,
        ownerId: ownerId,
      );
      
      final currentTeams = state.value ?? [];
      state = AsyncValue.data([...currentTeams, team]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateTeam(Team team) async {
    try {
      await _teamService.updateTeam(team);
      
      final currentTeams = state.value ?? [];
      final index = currentTeams.indexWhere((t) => t.id == team.id);
      if (index != -1) {
        final updatedTeams = [...currentTeams];
        updatedTeams[index] = team;
        state = AsyncValue.data(updatedTeams);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteTeam(String teamId) async {
    try {
      await _teamService.deleteTeam(teamId, _userId);
      
      final currentTeams = state.value ?? [];
      final updatedTeams = currentTeams.where((t) => t.id != teamId).toList();
      state = AsyncValue.data(updatedTeams);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> inviteToTeam({
    required String teamId,
    required String email,
    required TeamRole role,
    String? message,
  }) async {
    try {
      await _teamService.inviteUserToTeam(
        teamId: teamId,
        email: email,
        invitedById: _userId,
        role: role,
        message: message,
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateMemberRole({
    required String teamId,
    required String userId,
    required TeamRole newRole,
  }) async {
    try {
      await _teamService.updateMemberRole(teamId, userId, newRole, _userId);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> removeMember({
    required String teamId,
    required String userId,
  }) async {
    try {
      await _teamService.removeMemberFromTeam(teamId, userId, _userId);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    try {
      await _teamService.acceptTeamInvitation(invitationId, _userId);
      // Reload teams after accepting invitation
      await _loadTeams();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> declineInvitation(String invitationId) async {
    try {
      await _teamService.declineTeamInvitation(invitationId);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> removeMemberFromTeam(String teamId, String userId) async {
    try {
      await _teamService.removeMemberFromTeam(teamId, userId, _userId);
      // Reload teams after removing member
      await _loadTeams();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

/// Provider for team notifier
final teamNotifierProvider = StateNotifierProvider<TeamNotifier, AsyncValue<List<Team>>>((ref) {
  final teamService = ref.read(teamServiceProvider);
  final user = ref.watch(currentUserProvider).value;
  return TeamNotifier(teamService, user?.id ?? '');
});

/// Provider for getting current user's teams
final userTeamsProvider = FutureProvider.family<List<Team>, String>((ref, userId) async {
  final teamService = ref.read(teamServiceProvider);
  return await teamService.getUserTeams(userId);
});

/// Provider for getting a specific team
final teamProvider = Provider.family<AsyncValue<Team?>, String>((ref, teamId) {
  final teams = ref.watch(teamNotifierProvider);
  return teams.when(
    data: (teamList) {
      try {
        final team = teamList.firstWhere((t) => t.id == teamId);
        return AsyncValue.data(team);
      } catch (e) {
        return const AsyncValue.data(null);
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for getting team members with user data
final teamMembersProvider = FutureProvider.family<List<TeamMemberWithUser>, String>((ref, teamId) async {
  final teamService = ref.read(teamServiceProvider);
  return await teamService.getTeamMembersWithUserData(teamId);
});

/// Provider for getting team invitations
final teamInvitationsProvider = FutureProvider.family<List<TeamInvitation>, String>((ref, teamId) async {
  final teamService = ref.read(teamServiceProvider);
  return await teamService.getPendingInvitationsForTeam(teamId);
});

/// Provider for team management (alias to teamNotifierProvider for consistency)
final teamManagementProvider = teamNotifierProvider;

/// Provider for getting user invitations
final userInvitationsProvider = FutureProvider.family<List<TeamInvitation>, String>((ref, email) async {
  final teamService = ref.read(teamServiceProvider);
  return await teamService.getInvitationsForEmail(email);
});

/// Provider for checking user role in team
final userRoleInTeamProvider = Provider.family<TeamRole?, String>((ref, teamId) {
  final teams = ref.watch(teamNotifierProvider).value ?? [];
  final currentUser = ref.watch(currentUserProvider).value;
  
  if (currentUser == null) return null;
  
  final team = teams.where((t) => t.id == teamId).firstOrNull;
  if (team == null) return null;
  
  final member = team.getMember(currentUser.id);
  return member?.role;
});

/// Provider for checking if user can manage team
final canManageTeamProvider = Provider.family<bool, String>((ref, teamId) {
  final userRole = ref.watch(userRoleInTeamProvider(teamId));
  return userRole == TeamRole.owner || userRole == TeamRole.admin;
});

/// Provider for getting invitations for email
final invitationsForEmailProvider = FutureProvider.family<List<TeamInvitation>, String>((ref, email) async {
  final teamService = ref.read(teamServiceProvider);
  return await teamService.getInvitationsForEmail(email);
});

/// Provider for getting a specific team invitation
final teamInvitationProvider = FutureProvider.family<TeamInvitation?, String>((ref, invitationId) async {
  final teamService = ref.read(teamServiceProvider);
  final invitations = await teamService.getInvitationsSentByUser(''); // This would need the proper user ID
  return invitations.where((inv) => inv.id == invitationId).firstOrNull;
});