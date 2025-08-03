import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/user_service.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../user_management/providers/user_provider.dart';

class UserStatisticsSection extends ConsumerWidget {
  final AppUser user;

  const UserStatisticsSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStats = ref.watch(userStatisticsProvider);
    
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account overview
          _buildAccountOverviewCard(context),
          
          SizedBox(height: 16.h),
          
          // Activity stats
          _buildActivityStatsCard(context),
          
          SizedBox(height: 16.h),
          
          // Usage analytics
          _buildUsageAnalyticsCard(context),
          
          SizedBox(height: 16.h),
          
          // Global statistics (if admin)
          if (user.isAdmin)
            userStats.when(
              data: (stats) => _buildGlobalStatsCard(context, stats),
              loading: () => _buildLoadingCard(context, 'Global Statistics'),
              error: (error, stack) => _buildErrorCard(context, 'Global Statistics', error),
            ),
          
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildAccountOverviewCard(BuildContext context) {
    return NeumorphicEmbossedCard(
      padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.account_circle,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Account Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Member Since',
                    _formatDate(user.createdAt),
                    Icons.calendar_today,
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Last Active',
                    user.lastActiveAt != null 
                        ? _formatRelativeTime(user.lastActiveAt!)
                        : 'Never',
                    Icons.access_time,
                    user.isOnline ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Account Status',
                    _getStatusDisplayName(user.status),
                    Icons.verified,
                    _getStatusColor(user.status),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Role',
                    _getRoleDisplayName(user.role),
                    Icons.badge,
                    _getRoleColor(user.role),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildActivityStatsCard(BuildContext context) {
    return NeumorphicEmbossedCard(
      padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: AppColors.success,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Activity Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Teams',
                    user.teamIds.length.toString(),
                    Icons.group,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Projects',
                    user.projectIds.length.toString(),
                    Icons.work,
                    AppColors.accent,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Skills',
                    user.skills.length.toString(),
                    Icons.star,
                    AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Onboarding',
                    user.hasCompletedOnboarding ? 'Complete' : 'Pending',
                    Icons.check_circle,
                    user.hasCompletedOnboarding ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildUsageAnalyticsCard(BuildContext context) {
    return NeumorphicEmbossedCard(
      padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: AppColors.accent,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Usage Analytics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            
            // Preferences overview
            _buildPreferencesSummary(context),
            
            SizedBox(height: 16.h),
            
            // Security status
            _buildSecurityStatus(context),
          ],
        ),
    );
  }

  Widget _buildPreferencesSummary(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildPreferenceItem(
                  context,
                  'Theme',
                  _getThemeDisplayName(user.preferences.themeMode),
                  Icons.palette,
                ),
              ),
              Expanded(
                child: _buildPreferenceItem(
                  context,
                  'Language',
                  user.preferences.language.toUpperCase(),
                  Icons.language,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildPreferenceItem(
                  context,
                  'Notifications',
                  user.preferences.pushNotifications ? 'Enabled' : 'Disabled',
                  Icons.notifications,
                ),
              ),
              Expanded(
                child: _buildPreferenceItem(
                  context,
                  'Analytics',
                  user.preferences.enableAnalytics ? 'Enabled' : 'Disabled',
                  Icons.analytics,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStatus(BuildContext context) {
    final securityScore = _calculateSecurityScore();
    
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Security Score',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getSecurityScoreColor(securityScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$securityScore/100',
                  style: TextStyle(
                    color: _getSecurityScoreColor(securityScore),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: securityScore / 100,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getSecurityScoreColor(securityScore),
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: [
              _buildSecurityBadge(
                context,
                'Email Verified',
                user.isEmailVerified,
                Icons.email,
              ),
              _buildSecurityBadge(
                context,
                '2FA Enabled',
                user.hasTwoFactorEnabled,
                Icons.security,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalStatsCard(BuildContext context, UserStatistics stats) {
    return NeumorphicEmbossedCard(
      padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.purple,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Global Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'ADMIN',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Users',
                    stats.totalUsers.toString(),
                    Icons.people,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Active Users',
                    stats.activeUsersLast30Days.toString(),
                    Icons.trending_up,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'New Users',
                    stats.newUsersLast7Days.toString(),
                    Icons.person_add,
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Active Rate',
                    '${stats.activeUserPercentage.toStringAsFixed(1)}%',
                    Icons.percent,
                    AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: color,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityBadge(
    BuildContext context,
    String label,
    bool enabled,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: enabled 
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: enabled 
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check : Icons.close,
            size: 12.sp,
            color: enabled ? AppColors.success : AppColors.error,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: enabled ? AppColors.success : AppColors.error,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context, String title) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String title, Object error) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 32.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else {
      return 'Today';
    }
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return _formatDate(date);
    }
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return AppColors.success;
      case UserStatus.inactive:
        return AppColors.textSecondary;
      case UserStatus.suspended:
        return AppColors.error;
      case UserStatus.pending:
        return AppColors.warning;
      case UserStatus.blocked:
        return AppColors.error;
    }
  }

  String _getStatusDisplayName(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.inactive:
        return 'Inactive';
      case UserStatus.suspended:
        return 'Suspended';
      case UserStatus.pending:
        return 'Pending';
      case UserStatus.blocked:
        return 'Blocked';
    }
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
        return 'Premium';
      case UserRole.member:
        return 'Member';
      case UserRole.viewer:
        return 'Viewer';
    }
  }

  String _getThemeDisplayName(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  int _calculateSecurityScore() {
    int score = 0;
    
    if (user.isEmailVerified) score += 40;
    if (user.hasTwoFactorEnabled) score += 50;
    if (user.hasCompletedOnboarding) score += 10;
    
    return score;
  }

  Color _getSecurityScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }
}