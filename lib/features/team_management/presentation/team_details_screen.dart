import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../core/models/team_model.dart';
import '../providers/team_provider.dart';
import '../widgets/team_member_card.dart';
import '../widgets/invite_member_dialog.dart';
import '../../auth/providers/auth_provider.dart';

class TeamDetailsScreen extends ConsumerStatefulWidget {
  final String teamId;

  const TeamDetailsScreen({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends ConsumerState<TeamDetailsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamAsync = ref.watch(teamProvider(widget.teamId));
    final membersAsync = ref.watch(teamMembersProvider(widget.teamId));
    final currentUser = ref.watch(currentUserProvider).value;

    return teamAsync.when(
      data: (team) {
        if (team == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Team Not Found')),
            body: const Center(child: Text('Team not found')),
          );
        }

        final isOwnerOrAdmin = currentUser?.id == team.ownerId ||
            membersAsync.value?.any((member) => 
                member.member.userId == currentUser?.id && 
                member.member.canManageMembers) == true;

        return Scaffold(
          backgroundColor: CustomNeumorphicTheme.baseColor,
          appBar: NeumorphicAppBar(
            title: Text(
              team.name,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: CustomNeumorphicTheme.darkText,
              ),
            ),
            actions: [
              if (isOwnerOrAdmin)
                IconButton(
                  onPressed: () => _showInviteMemberDialog(team),
                  icon: Icon(
                    Icons.person_add,
                    color: CustomNeumorphicTheme.primaryPurple,
                    size: 24.sp,
                  ),
                ),
              SizedBox(width: 16.w),
            ],
          ),
          body: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Members'),
                ],
                labelColor: CustomNeumorphicTheme.primaryPurple,
                unselectedLabelColor: CustomNeumorphicTheme.lightText,
                indicatorColor: CustomNeumorphicTheme.primaryPurple,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(team),
                    _buildMembersTab(team, membersAsync, isOwnerOrAdmin),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: CustomNeumorphicTheme.baseColor,
        appBar: NeumorphicAppBar(
          title: Text(
            'Loading...',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: CustomNeumorphicTheme.darkText,
            ),
          ),
        ),
        body: const LoadingIndicator(message: 'Loading team details...'),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: CustomNeumorphicTheme.baseColor,
        appBar: NeumorphicAppBar(
          title: Text(
            'Error',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: CustomNeumorphicTheme.darkText,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: AppColors.error,
              ),
              SizedBox(height: 16.h),
              Text(
                'Error loading team',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(Team team) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Info Card
          NeumorphicCard(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.group,
                        size: 24.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: CustomNeumorphicTheme.darkText,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${team.totalMembers} members',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CustomNeumorphicTheme.lightText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                if (team.description.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    team.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.darkText,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Team Stats Card
          NeumorphicCard(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team Statistics',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.group,
                        label: 'Total Members',
                        value: team.totalMembers.toString(),
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.schedule,
                        label: 'Pending Invites',
                        value: team.pendingInvitationsCount.toString(),
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Team Settings Card
          NeumorphicCard(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team Settings',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
                SizedBox(height: 16.h),
                _SettingItem(
                  icon: Icons.person_add,
                  label: 'Allow Member Invites',
                  isEnabled: team.settings.allowMemberInvites,
                ),
                SizedBox(height: 12.h),
                _SettingItem(
                  icon: Icons.task_alt,
                  label: 'Require Task Approval',
                  isEnabled: team.settings.requireApprovalForTasks,
                ),
                SizedBox(height: 12.h),
                _SettingItem(
                  icon: Icons.notifications,
                  label: 'Enable Notifications',
                  isEnabled: team.settings.enableNotifications,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(Team team, AsyncValue<List<TeamMemberWithUser>> membersAsync, bool canManageMembers) {
    return membersAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_off,
                  size: 64.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No Members Found',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: TeamMemberCard(
                member: member,
                canManage: canManageMembers && member.user.id != team.ownerId,
                onRoleChanged: (newRole) => _updateMemberRole(member, newRole),
                onRemove: () => _removeMember(member),
              ),
            );
          },
        );
      },
      loading: () => const LoadingIndicator(message: 'Loading members...'),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error loading members',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: CustomNeumorphicTheme.darkText,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 12.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteMemberDialog(Team team) {
    showDialog(
      context: context,
      builder: (context) => InviteMemberDialog(team: team),
    );
  }

  Future<void> _updateMemberRole(TeamMemberWithUser member, TeamRole newRole) async {
    try {
      await ref.read(teamNotifierProvider.notifier).updateMemberRole(
        teamId: widget.teamId,
        userId: member.user.id,
        newRole: newRole,
      );
      
      // Refresh members
      ref.invalidate(teamMembersProvider(widget.teamId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.user.displayName}\'s role updated to ${newRole.displayName}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating role: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _removeMember(TeamMemberWithUser member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CustomNeumorphicTheme.baseColor,
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove ${member.user.displayName} from the team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(teamNotifierProvider.notifier).removeMember(
          teamId: widget.teamId,
          userId: member.user.id,
        );
        
        // Refresh members and team
        ref.invalidate(teamMembersProvider(widget.teamId));
        ref.invalidate(teamProvider(widget.teamId));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${member.user.displayName} removed from team'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing member: $error'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32.sp,
          color: color,
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: CustomNeumorphicTheme.lightText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: isEnabled ? AppColors.success : CustomNeumorphicTheme.lightText,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: CustomNeumorphicTheme.darkText,
            ),
          ),
        ),
        Icon(
          isEnabled ? Icons.check_circle : Icons.cancel,
          size: 16.sp,
          color: isEnabled ? AppColors.success : CustomNeumorphicTheme.lightText,
        ),
      ],
    );
  }
}