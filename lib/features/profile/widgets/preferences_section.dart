import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../user_management/providers/user_provider.dart';

class PreferencesSection extends ConsumerWidget {
  final AppUser user;

  const PreferencesSection({
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
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: AppColors.accent,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            
            // Appearance preferences
            _buildPreferenceCategory(
              context,
              'Appearance',
              Icons.palette,
              [
                _buildThemeSetting(context, ref),
                _buildLanguageSetting(context, ref),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Notification preferences
            _buildPreferenceCategory(
              context,
              'Notifications',
              Icons.notifications,
              [
                _buildNotificationSetting(
                  context,
                  ref,
                  'Push Notifications',
                  'Receive push notifications on your device',
                  user.preferences.pushNotifications,
                  (value) => _updatePreference(
                    ref,
                    user.preferences.copyWith(pushNotifications: value),
                  ),
                ),
                _buildNotificationSetting(
                  context,
                  ref,
                  'Email Notifications',
                  'Receive notifications via email',
                  user.preferences.emailNotifications,
                  (value) => _updatePreference(
                    ref,
                    user.preferences.copyWith(emailNotifications: value),
                  ),
                ),
                _buildNotificationSetting(
                  context,
                  ref,
                  'Desktop Notifications',
                  'Show notifications on desktop',
                  user.preferences.desktopNotifications,
                  (value) => _updatePreference(
                    ref,
                    user.preferences.copyWith(desktopNotifications: value),
                  ),
                ),
                _buildNotificationSetting(
                  context,
                  ref,
                  'Sound Effects',
                  'Play sounds for notifications',
                  user.preferences.soundEnabled,
                  (value) => _updatePreference(
                    ref,
                    user.preferences.copyWith(soundEnabled: value),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Workflow preferences
            _buildPreferenceCategory(
              context,
              'Workflow',
              Icons.work,
              [
                _buildNotificationSetting(
                  context,
                  ref,
                  'Auto-Complete Tasks',
                  'Automatically mark tasks as done when moved to completed',
                  user.preferences.autoCompleteTasksInDone,
                  (value) => _updatePreference(
                    ref,
                    user.preferences.copyWith(autoCompleteTasksInDone: value),
                  ),
                ),
                _buildNotificationSetting(
                  context,
                  ref,
                  'Show Project Progress',
                  'Display progress bars on project cards',
                  user.preferences.showProjectProgress,
                  (value) => _updatePreference(
                    ref,
                    user.preferences.copyWith(showProjectProgress: value),
                  ),
                ),
                _buildNotificationSetting(
                  context,
                  ref,
                  'Enable Drag & Drop',
                  'Allow drag and drop for task management',
                  user.preferences.enableDragAndDrop,
                  (value) => _updatePreference(
                    ref,
                    user.preferences.copyWith(enableDragAndDrop: value),
                  ),
                ),
                _buildNotificationSetting(
                  context,
                  ref,
                  'Compact Task View',
                  'Use compact layout for task lists',
                  user.preferences.compactTaskView,
                  (value) => _updatePreference(
                    ref,
                    user.preferences.copyWith(compactTaskView: value),
                  ),
                ),
                _buildNotificationSetting(
                  context,
                  ref,
                  'Show Task Estimates',
                  'Display time estimates on tasks',
                  user.preferences.showTaskEstimates,
                  (value) => _updatePreference(
                    ref,
                    user.preferences.copyWith(showTaskEstimates: value),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Working hours settings
            _buildPreferenceCategory(
              context,
              'Working Hours',
              Icons.schedule,
              [
                _buildWorkingHoursSetting(context, ref),
                _buildWorkingDaysSetting(context, ref),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Privacy & Data preferences
            _buildPreferenceCategory(
              context,
              'Privacy & Data',
              Icons.privacy_tip,
              [
                _buildNotificationSetting(
                  context,
                  ref,
                  'Enable Analytics',
                  'Help improve our service with usage analytics',
                  user.preferences.enableAnalytics,
                  (value) => _updatePreference(
                    ref,
                    user.preferences.copyWith(enableAnalytics: value),
                  ),
                ),
                _buildNotificationSetting(
                  context,
                  ref,
                  'Auto Backup',
                  'Automatically backup your data',
                  user.preferences.enableAutoBackup,
                  (value) => _updatePreference(
                    ref,
                    user.preferences.copyWith(enableAutoBackup: value),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Reset preferences button
            Center(
              child: OutlinedButton.icon(
                onPressed: () => _showResetPreferencesDialog(context, ref),
                icon: const Icon(Icons.restore),
                label: const Text('Reset to Defaults'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceCategory(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...children,
      ],
    );
  }

  Widget _buildThemeSetting(BuildContext context, WidgetRef ref) {
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
            'Theme Mode',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  context,
                  ref,
                  'Light',
                  Icons.light_mode,
                  AppThemeMode.light,
                  user.preferences.themeMode == AppThemeMode.light,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildThemeOption(
                  context,
                  ref,
                  'Dark',
                  Icons.dark_mode,
                  AppThemeMode.dark,
                  user.preferences.themeMode == AppThemeMode.dark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildThemeOption(
                  context,
                  ref,
                  'System',
                  Icons.auto_mode,
                  AppThemeMode.system,
                  user.preferences.themeMode == AppThemeMode.system,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    AppThemeMode mode,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => _updatePreference(
        ref,
        user.preferences.copyWith(themeMode: mode),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSetting(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.language,
            size: 20.sp,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Choose your preferred language',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: user.preferences.language,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'es', child: Text('Español')),
              DropdownMenuItem(value: 'fr', child: Text('Français')),
              DropdownMenuItem(value: 'de', child: Text('Deutsch')),
              DropdownMenuItem(value: 'it', child: Text('Italiano')),
            ],
            onChanged: (value) {
              if (value != null) {
                _updatePreference(
                  ref,
                  user.preferences.copyWith(language: value),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSetting(
    BuildContext context,
    WidgetRef ref,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
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
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursSetting(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Working Hours',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildTimeSelector(
                  context,
                  ref,
                  'Start',
                  user.preferences.workingHoursStart,
                  (value) => _updatePreference(
                    ref,
                    user.preferences.copyWith(workingHoursStart: value),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildTimeSelector(
                  context,
                  ref,
                  'End',
                  user.preferences.workingHoursEnd,
                  (value) => _updatePreference(
                    ref,
                    user.preferences.copyWith(workingHoursEnd: value),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    WidgetRef ref,
    String label,
    int currentHour,
    Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        DropdownButton<int>(
          value: currentHour,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          items: List.generate(24, (index) {
            final hour = index;
            final displayHour = user.preferences.timeFormat == TimeFormat.hour12
                ? (hour == 0 ? 12 : hour > 12 ? hour - 12 : hour)
                : hour;
            final period = user.preferences.timeFormat == TimeFormat.hour12
                ? (hour < 12 ? 'AM' : 'PM')
                : '';
            
            return DropdownMenuItem(
              value: hour,
              child: Text('$displayHour:00 $period'.trim()),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildWorkingDaysSetting(BuildContext context, WidgetRef ref) {
    final daysOfWeek = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
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
            'Working Days',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: daysOfWeek.asMap().entries.map((entry) {
              final index = entry.key + 1; // 1-7 for Monday-Sunday
              final day = entry.value;
              final isSelected = user.preferences.workingDays.contains(index);
              
              return GestureDetector(
                onTap: () {
                  final updatedDays = List<int>.from(user.preferences.workingDays);
                  if (isSelected) {
                    updatedDays.remove(index);
                  } else {
                    updatedDays.add(index);
                  }
                  updatedDays.sort();
                  
                  _updatePreference(
                    ref,
                    user.preferences.copyWith(workingDays: updatedDays),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    day.length >= 3 ? day.substring(0, 3) : day, // Show first 3 letters
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _updatePreference(WidgetRef ref, UserPreferences updatedPreferences) async {
    try {
      await ref.read(userManagementProvider.notifier)
          .updatePreferences(user.id, updatedPreferences);
    } catch (e) {
      // Handle error - could show a snackbar or toast
      debugPrint('Error updating preferences: $e');
    }
  }

  void _showResetPreferencesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Preferences'),
        content: const Text(
          'Are you sure you want to reset all preferences to their default values? This action cannot be undone.',
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
                    .updatePreferences(user.id, UserPreferences.defaultPreferences());
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preferences reset to defaults'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}