import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/custom_neumorphic_theme.dart';
import '../theme/app_colors.dart';
import '../../core/models/project_model.dart';
import '../../core/models/team_model.dart';
import '../../features/project_creation/providers/project_provider.dart';
import '../../features/team_management/providers/team_provider.dart';
import '../../features/user_management/providers/user_provider.dart';

class LinkProjectTeamDialog extends ConsumerStatefulWidget {
  final Project project;

  const LinkProjectTeamDialog({
    super.key,
    required this.project,
  });

  @override
  ConsumerState<LinkProjectTeamDialog> createState() => _LinkProjectTeamDialogState();
}

class _LinkProjectTeamDialogState extends ConsumerState<LinkProjectTeamDialog> {
  String? _selectedTeamId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTeamId = widget.project.metadata.teamId;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    
    return currentUser.when(
      data: (user) {
        if (user == null) {
          return Dialog(
            backgroundColor: CustomNeumorphicTheme.baseColor,
            child: Container(
              padding: EdgeInsets.all(24.w),
              child: const Text('Please sign in to link teams'),
            ),
          );
        }
        
        final teamsAsync = ref.watch(userTeamsProvider(user.id));

        return teamsAsync.when(
          data: (teams) => Dialog(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.link,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Link to Team',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: CustomNeumorphicTheme.darkText,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Enable team collaboration for tasks',
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
            
            SizedBox(height: 20.h),
            
            // Project info
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.folder,
                    color: AppColors.info,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      widget.project.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Team selection
            Text(
              'Select Team:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: CustomNeumorphicTheme.darkText,
              ),
            ),
            SizedBox(height: 8.h),

            teamsAsync.when(
              data: (teams) {
                if (teams.isEmpty) {
                  return _buildEmptyState();
                }
                
                return SizedBox(
                  height: 200.h,
                  child: ListView.builder(
                    itemCount: teams.length + 1, // +1 for "No team" option
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // No team option
                        return _TeamOption(
                          team: null,
                          isSelected: _selectedTeamId == null,
                          onTap: () {
                            setState(() {
                              _selectedTeamId = null;
                            });
                          },
                        );
                      }
                      
                      final team = teams[index - 1];
                      return _TeamOption(
                        team: team,
                        isSelected: _selectedTeamId == team.id,
                        onTap: () {
                          setState(() {
                            _selectedTeamId = team.id;
                          });
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => SizedBox(
                height: 100.h,
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
            
            SizedBox(height: 20.h),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12.r),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      'Cancel',
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
                    onPressed: _isLoading ? null : _linkToTeam,
                    selectedColor: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
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
                            'Link Project',
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Icon(
            Icons.group_off,
            size: 32.sp,
            color: CustomNeumorphicTheme.lightText,
          ),
          SizedBox(height: 8.h),
          Text(
            'No teams found',
            style: TextStyle(
              fontSize: 14.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            'Create a team first to enable collaboration',
            style: TextStyle(
              fontSize: 12.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 32.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 8.h),
          Text(
            'Error loading teams',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: CustomNeumorphicTheme.darkText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _linkToTeam() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Link to selected team (null if no team selected)
      await ref.read(projectNotifierProvider.notifier).linkProjectToTeam(
        widget.project.id,
        _selectedTeamId, // Can be null, will be handled properly
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        
        final message = _selectedTeamId != null 
            ? 'Project linked to team successfully'
            : 'Project unlinked from team';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error linking project: $error'),
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

class _TeamOption extends StatelessWidget {
  final Team? team;
  final bool isSelected;
  final VoidCallback onTap;

  const _TeamOption({
    required this.team,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: NeumorphicButton(
        onPressed: onTap,
        isSelected: isSelected,
        selectedColor: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // Team icon
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: team == null 
                    ? AppColors.warning.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                team == null ? Icons.close : Icons.group,
                size: 16.sp,
                color: team == null ? AppColors.warning : AppColors.primary,
              ),
            ),
            
            SizedBox(width: 12.w),
            
            // Team info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team?.name ?? 'No Team',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? AppColors.primary 
                          : CustomNeumorphicTheme.darkText,
                    ),
                  ),
                  if (team != null) ...[ 
                    SizedBox(height: 2.h),
                    Text(
                      '${team!.totalMembers} members',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: CustomNeumorphicTheme.lightText,
                      ),
                    ),
                  ] else ...[
                    SizedBox(height: 2.h),
                    Text(
                      'Work independently without team collaboration',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: CustomNeumorphicTheme.lightText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 18.sp,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
        );
      },
      loading: () => Dialog(
        backgroundColor: CustomNeumorphicTheme.baseColor,
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Dialog(
        backgroundColor: CustomNeumorphicTheme.baseColor,
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}