import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/team_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../team_management/providers/team_provider.dart';

class TeamMembershipSection extends ConsumerWidget {
  final String userId;

  const TeamMembershipSection({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTeams = ref.watch(userTeamsProvider(userId));
    final invitations = ref.watch(invitationsForEmailProvider('user@example.com')); // This would use actual user email

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pending invitations
          invitations.when(
            data: (invites) {
              if (invites.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      context,
                      'Pending Invitations',
                      Icons.mail_outline,
                      invites.length,
                    ),
                    SizedBox(height: 12.h),
                    ...invites.map((invitation) => _buildInvitationCard(
                      context,
                      ref,
                      invitation,
                    )),
                    SizedBox(height: 24.h),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Current teams
          userTeams.when(
            data: (teams) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    'My Teams',
                    Icons.group,
                    teams.length,
                  ),
                  SizedBox(height: 12.h),
                  
                  if (teams.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...teams.map((team) => _buildTeamCard(context, ref, team)),
                  
                  SizedBox(height: 24.h),
                  
                  // Create or join team actions
                  _buildActionButtons(context, ref),
                ],
              );
            },
            loading: () => Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: const CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Error loading teams',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(userTeamsProvider(userId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    int count,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvitationCard(
    BuildContext context,
    WidgetRef ref,
    TeamInvitation invitation,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.mail,
                    color: AppColors.info,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Invitation',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Invited as ${_getRoleDisplayName(invitation.role)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(invitation.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _getStatusDisplayName(invitation.status),
                    style: TextStyle(
                      color: _getStatusColor(invitation.status),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            if (invitation.message?.isNotEmpty == true) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  invitation.message!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 12.h),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _declineInvitation(context, ref, invitation),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptInvitation(context, ref, invitation),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, WidgetRef ref, Team team) {
    final currentUserRole = ref.watch(userRoleInTeamProvider(team.id));
    final canManage = ref.watch(canManageTeamProvider(team.id));
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Team logo or placeholder
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: team.logoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            team.logoUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.group,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                ),
                
                SizedBox(width: 12.w),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (currentUserRole != null)
                        Text(
                          _getRoleDisplayName(currentUserRole),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getRoleColor(currentUserRole),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 20.sp,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 16),
                          SizedBox(width: 8),
                          Text('View Team'),
                        ],
                      ),
                    ),
                    if (canManage)
                      const PopupMenuItem<String>(
                        value: 'manage',
                        child: Row(
                          children: [
                            Icon(Icons.settings, size: 16),
                            SizedBox(width: 8),
                            Text('Manage'),
                          ],
                        ),
                      ),
                    const PopupMenuItem<String>(
                      value: 'leave',
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Leave Team', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) => _handleTeamAction(context, ref, team, value),
                ),
              ],
            ),
            
            if (team.description.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                team.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            SizedBox(height: 12.h),
            
            Row(
              children: [
                _buildTeamStat(
                  context,
                  Icons.people,
                  '${team.activeMemberCount} members',
                ),
                SizedBox(width: 16.w),
                _buildTeamStat(
                  context,
                  Icons.work,
                  '${team.projectIds.length} projects',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamStat(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        SizedBox(width: 4.w),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.group_outlined,
            size: 48.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Teams Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Join or create a team to start collaborating',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showJoinTeamDialog(context, ref),
            icon: const Icon(Icons.group_add),
            label: const Text('Join Team'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showCreateTeamDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Create Team'),
          ),
        ),
      ],
    );
  }

  void _acceptInvitation(BuildContext context, WidgetRef ref, TeamInvitation invitation) async {
    try {
      await ref.read(teamInvitationProvider.notifier)
          .acceptTeamInvitation(invitation.id, userId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team invitation accepted!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _declineInvitation(BuildContext context, WidgetRef ref, TeamInvitation invitation) async {
    try {
      await ref.read(teamInvitationProvider.notifier)
          .declineTeamInvitation(invitation.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team invitation declined'),
            backgroundColor: AppColors.info,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleTeamAction(BuildContext context, WidgetRef ref, Team team, String action) {
    switch (action) {
      case 'view':
        // Navigate to team details
        break;
      case 'manage':
        // Navigate to team management
        break;
      case 'leave':
        _showLeaveTeamDialog(context, ref, team);
        break;
    }
  }

  void _showLeaveTeamDialog(BuildContext context, WidgetRef ref, Team team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Team'),
        content: Text('Are you sure you want to leave "${team.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(teamManagementProvider.notifier)
                    .removeMemberFromTeam(team.id, userId, team.ownerId);
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Left team successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showJoinTeamDialog(BuildContext context, WidgetRef ref) {
    final inviteCodeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter an invitation code to join a team:'),
            SizedBox(height: 16.h),
            TextField(
              controller: inviteCodeController,
              decoration: const InputDecoration(
                labelText: 'Invitation Code',
                border: OutlineInputBorder(),
                hintText: 'Enter code here...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement join team logic
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Join team functionality would be implemented here'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                try {
                  await ref.read(teamManagementProvider.notifier).createTeam(
                    name: nameController.text,
                    description: descriptionController.text,
                    ownerId: userId,
                  );
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Team created successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.pending:
        return AppColors.warning;
      case InvitationStatus.accepted:
        return AppColors.success;
      case InvitationStatus.declined:
        return AppColors.error;
      case InvitationStatus.expired:
        return AppColors.textSecondary;
      case InvitationStatus.cancelled:
        return AppColors.textSecondary;
    }
  }

  String _getStatusDisplayName(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.pending:
        return 'Pending';
      case InvitationStatus.accepted:
        return 'Accepted';
      case InvitationStatus.declined:
        return 'Declined';
      case InvitationStatus.expired:
        return 'Expired';
      case InvitationStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getRoleColor(TeamRole role) {
    switch (role) {
      case TeamRole.owner:
        return Colors.purple;
      case TeamRole.admin:
        return Colors.red;
      case TeamRole.manager:
        return Colors.orange;
      case TeamRole.member:
        return AppColors.primary;
      case TeamRole.viewer:
        return Colors.grey;
      case TeamRole.collaborator:
        return Colors.blue;
    }
  }

  String _getRoleDisplayName(TeamRole role) {
    switch (role) {
      case TeamRole.owner:
        return 'Owner';
      case TeamRole.admin:
        return 'Admin';
      case TeamRole.manager:
        return 'Manager';
      case TeamRole.member:
        return 'Member';
      case TeamRole.viewer:
        return 'Viewer';
      case TeamRole.collaborator:
        return 'Collaborator';
    }
  }
}