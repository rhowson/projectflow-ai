import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
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
        backgroundColor: CustomNeumorphicTheme.baseColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeumorphicContainer(
                padding: EdgeInsets.all(16.w),
                borderRadius: BorderRadius.circular(25),
                color: CustomNeumorphicTheme.errorRed,
                child: Icon(
                  Icons.error_outline,
                  size: 32.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Error loading profile',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
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
              SizedBox(height: 24.h),
              NeumorphicButton(
                onPressed: () {
                  ref.invalidate(currentUserProvider);
                },
                isSelected: true,
                selectedColor: CustomNeumorphicTheme.primaryPurple,
                borderRadius: BorderRadius.circular(12),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Scaffold(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      appBar: NeumorphicAppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: NeumorphicCard(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeumorphicContainer(
                  padding: EdgeInsets.all(20.w),
                  borderRadius: BorderRadius.circular(35),
                  color: CustomNeumorphicTheme.primaryPurple,
                  child: Icon(
                    Icons.person_outline,
                    size: 48.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  'Sign In Required',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Please sign in to view and manage your profile',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: CustomNeumorphicTheme.lightText,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                NeumorphicButton(
                  onPressed: () {
                    // Navigate to sign in screen
                    // This would be implemented with your auth flow
                  },
                  isSelected: true,
                  selectedColor: CustomNeumorphicTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(12),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.login, size: 18.sp, color: Colors.white),
                      SizedBox(width: 8.w),
                      Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileScreen(AppUser user) {
    return Scaffold(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      appBar: NeumorphicAppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          NeumorphicButton(
            onPressed: () => _showEditProfileDialog(user),
            borderRadius: BorderRadius.circular(25),
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.edit,
              color: CustomNeumorphicTheme.darkText,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 8.w),
          NeumorphicButton(
            onPressed: () => _showMoreOptions(),
            borderRadius: BorderRadius.circular(25),
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.more_vert,
              color: CustomNeumorphicTheme.darkText,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 16.w),
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
            child: NeumorphicContainer(
              padding: EdgeInsets.all(4.w),
              borderRadius: BorderRadius.circular(15),
              color: CustomNeumorphicTheme.cardColor,
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: CustomNeumorphicTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CustomNeumorphicTheme.darkShadow.withOpacity(0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: CustomNeumorphicTheme.lightText,
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
          NeumorphicCard(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.darkText,
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
          
          SizedBox(height: 20.h),
          
          // Profile information
          NeumorphicCard(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.darkText,
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
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CustomNeumorphicTheme.lightText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user.bio!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.darkText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Skills
          if (user.skills.isNotEmpty)
            NeumorphicCard(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skills & Expertise',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: user.skills.map((skill) => NeumorphicContainer(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      borderRadius: BorderRadius.circular(20),
                      color: CustomNeumorphicTheme.primaryPurple,
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          
          SizedBox(height: 16.h),
          
          // Account status
          NeumorphicCard(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Status',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
                SizedBox(height: 16.h),
                Column(
                  children: [
                    Row(
                      children: [
                        NeumorphicContainer(
                        padding: EdgeInsets.all(6.w),
                        borderRadius: BorderRadius.circular(12),
                        color: user.isEmailVerified ? CustomNeumorphicTheme.successGreen : CustomNeumorphicTheme.secondaryPurple,
                        child: Icon(
                          user.isEmailVerified ? Icons.verified : Icons.warning,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        user.isEmailVerified ? 'Email Verified' : 'Email Not Verified',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CustomNeumorphicTheme.darkText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      NeumorphicContainer(
                        padding: EdgeInsets.all(6.w),
                        borderRadius: BorderRadius.circular(12),
                        color: user.hasTwoFactorEnabled ? CustomNeumorphicTheme.successGreen : CustomNeumorphicTheme.lightText,
                        child: Icon(
                          user.hasTwoFactorEnabled ? Icons.security : Icons.security_outlined,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        user.hasTwoFactorEnabled ? '2FA Enabled' : '2FA Disabled',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CustomNeumorphicTheme.darkText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      NeumorphicContainer(
                        padding: EdgeInsets.all(6.w),
                        borderRadius: BorderRadius.circular(12),
                        color: user.isOnline ? CustomNeumorphicTheme.successGreen : CustomNeumorphicTheme.lightText,
                        child: Icon(
                          user.isOnline ? Icons.circle : Icons.circle_outlined,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        user.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CustomNeumorphicTheme.darkText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ],
                    ),
                  ],
                ),
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
    return NeumorphicButton(
      onPressed: onTap,
      borderRadius: BorderRadius.circular(20),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 14.sp,
            color: CustomNeumorphicTheme.primaryPurple,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: CustomNeumorphicTheme.darkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
              style: TextStyle(
                fontSize: 12.sp,
                color: CustomNeumorphicTheme.lightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: CustomNeumorphicTheme.darkText,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CustomNeumorphicTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: CustomNeumorphicTheme.lightText,
                borderRadius: BorderRadius.circular(2.h),
              ),
            ),
            SizedBox(height: 20.h),
            NeumorphicButton(
              onPressed: () {
                Navigator.pop(context);
                _tabController.animateTo(2); // Switch to settings tab
              },
              borderRadius: BorderRadius.circular(12),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20.sp, color: CustomNeumorphicTheme.darkText),
                  SizedBox(width: 12.w),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: CustomNeumorphicTheme.darkText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            NeumorphicButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to help screen
              },
              borderRadius: BorderRadius.circular(12),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(Icons.help_outline, size: 20.sp, color: CustomNeumorphicTheme.darkText),
                  SizedBox(width: 12.w),
                  Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: CustomNeumorphicTheme.darkText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            NeumorphicButton(
              onPressed: () {
                Navigator.pop(context);
                _showSignOutDialog();
              },
              borderRadius: BorderRadius.circular(12),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20.sp, color: CustomNeumorphicTheme.errorRed),
                  SizedBox(width: 12.w),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: CustomNeumorphicTheme.errorRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
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
              backgroundColor: CustomNeumorphicTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}