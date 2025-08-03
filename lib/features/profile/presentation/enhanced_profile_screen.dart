import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../user_management/providers/user_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_settings_section.dart';
import '../widgets/team_membership_section.dart';
import '../widgets/user_statistics_section.dart';
import '../widgets/preferences_section.dart';

class EnhancedProfileScreen extends ConsumerStatefulWidget {
  const EnhancedProfileScreen({super.key});

  @override
  ConsumerState<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends ConsumerState<EnhancedProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return _buildSignInPrompt();
    }

    return currentUser.when(
      data: (user) {
        if (user == null) return _buildSignInPrompt();
        return _buildProfileScreen(user);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
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
                'Error loading profile',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8.h),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(currentUserProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profile',
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 96.sp,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              SizedBox(height: 24.h),
              Text(
                'Sign In Required',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'Please sign in to view and manage your profile',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to sign in screen
                  // This would be implemented with your auth flow
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileScreen(AppUser user) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(user),
            tooltip: 'Edit Profile',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 16),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline, size: 16),
                    SizedBox(width: 8),
                    Text('Help & Support'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 16),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleMenuAction(value),
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile header
          ProfileHeader(user: user),
          
          SizedBox(height: 16.h),
          
          // Tab bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Teams'),
                Tab(text: 'Settings'),
                Tab(text: 'Stats'),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(user),
                _buildTeamsTab(user),
                _buildSettingsTab(user),
                _buildStatsTab(user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AppUser user) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick actions
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: [
                      _buildQuickActionChip(
                        icon: Icons.edit,
                        label: 'Edit Profile',
                        onTap: () => _showEditProfileDialog(user),
                      ),
                      _buildQuickActionChip(
                        icon: Icons.security,
                        label: '2FA Settings',
                        onTap: () => _showTwoFactorDialog(user),
                      ),
                      _buildQuickActionChip(
                        icon: Icons.group_add,
                        label: 'Join Team',
                        onTap: () => _showJoinTeamDialog(),
                      ),
                      _buildQuickActionChip(
                        icon: Icons.palette,
                        label: 'Theme',
                        onTap: () => _showThemeDialog(user),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Profile information
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildInfoRow('Email', user.email),
                  _buildInfoRow('Phone', user.phoneNumber ?? 'Not provided'),
                  _buildInfoRow('Job Title', user.jobTitle ?? 'Not provided'),
                  _buildInfoRow('Department', user.department ?? 'Not provided'),
                  _buildInfoRow('Company', user.company ?? 'Not provided'),
                  _buildInfoRow('Location', user.location ?? 'Not provided'),
                  _buildInfoRow('Timezone', user.timezone),
                  if (user.bio?.isNotEmpty == true) ...[
                    SizedBox(height: 8.h),
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      user.bio!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Skills
          if (user.skills.isNotEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skills & Expertise',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: user.skills.map((skill) => Chip(
                        label: Text(
                          skill,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
          
          SizedBox(height: 16.h),
          
          // Account status
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(
                        user.isEmailVerified ? Icons.verified : Icons.warning,
                        size: 16.sp,
                        color: user.isEmailVerified ? AppColors.success : AppColors.warning,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        user.isEmailVerified ? 'Email Verified' : 'Email Not Verified',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        user.hasTwoFactorEnabled ? Icons.security : Icons.security_outlined,
                        size: 16.sp,
                        color: user.hasTwoFactorEnabled ? AppColors.success : AppColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        user.hasTwoFactorEnabled ? '2FA Enabled' : '2FA Disabled',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        user.isOnline ? Icons.circle : Icons.circle_outlined,
                        size: 16.sp,
                        color: user.isOnline ? AppColors.success : AppColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        user.isOnline ? 'Online' : 'Offline',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildTeamsTab(AppUser user) {
    return TeamMembershipSection(userId: user.id);
  }

  Widget _buildSettingsTab(AppUser user) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          ProfileSettingsSection(user: user),
          SizedBox(height: 16.h),
          PreferencesSection(user: user),
        ],
      ),
    );
  }

  Widget _buildStatsTab(AppUser user) {
    return UserStatisticsSection(user: user);
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 16.sp),
      label: Text(
        label,
        style: TextStyle(fontSize: 12.sp),
      ),
      onPressed: onTap,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      side: BorderSide(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(AppUser user) {
    // Implementation for edit profile dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing dialog would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog(AppUser user) {
    // Implementation for 2FA settings dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Two-Factor Authentication'),
        content: Text(
          user.hasTwoFactorEnabled 
              ? 'Two-factor authentication is currently enabled.'
              : 'Two-factor authentication is currently disabled. Enable it for better security.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Toggle 2FA
              ref.read(userManagementProvider.notifier)
                  .updateTwoFactorStatus(user.id, !user.hasTwoFactorEnabled);
              Navigator.of(context).pop();
            },
            child: Text(user.hasTwoFactorEnabled ? 'Disable 2FA' : 'Enable 2FA'),
          ),
        ],
      ),
    );
  }

  void _showJoinTeamDialog() {
    // Implementation for join team dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Team'),
        content: const Text('Team joining functionality would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(AppUser user) {
    // Implementation for theme selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppThemeMode>(
              title: const Text('Light'),
              value: AppThemeMode.light,
              groupValue: user.preferences.themeMode,
              onChanged: (value) {
                if (value != null) {
                  final updatedPreferences = user.preferences.copyWith(themeMode: value);
                  ref.read(userManagementProvider.notifier)
                      .updatePreferences(user.id, updatedPreferences);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              title: const Text('Dark'),
              value: AppThemeMode.dark,
              groupValue: user.preferences.themeMode,
              onChanged: (value) {
                if (value != null) {
                  final updatedPreferences = user.preferences.copyWith(themeMode: value);
                  ref.read(userManagementProvider.notifier)
                      .updatePreferences(user.id, updatedPreferences);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              title: const Text('System'),
              value: AppThemeMode.system,
              groupValue: user.preferences.themeMode,
              onChanged: (value) {
                if (value != null) {
                  final updatedPreferences = user.preferences.copyWith(themeMode: value);
                  ref.read(userManagementProvider.notifier)
                      .updatePreferences(user.id, updatedPreferences);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        _tabController.animateTo(2); // Switch to settings tab
        break;
      case 'help':
        // Navigate to help screen
        break;
      case 'signout':
        _showSignOutDialog();
        break;
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement sign out logic
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}