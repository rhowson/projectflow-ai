import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../core/models/team_model.dart';
import '../../../core/services/team_service.dart';

class TeamMemberCard extends StatelessWidget {
  final TeamMemberWithUser member;
  final bool canManage;
  final Function(TeamRole)? onRoleChanged;
  final VoidCallback? onRemove;

  const TeamMemberCard({
    super.key,
    required this.member,
    this.canManage = false,
    this.onRoleChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: member.user.photoUrl?.isNotEmpty == true 
                ? NetworkImage(member.user.photoUrl!) 
                : null,
            child: member.user.photoUrl?.isEmpty ?? true
                ? Text(
                    _getInitials(member.user.displayName),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),

          SizedBox(width: 12.w),

          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.user.displayName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  member.user.email,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Joined ${DateFormat('MMM dd, yyyy').format(member.member.addedAt)}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Role and Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Role Chip
              _RoleChip(
                role: member.member.role,
                canEdit: canManage,
                onRoleChanged: onRoleChanged,
              ),
              
              if (canManage) ...[
                SizedBox(height: 8.h),
                // Remove Button
                NeumorphicButton(
                  onPressed: onRemove,
                  borderRadius: BorderRadius.circular(6.r),
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.remove_circle_outline,
                    size: 16.sp,
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
        ],
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
}

class _RoleChip extends StatelessWidget {
  final TeamRole role;
  final bool canEdit;
  final Function(TeamRole)? onRoleChanged;

  const _RoleChip({
    required this.role,
    this.canEdit = false,
    this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getRoleColor(role);

    final chip = Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(role),
            size: 12.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            role.displayName,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (canEdit) ...[
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14.sp,
              color: color,
            ),
          ],
        ],
      ),
    );

    if (!canEdit) return chip;

    return PopupMenuButton<TeamRole>(
      onSelected: (newRole) => onRoleChanged?.call(newRole),
      itemBuilder: (context) => TeamRole.values
          .where((r) => r != TeamRole.owner) // Can't change to owner
          .map((r) => PopupMenuItem(
                value: r,
                child: Row(
                  children: [
                    Icon(
                      _getRoleIcon(r),
                      size: 16.sp,
                      color: _getRoleColor(r),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.displayName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: CustomNeumorphicTheme.darkText,
                          ),
                        ),
                        Text(
                          r.displayName,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: CustomNeumorphicTheme.lightText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ))
          .toList(),
      child: chip,
    );
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

  IconData _getRoleIcon(TeamRole role) {
    switch (role) {
      case TeamRole.owner:
        return Icons.star;
      case TeamRole.admin:
        return Icons.admin_panel_settings;
      case TeamRole.manager:
        return Icons.manage_accounts;
      case TeamRole.member:
        return Icons.person;
      case TeamRole.viewer:
        return Icons.visibility;
      case TeamRole.collaborator:
        return Icons.people;
    }
  }
}