import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_model.dart';
import 'user_service.dart';

/// Service for managing team operations in ProjectFlow AI
/// Handles team CRUD operations, member management, and collaboration features
class TeamService {
  static const String _teamsCollection = 'teams';
  static const String _invitationsCollection = 'team_invitations';
  
  final FirebaseFirestore _firestore;
  final UserService _userService;
  
  TeamService({
    FirebaseFirestore? firestore,
    UserService? userService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _userService = userService ?? UserService();

  /// Creates a new team
  Future<Team> createTeam({
    required String name,
    required String description,
    required String ownerId,
    String? logoUrl,
    String? organizationId,
    TeamPlan plan = TeamPlan.free,
  }) async {
    try {
      final teamId = _firestore.collection(_teamsCollection).doc().id;
      
      final team = Team.createNew(
        id: teamId,
        name: name,
        description: description,
        ownerId: ownerId,
        logoUrl: logoUrl,
        organizationId: organizationId,
        plan: plan,
      );
      
      // Create team document
      await _firestore
          .collection(_teamsCollection)
          .doc(teamId)
          .set(team.toJson());
      
      // Add team to owner's team list
      await _userService.addUserToTeam(ownerId, teamId);
      
      return team;
    } catch (e) {
      throw TeamServiceException('Failed to create team: $e');
    }
  }

  /// Gets a team by ID
  Future<Team?> getTeamById(String teamId) async {
    try {
      final doc = await _firestore
          .collection(_teamsCollection)
          .doc(teamId)
          .get();
      
      if (!doc.exists) return null;
      
      return Team.fromJson(doc.data()!);
    } catch (e) {
      throw TeamServiceException('Failed to get team by ID: $e');
    }
  }

  /// Gets teams for a specific user
  Future<List<Team>> getUserTeams(String userId) async {
    try {
      final query = await _firestore
          .collection(_teamsCollection)
          .where('members', arrayContainsAny: [
            {'userId': userId}
          ])
          .get();
      
      return query.docs
          .map((doc) => Team.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw TeamServiceException('Failed to get user teams: $e');
    }
  }

  /// Updates team information
  Future<Team> updateTeam(Team team) async {
    try {
      final updatedTeam = team.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _firestore
          .collection(_teamsCollection)
          .doc(team.id)
          .update(updatedTeam.toJson());
      
      return updatedTeam;
    } catch (e) {
      throw TeamServiceException('Failed to update team: $e');
    }
  }

  /// Updates specific team fields
  Future<void> updateTeamFields(String teamId, Map<String, dynamic> fields) async {
    try {
      fields['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(_teamsCollection)
          .doc(teamId)
          .update(fields);
    } catch (e) {
      throw TeamServiceException('Failed to update team fields: $e');
    }
  }

  /// Updates team settings
  Future<void> updateTeamSettings(String teamId, TeamSettings settings) async {
    try {
      await updateTeamFields(teamId, {
        'settings': settings.toJson(),
      });
    } catch (e) {
      throw TeamServiceException('Failed to update team settings: $e');
    }
  }

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
    try {
      // Check if team exists and if inviter has permission
      final team = await getTeamById(teamId);
      if (team == null) {
        throw TeamServiceException('Team not found');
      }
      
      final inviter = team.getMember(invitedById);
      if (inviter == null || !inviter.canManageMembers) {
        throw TeamServiceException('Insufficient permissions to invite members');
      }
      
      // Check if team is at capacity
      if (team.isAtCapacity) {
        throw TeamServiceException('Team is at capacity for the current plan');
      }
      
      // Check if user is already a member
      final existingUsers = await _userService.getUsersByEmails([email]);
      if (existingUsers.isNotEmpty) {
        final existingUser = existingUsers.first;
        if (team.hasMember(existingUser.id)) {
          throw TeamServiceException('User is already a member of this team');
        }
      }
      
      // Check for existing pending invitation
      final existingInvitation = await _getPendingInvitation(teamId, email);
      if (existingInvitation != null) {
        throw TeamServiceException('There is already a pending invitation for this email');
      }
      
      final invitationId = _firestore.collection(_invitationsCollection).doc().id;
      
      final invitation = TeamInvitation.createNew(
        id: invitationId,
        teamId: teamId,
        email: email,
        invitedById: invitedById,
        role: role,
        message: message,
        customTitle: customTitle,
        expirationDays: expirationDays,
      );
      
      await _firestore
          .collection(_invitationsCollection)
          .doc(invitationId)
          .set(invitation.toJson());
      
      return invitation;
    } catch (e) {
      if (e is TeamServiceException) rethrow;
      throw TeamServiceException('Failed to invite user to team: $e');
    }
  }

  /// Accepts a team invitation
  Future<void> acceptTeamInvitation(String invitationId, String userId) async {
    try {
      final invitation = await _getInvitationById(invitationId);
      if (invitation == null) {
        throw TeamServiceException('Invitation not found');
      }
      
      if (!invitation.isPending) {
        throw TeamServiceException('Invitation is no longer valid');
      }
      
      final team = await getTeamById(invitation.teamId);
      if (team == null) {
        throw TeamServiceException('Team not found');
      }
      
      // Check if team is at capacity
      if (team.isAtCapacity) {
        throw TeamServiceException('Team is at capacity');
      }
      
      final user = await _userService.getUserById(userId);
      if (user == null) {
        throw TeamServiceException('User not found');
      }
      
      // Verify email matches
      if (user.email != invitation.email) {
        throw TeamServiceException('Email does not match invitation');
      }
      
      // Add member to team
      final newMember = TeamMember.createMember(
        userId: userId,
        addedById: invitation.invitedById,
        role: invitation.role,
        customTitle: invitation.customTitle,
      ).copyWith(status: TeamMemberStatus.active);
      
      final updatedMembers = [...team.members, newMember];
      
      // Update team with new member
      await updateTeamFields(invitation.teamId, {
        'members': updatedMembers.map((m) => m.toJson()).toList(),
      });
      
      // Add team to user's team list
      await _userService.addUserToTeam(userId, invitation.teamId);
      
      // Mark invitation as accepted
      await _updateInvitationStatus(invitationId, InvitationStatus.accepted);
      
    } catch (e) {
      if (e is TeamServiceException) rethrow;
      throw TeamServiceException('Failed to accept team invitation: $e');
    }
  }

  /// Declines a team invitation
  Future<void> declineTeamInvitation(String invitationId) async {
    try {
      await _updateInvitationStatus(invitationId, InvitationStatus.declined);
    } catch (e) {
      throw TeamServiceException('Failed to decline team invitation: $e');
    }
  }

  /// Cancels a team invitation
  Future<void> cancelTeamInvitation(String invitationId, String cancelledById) async {
    try {
      final invitation = await _getInvitationById(invitationId);
      if (invitation == null) {
        throw TeamServiceException('Invitation not found');
      }
      
      // Check if user has permission to cancel
      final team = await getTeamById(invitation.teamId);
      if (team == null) {
        throw TeamServiceException('Team not found');
      }
      
      final member = team.getMember(cancelledById);
      if (member == null || !member.canManageMembers) {
        throw TeamServiceException('Insufficient permissions to cancel invitation');
      }
      
      await _updateInvitationStatus(invitationId, InvitationStatus.cancelled);
    } catch (e) {
      if (e is TeamServiceException) rethrow;
      throw TeamServiceException('Failed to cancel team invitation: $e');
    }
  }

  /// Removes a member from a team
  Future<void> removeMemberFromTeam(String teamId, String memberUserId, String removedById) async {
    try {
      final team = await getTeamById(teamId);
      if (team == null) {
        throw TeamServiceException('Team not found');
      }
      
      // Check permissions
      final remover = team.getMember(removedById);
      if (remover == null || !remover.canManageMembers) {
        throw TeamServiceException('Insufficient permissions to remove members');
      }
      
      // Cannot remove the owner
      if (memberUserId == team.ownerId) {
        throw TeamServiceException('Cannot remove team owner');
      }
      
      // Remove member from team
      final updatedMembers = team.members
          .where((m) => m.userId != memberUserId)
          .toList();
      
      await updateTeamFields(teamId, {
        'members': updatedMembers.map((m) => m.toJson()).toList(),
      });
      
      // Remove team from user's team list
      await _userService.removeUserFromTeam(memberUserId, teamId);
      
    } catch (e) {
      if (e is TeamServiceException) rethrow;
      throw TeamServiceException('Failed to remove member from team: $e');
    }
  }

  /// Updates a team member's role
  Future<void> updateMemberRole(String teamId, String memberUserId, TeamRole newRole, String updatedById) async {
    try {
      final team = await getTeamById(teamId);
      if (team == null) {
        throw TeamServiceException('Team not found');
      }
      
      // Check permissions
      final updater = team.getMember(updatedById);
      if (updater == null || !updater.canManageMembers) {
        throw TeamServiceException('Insufficient permissions to update member roles');
      }
      
      // Cannot change owner role
      if (memberUserId == team.ownerId) {
        throw TeamServiceException('Cannot change owner role');
      }
      
      // Update member role
      final updatedMembers = team.members.map((member) {
        if (member.userId == memberUserId) {
          return member.copyWith(role: newRole);
        }
        return member;
      }).toList();
      
      await updateTeamFields(teamId, {
        'members': updatedMembers.map((m) => m.toJson()).toList(),
      });
      
    } catch (e) {
      if (e is TeamServiceException) rethrow;
      throw TeamServiceException('Failed to update member role: $e');
    }
  }

  /// Transfers team ownership
  Future<void> transferOwnership(String teamId, String newOwnerId, String currentOwnerId) async {
    try {
      final team = await getTeamById(teamId);
      if (team == null) {
        throw TeamServiceException('Team not found');
      }
      
      // Verify current owner
      if (team.ownerId != currentOwnerId) {
        throw TeamServiceException('Only the current owner can transfer ownership');
      }
      
      // Verify new owner is a team member
      final newOwner = team.getMember(newOwnerId);
      if (newOwner == null) {
        throw TeamServiceException('New owner must be a team member');
      }
      
      // Update team with new owner
      final updatedMembers = team.members.map((member) {
        if (member.userId == currentOwnerId) {
          return member.copyWith(role: TeamRole.admin);
        } else if (member.userId == newOwnerId) {
          return member.copyWith(role: TeamRole.owner);
        }
        return member;
      }).toList();
      
      await updateTeamFields(teamId, {
        'ownerId': newOwnerId,
        'members': updatedMembers.map((m) => m.toJson()).toList(),
      });
      
    } catch (e) {
      if (e is TeamServiceException) rethrow;
      throw TeamServiceException('Failed to transfer ownership: $e');
    }
  }

  /// Gets team invitations for a specific email
  Future<List<TeamInvitation>> getInvitationsForEmail(String email) async {
    try {
      final query = await _firestore
          .collection(_invitationsCollection)
          .where('email', isEqualTo: email)
          .where('status', isEqualTo: InvitationStatus.pending.name)
          .get();
      
      return query.docs
          .map((doc) => TeamInvitation.fromJson(doc.data()))
          .where((invitation) => invitation.isPending)
          .toList();
    } catch (e) {
      throw TeamServiceException('Failed to get invitations for email: $e');
    }
  }

  /// Gets team invitations sent by a user
  Future<List<TeamInvitation>> getInvitationsSentByUser(String userId) async {
    try {
      final query = await _firestore
          .collection(_invitationsCollection)
          .where('invitedById', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return query.docs
          .map((doc) => TeamInvitation.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw TeamServiceException('Failed to get invitations sent by user: $e');
    }
  }

  /// Gets pending invitations for a team
  Future<List<TeamInvitation>> getPendingInvitationsForTeam(String teamId) async {
    try {
      final query = await _firestore
          .collection(_invitationsCollection)
          .where('teamId', isEqualTo: teamId)
          .where('status', isEqualTo: InvitationStatus.pending.name)
          .get();
      
      return query.docs
          .map((doc) => TeamInvitation.fromJson(doc.data()))
          .where((invitation) => invitation.isPending)
          .toList();
    } catch (e) {
      throw TeamServiceException('Failed to get pending invitations for team: $e');
    }
  }

  /// Archives a team
  Future<void> archiveTeam(String teamId, String archivedById) async {
    try {
      final team = await getTeamById(teamId);
      if (team == null) {
        throw TeamServiceException('Team not found');
      }
      
      // Only owner can archive team
      if (team.ownerId != archivedById) {
        throw TeamServiceException('Only team owner can archive team');
      }
      
      await updateTeamFields(teamId, {
        'status': TeamStatus.archived.name,
      });
    } catch (e) {
      if (e is TeamServiceException) rethrow;
      throw TeamServiceException('Failed to archive team: $e');
    }
  }

  /// Deletes a team
  Future<void> deleteTeam(String teamId, String deletedById) async {
    try {
      final team = await getTeamById(teamId);
      if (team == null) {
        throw TeamServiceException('Team not found');
      }
      
      // Only owner can delete team
      if (team.ownerId != deletedById) {
        throw TeamServiceException('Only team owner can delete team');
      }
      
      // Remove team from all members' team lists
      for (final member in team.members) {
        await _userService.removeUserFromTeam(member.userId, teamId);
      }
      
      // Cancel all pending invitations
      final pendingInvitations = await getPendingInvitationsForTeam(teamId);
      for (final invitation in pendingInvitations) {
        await _updateInvitationStatus(invitation.id, InvitationStatus.cancelled);
      }
      
      // Delete team document
      await _firestore
          .collection(_teamsCollection)
          .doc(teamId)
          .delete();
      
    } catch (e) {
      if (e is TeamServiceException) rethrow;
      throw TeamServiceException('Failed to delete team: $e');
    }
  }

  /// Stream of team changes for real-time updates
  Stream<Team?> watchTeam(String teamId) {
    return _firestore
        .collection(_teamsCollection)
        .doc(teamId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return Team.fromJson(doc.data()!);
        });
  }

  /// Stream of user teams for real-time updates
  Stream<List<Team>> watchUserTeams(String userId) {
    return _firestore
        .collection(_teamsCollection)
        .where('members', arrayContainsAny: [
          {'userId': userId}
        ])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Team.fromJson(doc.data()))
            .toList());
  }

  /// Private helper methods

  Future<TeamInvitation?> _getInvitationById(String invitationId) async {
    final doc = await _firestore
        .collection(_invitationsCollection)
        .doc(invitationId)
        .get();
    
    if (!doc.exists) return null;
    
    return TeamInvitation.fromJson(doc.data()!);
  }

  Future<TeamInvitation?> _getPendingInvitation(String teamId, String email) async {
    final query = await _firestore
        .collection(_invitationsCollection)
        .where('teamId', isEqualTo: teamId)
        .where('email', isEqualTo: email)
        .where('status', isEqualTo: InvitationStatus.pending.name)
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) return null;
    
    final invitation = TeamInvitation.fromJson(query.docs.first.data());
    return invitation.isPending ? invitation : null;
  }

  Future<void> _updateInvitationStatus(String invitationId, InvitationStatus status) async {
    await _firestore
        .collection(_invitationsCollection)
        .doc(invitationId)
        .update({
          'status': status.name,
          'respondedAt': FieldValue.serverTimestamp(),
        });
  }
}

/// Custom exception for team service operations
class TeamServiceException implements Exception {
  final String message;
  
  const TeamServiceException(this.message);
  
  @override
  String toString() => 'TeamServiceException: $message';
}