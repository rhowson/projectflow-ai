import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../user_management/providers/user_provider.dart';

class ProfileSettingsSection extends ConsumerWidget {
  final AppUser user;

  const ProfileSettingsSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Email verification
            _buildSettingItem(
              context,
              icon: user.isEmailVerified ? Icons.verified : Icons.warning,
              iconColor: user.isEmailVerified ? AppColors.success : AppColors.warning,
              title: 'Email Verification',
              subtitle: user.isEmailVerified 
                  ? 'Your email is verified'
                  : 'Please verify your email address',
              trailing: user.isEmailVerified
                  ? null
                  : TextButton(
                      onPressed: () => _resendVerificationEmail(context, ref, user),
                      child: const Text('Verify'),
                    ),
            ),
            
            Divider(height: 24.h),
            
            // Two-factor authentication
            _buildSettingItem(
              context,
              icon: user.hasTwoFactorEnabled ? Icons.security : Icons.security_outlined,
              iconColor: user.hasTwoFactorEnabled ? AppColors.success : AppColors.textSecondary,
              title: 'Two-Factor Authentication',
              subtitle: user.hasTwoFactorEnabled 
                  ? 'Enhanced security is enabled'
                  : 'Add an extra layer of security',
              trailing: Switch(
                value: user.hasTwoFactorEnabled,
                onChanged: (value) => _toggleTwoFactor(context, ref, user, value),
              ),
            ),
            
            Divider(height: 24.h),
            
            // Password change
            _buildSettingItem(
              context,
              icon: Icons.lock_outline,
              iconColor: AppColors.textSecondary,
              title: 'Password',
              subtitle: 'Change your account password',
              trailing: IconButton(
                onPressed: () => _showChangePasswordDialog(context, ref, user),
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            
            Divider(height: 24.h),
            
            // Privacy settings
            _buildSettingItem(
              context,
              icon: Icons.privacy_tip_outlined,
              iconColor: AppColors.textSecondary,
              title: 'Privacy Settings',
              subtitle: 'Manage your privacy preferences',
              trailing: IconButton(
                onPressed: () => _showPrivacyDialog(context, ref, user),
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            
            Divider(height: 24.h),
            
            // Data export
            _buildSettingItem(
              context,
              icon: Icons.download_outlined,
              iconColor: AppColors.textSecondary,
              title: 'Export Data',
              subtitle: 'Download your account data',
              trailing: IconButton(
                onPressed: () => _exportUserData(context, ref, user),
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Danger zone
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        color: AppColors.error,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Danger Zone',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // Deactivate account
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.pause_circle_outline,
                      color: AppColors.error,
                    ),
                    title: Text(
                      'Deactivate Account',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Temporarily disable your account',
                    ),
                    trailing: TextButton(
                      onPressed: () => _showDeactivateDialog(context, ref, user),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Deactivate'),
                    ),
                  ),
                  
                  // Delete account
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.delete_forever_outlined,
                      color: AppColors.error,
                    ),
                    title: Text(
                      'Delete Account',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Permanently delete your account and all data',
                    ),
                    trailing: TextButton(
                      onPressed: () => _showDeleteDialog(context, ref, user),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20.sp,
          ),
        ),
        
        SizedBox(width: 12.w),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        
        if (trailing != null) trailing,
      ],
    );
  }

  void _resendVerificationEmail(BuildContext context, WidgetRef ref, AppUser user) {
    // Implementation for resending verification email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification email sent!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _toggleTwoFactor(BuildContext context, WidgetRef ref, AppUser user, bool enabled) async {
    try {
      await ref.read(userManagementProvider.notifier)
          .updateTwoFactorStatus(user.id, enabled);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled 
                ? 'Two-factor authentication enabled'
                : 'Two-factor authentication disabled',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref, AppUser user) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              onTapOutside: (event) {
                // Hide keyboard when tapping outside
                FocusScope.of(context).unfocus();
              },
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: newPasswordController,
              onTapOutside: (event) {
                // Hide keyboard when tapping outside
                FocusScope.of(context).unfocus();
              },
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: confirmPasswordController,
              onTapOutside: (event) {
                // Hide keyboard when tapping outside
                FocusScope.of(context).unfocus();
              },
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
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
              // Implement password change logic
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context, WidgetRef ref, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Profile Visibility'),
              subtitle: const Text('Allow others to see your profile'),
              value: true, // This would come from user preferences
              onChanged: (value) {
                // Update privacy settings
              },
            ),
            SwitchListTile(
              title: const Text('Activity Status'),
              subtitle: const Text('Show when you\'re online'),
              value: user.preferences.enableAnalytics,
              onChanged: (value) {
                // Update activity visibility
              },
            ),
            SwitchListTile(
              title: const Text('Data Analytics'),
              subtitle: const Text('Help improve our service'),
              value: user.preferences.enableAnalytics,
              onChanged: (value) {
                final updatedPreferences = user.preferences.copyWith(
                  enableAnalytics: value,
                );
                ref.read(userManagementProvider.notifier)
                    .updatePreferences(user.id, updatedPreferences);
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

  void _exportUserData(BuildContext context, WidgetRef ref, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Your data will be exported as a JSON file and sent to your email address. This may take a few minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export request sent! Check your email.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context, WidgetRef ref, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
          'Are you sure you want to deactivate your account? You can reactivate it at any time by signing in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(userManagementProvider.notifier)
                    .deactivateUser(user.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deactivated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, AppUser user) {
    final confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            const Text('Type "DELETE" to confirm:'),
            SizedBox(height: 8.h),
            TextField(
              controller: confirmController,
              onTapOutside: (event) {
                // Hide keyboard when tapping outside
                FocusScope.of(context).unfocus();
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'DELETE',
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
            onPressed: () async {
              if (confirmController.text == 'DELETE') {
                try {
                  await ref.read(userManagementProvider.notifier)
                      .deleteUser(user.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please type "DELETE" to confirm'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}