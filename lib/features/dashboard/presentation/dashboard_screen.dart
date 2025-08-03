import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../core/models/project_model.dart';
import '../../../core/widgets/database_status_widget.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/theme/app_colors.dart';
import '../../project_creation/providers/project_provider.dart';
import '../../user_management/providers/user_provider.dart';
import '../widgets/project_overview_card.dart';
import '../widgets/project_progress_chart.dart';
import '../widgets/phases_list.dart';
import '../../task_management/widgets/responsive_kanban_board.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String? projectId;
  
  const DashboardScreen({super.key, this.projectId});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showAllProjects = false;

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectNotifierProvider);
    
    return Scaffold(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      appBar: NeumorphicAppBar(
        title: Text(
          'ProjectFlow AI',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          NeumorphicButton(
            onPressed: () => context.push('/profile'),
            borderRadius: BorderRadius.circular(25),
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.person,
              color: CustomNeumorphicTheme.primaryPurple,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 8.w),
          NeumorphicButton(
            onPressed: () => _showProjectMenu(context),
            borderRadius: BorderRadius.circular(25),
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.more_vert,
              color: CustomNeumorphicTheme.darkText,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: projectsState.when(
        data: (projects) {
          if (projects.isEmpty) {
            return _buildEmptyState(context);
          }
          
          if (widget.projectId != null) {
            final project = projects.firstWhere(
              (p) => p.id == widget.projectId,
              orElse: () => projects.first,
            );
            return _buildProjectDashboard(context, project, ref);
          }
          
          return _buildProjectsList(context, projects, ref);
        },
        loading: () => const Center(
          child: LoadingIndicator(message: 'Loading projects...'),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading projects',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              NeumorphicButton(
                onPressed: () {
                  ref.invalidate(projectNotifierProvider);
                },
                borderRadius: BorderRadius.circular(12),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: CustomNeumorphicTheme.primaryPurple,
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch,
              size: 96,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to ProjectFlow AI',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Get started by describing your project idea. Our AI will help you break it down into manageable phases and tasks.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            NeumorphicButton(
              onPressed: () {
                context.push('/create-project');
              },
              isSelected: true,
              selectedColor: CustomNeumorphicTheme.primaryPurple,
              borderRadius: BorderRadius.circular(15),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Create Your First Project',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Database status widget for testing
            const DatabaseStatusWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList(BuildContext context, List<Project> projects, WidgetRef ref) {
    // Sort projects by most recent first
    final sortedProjects = List<Project>.from(projects)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Calculate overall statistics
    final totalProjects = projects.length;
    final activeProjects = projects.where((p) => p.status == ProjectStatus.inProgress).length;
    final totalTasks = projects.fold<int>(0, (sum, project) => 
      sum + project.phases.fold<int>(0, (phaseSum, phase) => phaseSum + phase.tasks.length));
    final openTasks = projects.fold<int>(0, (sum, project) => 
      sum + project.phases.fold<int>(0, (phaseSum, phase) => 
        phaseSum + phase.tasks.where((task) => task.status != TaskStatus.completed).length));
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Greeting (only on main dashboard)
          _buildUserGreeting(context, ref),
          SizedBox(height: 20.h),
          
          // Quick Stats Cards
          _buildQuickStats(context, totalProjects, activeProjects, totalTasks, openTasks),
          SizedBox(height: 24.h),
          
          // Recent Projects Header
          Row(
            children: [
              Text(
                'Recent Projects',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
              if (sortedProjects.length > 1) ...[
                const Spacer(),
                Text(
                  '${sortedProjects.length} total',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          
          // Most Recent Project (always shown)
          if (sortedProjects.isNotEmpty) 
            _buildProjectCard(context, sortedProjects.first),
          
          // Expandable Section for Additional Projects
          if (sortedProjects.length > 1) ...[
            SizedBox(height: 12.h),
            _buildExpandableSection(context, sortedProjects.skip(1).toList()),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandableSection(BuildContext context, List<Project> additionalProjects) {
    return NeumorphicCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showAllProjects = !_showAllProjects;
              });
            },
            child: Row(
              children: [
                Text(
                  _showAllProjects ? 'See Less' : 'See More',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.primaryPurple,
                  ),
                ),
                SizedBox(width: 8.w),
                AnimatedRotation(
                  turns: _showAllProjects ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: CustomNeumorphicTheme.primaryPurple,
                    size: 18.sp,
                  ),
                ),
                const Spacer(),
                Text(
                  '${additionalProjects.length} more project${additionalProjects.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
              ],
            ),
          ),
          
          // Animated expandable content
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showAllProjects
                ? Column(
                    children: [
                      SizedBox(height: 16.h),
                      ...additionalProjects.map((project) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildProjectCard(context, project),
                      )),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDashboard(BuildContext context, Project project, WidgetRef ref) {
    final projectTasks = project.phases.fold<int>(0, (sum, phase) => sum + phase.tasks.length);
    final completedTasks = project.phases.fold<int>(0, (sum, phase) => 
      sum + phase.tasks.where((task) => task.status == TaskStatus.completed).length);
    final inProgressTasks = project.phases.fold<int>(0, (sum, phase) => 
      sum + phase.tasks.where((task) => task.status == TaskStatus.inProgress).length);
    final openTasks = projectTasks - completedTasks;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    _StatusChip(status: project.status),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.list),
                tooltip: 'Back to Projects',
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // Project Summary Tile
          _buildProjectSummaryTile(context, project, completedTasks, projectTasks, inProgressTasks),
          SizedBox(height: 24.h),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: NeumorphicButton(
                  onPressed: () => context.go('/tasks/${project.id}'),
                  isSelected: true,
                  selectedColor: CustomNeumorphicTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(12),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, color: Colors.white, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'View Tasks',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: NeumorphicButton(
                  onPressed: () => context.push('/create-task?project=${project.id}'),
                  borderRadius: BorderRadius.circular(12),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: CustomNeumorphicTheme.primaryPurple, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Add Task',
                        style: TextStyle(
                          color: CustomNeumorphicTheme.primaryPurple,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          // Phases Overview
          Text(
            'Project Phases',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          
          // Simplified phases list
          ...project.phases.map((phase) => _buildPhaseCard(context, phase, project.id)),
        ],
      ),
    );
  }

  Widget _buildPhaseCard(BuildContext context, ProjectPhase phase, String projectId) {
    final phaseTasks = phase.tasks.length;
    final completedTasks = phase.tasks.where((task) => task.status == TaskStatus.completed).length;
    final progress = phaseTasks > 0 ? (completedTasks / phaseTasks) : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: NeumorphicCard(
        onTap: () => context.go('/tasks/$projectId?phase=${phase.id}'),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    phase.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ],
            ),
            if (phase.description.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                phase.description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: CustomNeumorphicTheme.lightText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      NeumorphicProgressBar(
                        progress: progress,
                        height: 6.h,
                        progressColor: _getProgressColor(progress),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _getProgressColor(progress),
                      ),
                    ),
                    Text(
                      '$completedTasks/$phaseTasks tasks',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: CustomNeumorphicTheme.lightText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, int totalProjects, int activeProjects, int totalTasks, int openTasks) {
    return _buildUnifiedSummaryTile(
      context,
      totalProjects,
      activeProjects,
      totalTasks,
      openTasks,
    );
  }

  Widget _buildUserGreeting(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    
    return currentUserAsync.when(
      data: (user) {
        final now = DateTime.now();
        final hour = now.hour;
        String greeting;
        
        if (hour < 12) {
          greeting = 'Good morning';
        } else if (hour < 17) {
          greeting = 'Good afternoon';
        } else {
          greeting = 'Good evening';
        }
        
        final userName = user?.displayName ?? (user?.email != null ? user!.email!.split('@').first : null) ?? 'there';
        
        return Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello,',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
            ],
          ),
        ),
      error: (error, stack) => Padding(
        padding: EdgeInsets.only(left: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello,',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: CustomNeumorphicTheme.lightText,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'there',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: CustomNeumorphicTheme.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedSummaryTile(BuildContext context, int totalProjects, int activeProjects, int totalTasks, int openTasks) {
    final completedTasks = totalTasks - openTasks;
    final taskCompletionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;
    
    return NeumorphicFlatContainer(
      padding: EdgeInsets.all(20.w),
      borderRadius: BorderRadius.circular(16.r),
      color: CustomNeumorphicTheme.baseColor,
      onTap: () {
        // Navigate to detailed overview or stats
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title
          Row(
            children: [
              NeumorphicContainer(
                padding: EdgeInsets.all(10.w),
                borderRadius: BorderRadius.circular(12),
                color: CustomNeumorphicTheme.primaryPurple,
                child: Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Project Overview',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20.h),
          
          // Unified stats in a clean layout
          Row(
            children: [
              // Projects section
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.dashboard,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Projects',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: CustomNeumorphicTheme.lightText,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '$activeProjects/$totalProjects',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Vertical divider
              Container(
                height: 60.h,
                width: 1.w,
                color: CustomNeumorphicTheme.lightText.withOpacity(0.3),
              ),
              
              // Tasks section  
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 16.sp,
                            color: AppColors.secondary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Tasks',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: CustomNeumorphicTheme.lightText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '$openTasks',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: CustomNeumorphicTheme.darkText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$taskCompletionRate% Done',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSummaryTile(BuildContext context, Project project, int completedTasks, int projectTasks, int inProgressTasks) {
    final completionRate = projectTasks > 0 ? (completedTasks / projectTasks * 100).round() : 0;
    
    return NeumorphicFlatContainer(
      padding: EdgeInsets.all(20.w),
      borderRadius: BorderRadius.circular(16.r),
      color: CustomNeumorphicTheme.baseColor,
      onTap: () {
        // Navigate to detailed project stats
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unified project stats (no header title needed)
          Row(
            children: [
              // Completed tasks section
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16.sp,
                          color: AppColors.projectCompleted,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: CustomNeumorphicTheme.lightText,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '$completedTasks/$projectTasks',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$completionRate% Done',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.projectCompleted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Vertical divider
              Container(
                height: 60.h,
                width: 1.w,
                color: CustomNeumorphicTheme.lightText.withOpacity(0.3),
              ),
              
              // In Progress tasks section  
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 16.sp,
                            color: AppColors.projectInProgress,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'In Progress',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: CustomNeumorphicTheme.lightText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '$inProgressTasks',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: CustomNeumorphicTheme.darkText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Active Tasks',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.projectInProgress,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String subtitle, IconData icon, Color color) {
    return NeumorphicEmbossedCard(
      padding: EdgeInsets.all(16.w),
      onTap: () {
        // Add haptic feedback and potential navigation
        // Could navigate to detailed stats view
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeumorphicContainer(
                padding: EdgeInsets.all(8.w),
                borderRadius: BorderRadius.circular(12),
                color: color,
                child: Icon(icon, color: Colors.white, size: 16.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: CustomNeumorphicTheme.darkText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.sp,
              color: CustomNeumorphicTheme.lightText,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    final projectTasks = project.phases.fold<int>(0, (sum, phase) => sum + phase.tasks.length);
    final completedTasks = project.phases.fold<int>(0, (sum, phase) => 
      sum + phase.tasks.where((task) => task.status == TaskStatus.completed).length);
    final progress = projectTasks > 0 ? (completedTasks / projectTasks) : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: NeumorphicCard(
        onTap: () => context.go('/tasks/${project.id}'),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.w),
                _StatusChip(status: project.status),
              ],
            ),
            SizedBox(height: 12.h),
            if (project.description.isNotEmpty) ...[
              Text(
                project.description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16.h),
            ],
            // Progress Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: CustomNeumorphicTheme.lightText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      NeumorphicProgressBar(
                        progress: progress,
                        height: 6.h,
                        progressColor: _getProgressColor(progress),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: _getProgressColor(progress),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.task, size: 14.sp, color: CustomNeumorphicTheme.lightText),
                SizedBox(width: 6.w),
                Text(
                  '$completedTasks/$projectTasks tasks',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: CustomNeumorphicTheme.lightText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 20.w),
                Icon(Icons.timeline, size: 14.sp, color: CustomNeumorphicTheme.lightText),
                SizedBox(width: 6.w),
                Text(
                  '${project.phases.length} phases',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: CustomNeumorphicTheme.lightText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return CustomNeumorphicTheme.successGreen;
    if (progress >= 0.5) return CustomNeumorphicTheme.primaryPurple;
    return CustomNeumorphicTheme.secondaryPurple;
  }

  void _showProjectMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Project Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Team'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to team management
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('View Reports'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to reports
            },
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ProjectStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case ProjectStatus.planning:
        color = CustomNeumorphicTheme.secondaryPurple;
        label = 'Planning';
        break;
      case ProjectStatus.inProgress:
        color = CustomNeumorphicTheme.primaryPurple;
        label = 'In Progress';
        break;
      case ProjectStatus.completed:
        color = CustomNeumorphicTheme.successGreen;
        label = 'Completed';
        break;
      case ProjectStatus.onHold:
        color = CustomNeumorphicTheme.lightText;
        label = 'On Hold';
        break;
      case ProjectStatus.cancelled:
        color = CustomNeumorphicTheme.errorRed;
        label = 'Cancelled';
        break;
    }

    return NeumorphicContainer(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      borderRadius: BorderRadius.circular(15),
      color: color,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}