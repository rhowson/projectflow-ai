import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/custom_neumorphic_theme.dart';
import '../theme/app_colors.dart';
import '../../core/models/project_model.dart';
import '../../core/models/team_model.dart';
import '../../features/project_creation/providers/project_provider.dart';
import '../../features/team_management/providers/team_provider.dart';

class TaskAssignmentDialog extends ConsumerStatefulWidget {
  final String projectId;
  final String phaseId;
  final Task task;

  const TaskAssignmentDialog({
    super.key,
    required this.projectId,
    required this.phaseId,
    required this.task,
  });

  @override
  ConsumerState<TaskAssignmentDialog> createState() => _TaskAssignmentDialogState();
}

class _TaskAssignmentDialogState extends ConsumerState<TaskAssignmentDialog> {
  String? _selectedUserId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.task.assignedToId;
  }

  @override
  Widget build(BuildContext context) {
    // Get project and team members
    final projectAsync = ref.watch(projectProvider(widget.projectId));
    final teamId = projectAsync.value?.metadata.teamId;
    final membersAsync = teamId != null 
        ? ref.watch(teamMembersProvider(teamId))
        : null;

    return Dialog(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Assign Task',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: CustomNeumorphicTheme.darkText,
              ),
            ),
            SizedBox(height: 8.h),
            
            // Task info
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.task_alt,
                    color: AppColors.primary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      widget.task.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Team members list
            Text(
              'Assign to team member:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: CustomNeumorphicTheme.darkText,
              ),
            ),
            SizedBox(height: 12.h),

            if (membersAsync != null)
              membersAsync.when(
                data: (members) {
                  if (members.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return SizedBox(
                    height: 200.h,
                    child: ListView.builder(
                      itemCount: members.length + 1, // +1 for "Unassign" option
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Unassign option
                          return _TeamMemberTile(
                            member: null,
                            isSelected: _selectedUserId == null,
                            onTap: () {
                              setState(() {
                                _selectedUserId = null;
                              });
                            },
                          );
                        }
                        
                        final member = members[index - 1];
                        return _TeamMemberTile(
                          member: member,
                          isSelected: _selectedUserId == member.user.id,
                          onTap: () {
                            setState(() {
                              _selectedUserId = member.user.id;
                            });
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () => SizedBox(
                  height: 100.h,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => _buildErrorState(error.toString()),
              )
            else
              _buildNoTeamState(),
            
            SizedBox(height: 20.h),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12.r),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: CustomNeumorphicTheme.lightText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: NeumorphicButton(
                    onPressed: _isLoading ? null : _assignTask,
                    selectedColor: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: _isLoading
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Assign',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Icon(
            Icons.group_off,
            size: 32.sp,
            color: CustomNeumorphicTheme.lightText,
          ),
          SizedBox(height: 8.h),
          Text(
            'No team members found',
            style: TextStyle(
              fontSize: 14.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 32.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 8.h),
          Text(
            'Error loading team members',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: CustomNeumorphicTheme.darkText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoTeamState() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 24.sp,
            color: AppColors.warning,
          ),
          SizedBox(height: 8.h),
          Text(
            'No Team Linked',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: CustomNeumorphicTheme.darkText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            'This project is not linked to a team. Link the project to a team to assign tasks to team members.',
            style: TextStyle(
              fontSize: 12.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _assignTask() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(projectNotifierProvider.notifier).assignTaskToMember(
        widget.projectId,
        widget.phaseId,
        widget.task.id,
        _selectedUserId,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        
        final assigneeName = _selectedUserId == null 
            ? 'Unassigned'
            : 'Assigned';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task $assigneeName successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error assigning task: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.trim().isNotEmpty) {
      return name.trim().substring(0, 1).toUpperCase();
    } else {
      return '?';
    }
  }
}

class _TeamMemberTile extends StatelessWidget {
  final TeamMemberWithUser? member;
  final bool isSelected;
  final VoidCallback onTap;

  const _TeamMemberTile({
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: NeumorphicButton(
        onPressed: onTap,
        isSelected: isSelected,
        selectedColor: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 18.r,
              backgroundColor: member == null 
                  ? AppColors.warning.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.2),
              backgroundImage: member?.user.photoUrl?.isNotEmpty == true 
                  ? NetworkImage(member!.user.photoUrl!) 
                  : null,
              child: member == null
                  ? Icon(
                      Icons.person_off,
                      size: 16.sp,
                      color: AppColors.warning,
                    )
                  : (member!.user.photoUrl?.isEmpty ?? true)
                      ? Text(
                          _getInitials(member!.user.displayName),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
            ),
            
            SizedBox(width: 12.w),
            
            // Member info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member?.user.displayName ?? 'Unassigned',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? AppColors.primary 
                          : CustomNeumorphicTheme.darkText,
                    ),
                  ),
                  if (member != null) ...[
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Text(
                          member!.user.email,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: CustomNeumorphicTheme.lightText,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _getRoleColor(member!.member.role).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            member!.member.role.displayName,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: _getRoleColor(member!.member.role),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 18.sp,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.trim().isNotEmpty) {
      return name.trim().substring(0, 1).toUpperCase();
    } else {
      return '?';
    }
  }

  Color _getRoleColor(TeamRole role) {
    switch (role) {
      case TeamRole.owner:
        return AppColors.warning;
      case TeamRole.admin:
        return AppColors.primary;
      case TeamRole.manager:
        return AppColors.secondary;
      case TeamRole.member:
        return AppColors.secondary;
      case TeamRole.viewer:
        return AppColors.info;
      case TeamRole.collaborator:
        return AppColors.info;
    }
  }
}