import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final AppUser user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryLight.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Profile photo and online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: user.photoUrl == null
                    ? Text(
                        user.initials,
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              if (user.isOnline)
                Positioned(
                  bottom: 4.h,
                  right: 4.w,
                  child: Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // User name and role
          Text(
            user.fullName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 4.h),
          
          if (user.jobTitle?.isNotEmpty == true)
            Text(
              user.jobTitle!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          
          SizedBox(height: 8.h),
          
          // Role badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: _getRoleColor(user.role).withOpacity(0.3),
              ),
            ),
            child: Text(
              _getRoleDisplayName(user.role),
              style: TextStyle(
                color: _getRoleColor(user.role),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Quick stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                icon: Icons.group,
                value: user.teamIds.length.toString(),
                label: 'Teams',
              ),
              _buildStatItem(
                context,
                icon: Icons.work,
                value: user.projectIds.length.toString(),
                label: 'Projects',
              ),
              _buildStatItem(
                context,
                icon: Icons.star,
                value: user.skills.length.toString(),
                label: 'Skills',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                offset: Offset(0, 2.h),
                blurRadius: 8.r,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return Colors.purple;
      case UserRole.admin:
        return Colors.red;
      case UserRole.manager:
        return Colors.orange;
      case UserRole.premium:
        return Colors.blue;
      case UserRole.member:
        return AppColors.primary;
      case UserRole.viewer:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.premium:
        return 'Premium Member';
      case UserRole.member:
        return 'Member';
      case UserRole.viewer:
        return 'Viewer';
    }
  }
}