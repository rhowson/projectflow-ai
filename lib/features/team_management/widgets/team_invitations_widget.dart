import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../core/models/team_model.dart';
import '../providers/team_provider.dart';

class TeamInvitationsWidget extends ConsumerWidget {
  final List<TeamInvitation> invitations;

  const TeamInvitationsWidget({
    super.key,
    required this.invitations,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: invitations.map((invitation) => Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: _InvitationCard(invitation: invitation),
      )).toList(),
    );
  }
}

class _InvitationCard extends ConsumerStatefulWidget {
  final TeamInvitation invitation;

  const _InvitationCard({required this.invitation});

  @override
  ConsumerState<_InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends ConsumerState<_InvitationCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with team name and role
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.group,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Invitation',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Invited as ${widget.invitation.role.displayName}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: CustomNeumorphicTheme.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              _RoleChip(role: widget.invitation.role),
            ],
          ),

          if (widget.invitation.message != null && widget.invitation.message!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                widget.invitation.message!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: CustomNeumorphicTheme.darkText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],

          SizedBox(height: 12.h),

          // Invitation details
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
              SizedBox(width: 4.w),
              Text(
                'Invited ${DateFormat('MMM dd, yyyy').format(widget.invitation.createdAt)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ),
              SizedBox(width: 16.w),
              Icon(
                Icons.timer,
                size: 14.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
              SizedBox(width: 4.w),
              Text(
                'Expires ${DateFormat('MMM dd').format(widget.invitation.expiresAt)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: widget.invitation.isExpired 
                      ? AppColors.error 
                      : CustomNeumorphicTheme.lightText,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: NeumorphicButton(
                  onPressed: _isLoading ? null : () => _declineInvitation(),
                  borderRadius: BorderRadius.circular(8.r),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Text(
                    'Decline',
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
                  onPressed: _isLoading ? null : () => _acceptInvitation(),
                  selectedColor: AppColors.success,
                  borderRadius: BorderRadius.circular(8.r),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
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
                          'Accept',
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
    );
  }

  Future<void> _acceptInvitation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(teamNotifierProvider.notifier).acceptInvitation(widget.invitation.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Team invitation accepted!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Refresh invitations
        ref.invalidate(userInvitationsProvider);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting invitation: $error'),
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

  Future<void> _declineInvitation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(teamNotifierProvider.notifier).declineInvitation(widget.invitation.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Team invitation declined'),
            backgroundColor: AppColors.warning,
          ),
        );
        // Refresh invitations
        ref.invalidate(userInvitationsProvider);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error declining invitation: $error'),
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

class _RoleChip extends StatelessWidget {
  final TeamRole role;

  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role) {
      case TeamRole.owner:
        color = AppColors.warning;
        break;
      case TeamRole.admin:
        color = AppColors.primary;
        break;
      case TeamRole.manager:
        color = AppColors.secondary;
        break;
      case TeamRole.member:
        color = AppColors.secondary;
        break;
      case TeamRole.viewer:
        color = AppColors.info;
        break;
      case TeamRole.collaborator:
        color = AppColors.info;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        role.displayName,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}