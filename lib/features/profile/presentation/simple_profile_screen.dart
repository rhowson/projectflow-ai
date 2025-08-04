import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../auth/providers/auth_provider.dart';

class SimpleProfileScreen extends ConsumerWidget {
  const SimpleProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDisplayInfo = ref.watch(userDisplayInfoProvider);
    final currentUser = ref.watch(currentUserProvider);
    final hasLoggedInOnce = ref.watch(hasLoggedInOnceProvider);
    final isBiometricEnabled = ref.watch(isBiometricEnabledProvider);
    final biometricAvailability = ref.watch(biometricAvailabilityProvider);

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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // User Profile Card
            _buildUserProfileCard(context, ref, userDisplayInfo, currentUser),
            SizedBox(height: 24.h),
            
            // Authentication Settings Card
            if (hasLoggedInOnce) _buildAuthenticationCard(context, ref, isBiometricEnabled, biometricAvailability),
            if (hasLoggedInOnce) SizedBox(height: 24.h),
            
            // Settings & Actions Card
            _buildSettingsCard(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context, WidgetRef ref, UserDisplayInfo? userDisplayInfo, AsyncValue currentUser) {
    return NeumorphicCard(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              NeumorphicContainer(
                padding: EdgeInsets.all(4.w),
                borderRadius: BorderRadius.circular(40.r),
                color: CustomNeumorphicTheme.primaryPurple,
                child: CircleAvatar(
                  radius: 36.r,
                  backgroundColor: CustomNeumorphicTheme.primaryPurple,
                  backgroundImage: userDisplayInfo?.photoURL != null 
                      ? NetworkImage(userDisplayInfo!.photoURL!) 
                      : null,
                  child: userDisplayInfo?.photoURL == null 
                      ? Text(
                          userDisplayInfo?.initials ?? 'U',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
              if (userDisplayInfo?.isEmailVerified == true)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: NeumorphicContainer(
                    padding: EdgeInsets.all(4.w),
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.green,
                    child: Icon(
                      Icons.verified,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // User Name
          Text(
            userDisplayInfo?.formattedName ?? 'User',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: CustomNeumorphicTheme.darkText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          
          // Email
          if (userDisplayInfo?.email != null)
            Text(
              userDisplayInfo!.email!,
              style: TextStyle(
                fontSize: 14.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 16.h),
          
          // User Details
          currentUser.when(
            data: (user) => user != null ? _buildUserDetails(context, user) : const SizedBox.shrink(),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetails(BuildContext context, user) {
    return Column(
      children: [
        if (user.authProvider != null) ...[
          _buildDetailRow(
            context,
            'Authentication',
            _getAuthProviderDisplayName(user.authProvider),
            _getAuthProviderIcon(user.authProvider),
          ),
          SizedBox(height: 12.h),
        ],
        if (user.role != null) ...[
          _buildDetailRow(
            context,
            'Role',
            user.role.toString().split('.').last.toUpperCase(),
            Icons.admin_panel_settings,
          ),
          SizedBox(height: 12.h),
        ],
        if (user.createdAt != null)
          _buildDetailRow(
            context,
            'Member Since',
            _formatDate(user.createdAt),
            Icons.calendar_today,
          ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: CustomNeumorphicTheme.primaryPurple,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: CustomNeumorphicTheme.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticationCard(BuildContext context, WidgetRef ref, bool isBiometricEnabled, AsyncValue<bool> biometricAvailability) {
    return NeumorphicCard(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Authentication & Security',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: CustomNeumorphicTheme.darkText,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Biometric Authentication Toggle
          biometricAvailability.when(
            data: (isAvailable) => isAvailable 
                ? _buildBiometricToggle(context, ref, isBiometricEnabled)
                : _buildBiometricUnavailable(context),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => _buildBiometricUnavailable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricToggle(BuildContext context, WidgetRef ref, bool isEnabled) {
    return NeumorphicContainer(
      padding: EdgeInsets.all(16.w),
      borderRadius: BorderRadius.circular(12.r),
      child: Row(
        children: [
          Icon(
            Icons.fingerprint,
            size: 24.sp,
            color: CustomNeumorphicTheme.primaryPurple,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biometric Authentication',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
                Text(
                  'Use fingerprint or face ID to sign in',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) async {
              if (value) {
                try {
                  await ref.read(authNotifierProvider.notifier).enableBiometricAuth();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to enable biometric authentication: $e'),
                        backgroundColor: CustomNeumorphicTheme.errorRed,
                      ),
                    );
                  }
                }
              } else {
                await ref.read(authNotifierProvider.notifier).disableBiometricAuth();
              }
            },
            activeColor: CustomNeumorphicTheme.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricUnavailable(BuildContext context) {
    return NeumorphicContainer(
      padding: EdgeInsets.all(16.w),
      borderRadius: BorderRadius.circular(12.r),
      color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            Icons.fingerprint_outlined,
            size: 24.sp,
            color: CustomNeumorphicTheme.lightText,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biometric Authentication',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
                Text(
                  'Not available on this device',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, WidgetRef ref) {
    return NeumorphicCard(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings & Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: CustomNeumorphicTheme.darkText,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Edit Profile Button
          NeumorphicButton(
            onPressed: () {
              // TODO: Navigate to edit profile
            },
            borderRadius: BorderRadius.circular(12.r),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Icon(Icons.edit, size: 18.sp, color: CustomNeumorphicTheme.primaryPurple),
                SizedBox(width: 12.w),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: CustomNeumorphicTheme.darkText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, size: 18.sp, color: CustomNeumorphicTheme.lightText),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          
          // Sign Out Button
          NeumorphicButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
            borderRadius: BorderRadius.circular(12.r),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Icon(Icons.logout, size: 18.sp, color: CustomNeumorphicTheme.errorRed),
                SizedBox(width: 12.w),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    color: CustomNeumorphicTheme.errorRed,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAuthProviderDisplayName(String? provider) {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple';
      case 'email':
        return 'Email';
      default:
        return 'Unknown';
    }
  }

  IconData _getAuthProviderIcon(String? provider) {
    switch (provider) {
      case 'google':
        return Icons.g_mobiledata;
      case 'apple':
        return Icons.apple;
      case 'email':
        return Icons.email;
      default:
        return Icons.account_circle;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}