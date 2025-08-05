import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/keyboard_dismissible_wrapper.dart';
import '../../../core/models/team_model.dart';
import '../providers/team_provider.dart';

class InviteMemberDialog extends ConsumerStatefulWidget {
  final Team team;

  const InviteMemberDialog({
    super.key,
    required this.team,
  });

  @override
  ConsumerState<InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends ConsumerState<InviteMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  TeamRole _selectedRole = TeamRole.member;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissibleWrapper(
      child: AlertDialog(
        backgroundColor: CustomNeumorphicTheme.baseColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Invite Team Member',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Field
                Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                NeumorphicCard(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter email address',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      
                      // Check if user is already a member
                      if (widget.team.memberIds.contains(value.trim())) {
                        return 'This user is already a team member';
                      }
                      
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                ),

                SizedBox(height: 16.h),

                // Role Selection
                Text(
                  'Role',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                NeumorphicCard(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: TeamRole.values
                        .where((role) => role != TeamRole.owner) // Can't invite as owner
                        .map((role) => _RoleOption(
                              role: role,
                              isSelected: _selectedRole == role,
                              onSelected: _isLoading ? null : () {
                                setState(() {
                                  _selectedRole = role;
                                });
                              },
                            ))
                        .toList(),
                  ),
                ),

                SizedBox(height: 16.h),

                // Message Field (Optional)
                Text(
                  'Personal Message (Optional)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                NeumorphicCard(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: TextFormField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Add a personal message to the invitation...',
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                    validator: (value) {
                      if (value != null && value.trim().length > 200) {
                        return 'Message must be less than 200 characters';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                ),

                SizedBox(height: 16.h),

                // Info Card
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16.sp,
                        color: AppColors.info,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'The invitation will expire in 7 days. The user will receive an email with instructions to join the team.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
            ),
          ),
          NeumorphicButton(
            onPressed: _isLoading ? null : _sendInvitation,
            selectedColor: CustomNeumorphicTheme.primaryPurple,
            borderRadius: BorderRadius.circular(8.r),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: _isLoading
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.send,
                        size: 14.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Send Invite',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(teamNotifierProvider.notifier).inviteToTeam(
        teamId: widget.team.id,
        email: _emailController.text.trim(),
        role: _selectedRole,
        message: _messageController.text.trim().isEmpty 
            ? null 
            : _messageController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to ${_emailController.text.trim()}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending invitation: $error'),
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
}

class _RoleOption extends StatelessWidget {
  final TeamRole role;
  final bool isSelected;
  final VoidCallback? onSelected;

  const _RoleOption({
    required this.role,
    required this.isSelected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getRoleColor(role);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      child: NeumorphicButton(
        onPressed: onSelected,
        isSelected: isSelected,
        selectedColor: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        padding: EdgeInsets.all(12.w),
        child: Row(
        children: [
          Icon(
            _getRoleIcon(role),
            size: 18.sp,
            color: isSelected ? color : CustomNeumorphicTheme.lightText,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.displayName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : CustomNeumorphicTheme.darkText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  role.displayName,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              size: 18.sp,
              color: color,
            ),
        ],
        ),
      ),
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