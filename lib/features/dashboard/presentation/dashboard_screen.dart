import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../core/models/project_model.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/theme/app_colors.dart';
import '../../project_creation/providers/project_provider.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with WidgetsBindingObserver {
  bool _showAllProjects = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh projects when dashboard screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectNotifierProvider.notifier).loadProjects();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh projects when app comes back to foreground
      ref.read(projectNotifierProvider.notifier).loadProjects();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh projects when returning to dashboard (e.g., from project creation)
    ref.read(projectNotifierProvider.notifier).loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectNotifierProvider);
    
    return Scaffold(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      appBar: NeumorphicAppBar(
        title: GestureDetector(
          onLongPress: () => _showClearDatabaseDialog(context, ref),
          child: Text(
            'ProjectFlow AI',
            style: Theme.of(context).textTheme.headlineSmall,
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
          SizedBox(width: 16.w),
        ],
      ),
      body: projectsState.when(
        data: (projects) {
          if (projects.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(projectNotifierProvider.notifier).loadProjects();
            },
            child: _buildProjectsList(context, projects, ref),
          );
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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Greeting Section - Enhanced spacing
          _buildUserGreetingSection(context, ref),
          SizedBox(height: 8.h), // Further reduced spacing between greeting and overview
          
          // Quick Stats Section - Wrapped in container for better definition
          _buildStatsSection(context, totalProjects, activeProjects, totalTasks, openTasks),
          SizedBox(height: 40.h), // Generous spacing between major sections
          
          // Recent Projects Section - Better section definition
          _buildRecentProjectsSection(context, sortedProjects),
          SizedBox(height: 40.h), // Consistent major section spacing
          
          // Team Updates Section - Clear separation
          _buildTeamUpdatesSection(context, ref),
          SizedBox(height: 24.h), // Bottom padding
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

  Widget _buildProjectSlider(BuildContext context, List<Project> projects) {
    return NeumorphicFlatContainer(
      height: 260.h,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      borderRadius: BorderRadius.circular(20.r),
      color: CustomNeumorphicTheme.baseColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Container(
            width: MediaQuery.of(context).size.width - 80.w, // Full width minus container padding
            margin: EdgeInsets.only(
              right: index < projects.length - 1 ? 16.w : 0, // Only right margin between cards
              top: 8.h,
              bottom: 8.h,
            ),
            child: _buildHorizontalProjectCard(context, project, index == 0),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalProjectCard(BuildContext context, Project project, bool isMostRecent) {
    final completedPhases = project.phases.where((phase) => phase.status == PhaseStatus.completed).length;
    final totalPhases = project.phases.length;
    final progress = totalPhases > 0 ? completedPhases / totalPhases : 0.0;
    
    return NeumorphicCard(
      onTap: () => context.go('/tasks/${project.id}'),
      padding: EdgeInsets.all(16.w),
      child: SizedBox(
        height: 200.h, // Fixed height to prevent overflow
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status - Fixed height
            SizedBox(
              height: isMostRecent ? 50.h : 28.h, // Accommodate "Most Recent" badge
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isMostRecent) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h), // Reduced padding
                            decoration: BoxDecoration(
                              color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Most Recent',
                              style: TextStyle(
                                fontSize: 9.sp, // Slightly smaller
                                fontWeight: FontWeight.w600,
                                color: CustomNeumorphicTheme.primaryPurple,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h), // Reduced spacing
                        ],
                        Expanded(
                          child: Text(
                            project.title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: CustomNeumorphicTheme.darkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: project.status),
                ],
              ),
            ),
            
            SizedBox(height: 6.h), // Reduced spacing
            
            // Description - Fixed height
            SizedBox(
              height: 32.h, // Fixed height for 2 lines
              child: Text(
                project.description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // Progress Section - Flexible with constrained content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress Row - Simplified layout
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: CustomNeumorphicTheme.lightText,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: CustomNeumorphicTheme.lightText.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getProgressColor(progress),
                                ),
                                minHeight: 6.h,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _getProgressColor(progress),
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(), // Push stats to bottom
                  
                  // Stats Row - Fixed at bottom with constrained height
                  SizedBox(
                    height: 20.h, // Fixed height for stats
                    child: Row(
                      children: [
                        Flexible(
                          child: _buildStatItem(
                            icon: Icons.view_module_outlined,
                            label: '${project.phases.length} phases',
                            color: CustomNeumorphicTheme.primaryPurple,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Flexible(
                          child: _buildStatItem(
                            icon: Icons.schedule_outlined,
                            label: _formatDate(project.createdAt),
                            color: CustomNeumorphicTheme.lightText,
                          ),
                        ),
                      ],
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: color,
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return CustomNeumorphicTheme.successGreen;
    if (progress >= 0.5) return CustomNeumorphicTheme.primaryPurple;
    if (progress >= 0.2) return Colors.orange;
    return CustomNeumorphicTheme.errorRed;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
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
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
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
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.task_alt, color: Colors.white, size: 16.sp),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'View Tasks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: CustomNeumorphicTheme.primaryPurple, size: 16.sp),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'Add Task',
                          style: TextStyle(
                            color: CustomNeumorphicTheme.primaryPurple,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
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
            style: Theme.of(context).textTheme.headlineSmall,
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
      margin: EdgeInsets.only(bottom: 20.h), // Increased bottom margin for shadow clearance
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

  Widget _buildUserGreetingSection(BuildContext context, WidgetRef ref) {
    return NeumorphicFlatContainer(
      padding: EdgeInsets.only(left: 4.w, right: 24.w, top: 20.h, bottom: 20.h), // Align left padding with other headings
      borderRadius: BorderRadius.circular(20.r),
      child: Align(
        alignment: Alignment.centerLeft,
        child: _buildUserGreeting(context, ref),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, int totalProjects, int activeProjects, int totalTasks, int openTasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 16.h),
          child: Text(
            'Overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        _buildQuickStats(context, totalProjects, activeProjects, totalTasks, openTasks),
      ],
    );
  }

  Widget _buildRecentProjectsSection(BuildContext context, List<Project> sortedProjects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with proper spacing
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 16.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Projects',
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (sortedProjects.isNotEmpty)
                _buildEnhancedSwipeIndicator(sortedProjects.length),
            ],
          ),
        ),
        // Project Slider with enhanced container
        if (sortedProjects.isNotEmpty) 
          _buildProjectSlider(context, sortedProjects),
      ],
    );
  }

  Widget _buildSwipeIndicator(int projectCount) {
    return NeumorphicContainer(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      borderRadius: BorderRadius.circular(20.r),
      color: CustomNeumorphicTheme.baseColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.swipe,
            size: 12.sp,
            color: CustomNeumorphicTheme.lightText,
          ),
          SizedBox(width: 6.w),
          Text(
            'Swipe',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: CustomNeumorphicTheme.lightText,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '$projectCount',
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: CustomNeumorphicTheme.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSwipeIndicator(int projectCount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated swipe arrows
        TweenAnimationBuilder(
          duration: const Duration(seconds: 2),
          tween: Tween<double>(begin: 0.3, end: 1.0),
          builder: (context, double value, child) {
            return AnimatedOpacity(
              opacity: value,
              duration: const Duration(milliseconds: 500),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_left,
                    size: 14.sp,
                    color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: value * 0.6),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: 14.sp,
                    color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: value * 0.6),
                  ),
                ],
              ),
            );
          },
          onEnd: () {
            // Restart animation after a delay
          },
        ),
        SizedBox(width: 8.w),
        NeumorphicContainer(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          borderRadius: BorderRadius.circular(16.r),
          color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swipe_outlined,
                size: 13.sp,
                color: CustomNeumorphicTheme.primaryPurple,
              ),
              SizedBox(width: 6.w),
              Text(
                projectCount > 1 ? 'Slide' : 'Slideable',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: CustomNeumorphicTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (projectCount > 1) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: CustomNeumorphicTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '$projectCount',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamUpdatesSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h), // Reduced from 20.h to 12.h
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Team Updates',
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              NeumorphicButton(
                onPressed: () {
                  // Navigate to full conversation view
                  // context.push('/team-conversations');
                },
                borderRadius: BorderRadius.circular(10.r), // Slightly smaller radius
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h), // Reduced padding
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 12.sp, // Reduced from 14.sp
                      color: CustomNeumorphicTheme.primaryPurple,
                    ),
                    SizedBox(width: 4.w), // Reduced from 6.w
                    Text(
                      'View All',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith( // Changed to labelSmall
                        color: CustomNeumorphicTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildTeamConversationList(context, ref),
      ],
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
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $userName',
              style: Theme.of(context).textTheme.displaySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, Welcome back',
            style: Theme.of(context).textTheme.displaySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, there',
            style: Theme.of(context).textTheme.displaySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedSummaryTile(BuildContext context, int totalProjects, int activeProjects, int totalTasks, int openTasks) {
    final completedTasks = totalTasks - openTasks;
    final taskCompletionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;
    
    return Row(
      children: [
        // Projects section with neumorphic background
        Expanded(
          flex: 1,
          child: NeumorphicCard(
            padding: EdgeInsets.all(20.w), // Back to original padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Enhanced icon with container but smaller
                NeumorphicContainer(
                  padding: EdgeInsets.all(8.w), // Smaller container
                  borderRadius: BorderRadius.circular(12.r), // Smaller radius
                  color: CustomNeumorphicTheme.primaryPurple,
                  child: Icon(
                    Icons.folder_outlined,
                    size: 20.sp, // Back to smaller icon
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h), // Back to original spacing
                Text(
                  '$activeProjects',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith( // Back to original size
                    color: CustomNeumorphicTheme.primaryPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'of $totalProjects',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith( // Back to smaller text
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
                SizedBox(height: 8.h), // Back to original spacing
                Text(
                  'Active Projects',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith( // Back to original size
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(width: 16.w), // Better spacing between sections
        
        // Tasks section with neumorphic background
        Expanded(
          flex: 1,
          child: NeumorphicCard(
            padding: EdgeInsets.all(20.w), // Back to original padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Enhanced icon with container but smaller
                NeumorphicContainer(
                  padding: EdgeInsets.all(8.w), // Smaller container
                  borderRadius: BorderRadius.circular(12.r), // Smaller radius
                  color: CustomNeumorphicTheme.successGreen,
                  child: Icon(
                    Icons.checklist_outlined,
                    size: 20.sp, // Back to smaller icon
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h), // Back to original spacing
                Text(
                  '$taskCompletionRate%',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith( // Back to original size
                    color: CustomNeumorphicTheme.successGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'completed',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith( // Back to smaller text
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
                SizedBox(height: 8.h), // Back to original spacing
                Text(
                  'Task Progress',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith( // Back to original size
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14.sp,
                          color: AppColors.projectCompleted,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: CustomNeumorphicTheme.lightText,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                  padding: EdgeInsets.only(left: 12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 14.sp,
                            color: AppColors.projectInProgress,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              'In Progress',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: CustomNeumorphicTheme.lightText,
                              ),
                              overflow: TextOverflow.ellipsis,
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
      margin: EdgeInsets.only(bottom: 24.h), // Increased bottom margin for shadow clearance
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
            Wrap(
              spacing: 12.w,
              runSpacing: 4.h,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.task, size: 12.sp, color: CustomNeumorphicTheme.lightText),
                    SizedBox(width: 4.w),
                    Text(
                      '$completedTasks/$projectTasks tasks',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: CustomNeumorphicTheme.lightText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timeline, size: 12.sp, color: CustomNeumorphicTheme.lightText),
                    SizedBox(width: 4.w),
                    Text(
                      '${project.phases.length} phases',
                      style: TextStyle(
                        fontSize: 10.sp,
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


  Widget _buildTeamConversationList(BuildContext context, WidgetRef ref) {
    // Mock conversation data - in real app this would come from a provider
    final recentConversations = [
      {
        'user': 'Sarah Chen',
        'avatar': 'SC',
        'message': 'Updated the design mockups for the login flow. Ready for review!',
        'time': '2 hours ago',
        'project': 'Mobile App Redesign',
        'type': 'update'
      },
      {
        'user': 'Mike Johnson',
        'avatar': 'MJ',
        'message': 'Fixed the authentication bug in the backend API.',
        'time': '4 hours ago',
        'project': 'Backend Infrastructure',
        'type': 'fix'
      },
      {
        'user': 'Emma Wilson',
        'avatar': 'EW',
        'message': 'Can someone help review the new user onboarding flow?',
        'time': '6 hours ago',
        'project': 'User Experience',
        'type': 'question'
      },
    ];

    return Column(
      children: recentConversations.map((conversation) => 
        _buildConversationItem(context, conversation)).toList(),
    );
  }

  Widget _buildConversationItem(BuildContext context, Map<String, String> conversation) {
    Color getTypeColor(String type) {
      switch (type) {
        case 'update':
          return CustomNeumorphicTheme.primaryPurple;
        case 'fix':
          return CustomNeumorphicTheme.successGreen;
        case 'question':
          return Colors.orange;
        default:
          return CustomNeumorphicTheme.lightText;
      }
    }

    IconData getTypeIcon(String type) {
      switch (type) {
        case 'update':
          return Icons.update;
        case 'fix':
          return Icons.build_circle;
        case 'question':
          return Icons.help_outline;
        default:
          return Icons.chat_bubble_outline;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h), // Reduced from 16.h
      child: NeumorphicCard(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h), // Reduced padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smaller, more compact avatar
            NeumorphicContainer(
              width: 32.w, // Reduced from 40.w
              height: 32.w, // Reduced from 40.w
              borderRadius: BorderRadius.circular(16.r), // Adjusted radius
              color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
              child: Center(
                child: Text(
                  conversation['avatar']!,
                  style: TextStyle(
                    fontSize: 12.sp, // Reduced from 14.sp
                    fontWeight: FontWeight.w700,
                    color: CustomNeumorphicTheme.primaryPurple,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w), // Reduced from 12.w
            
            // Content - more compact layout
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Important for height reduction
                children: [
                  // User name, time, and type icon in single row
                  Row(
                    children: [
                      // Type icon first for better visual hierarchy
                      Icon(
                        getTypeIcon(conversation['type']!),
                        size: 12.sp,
                        color: getTypeColor(conversation['type']!),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          conversation['user']!,
                          style: TextStyle(
                            fontSize: 13.sp, // Slightly reduced from 14.sp
                            fontWeight: FontWeight.w600,
                            color: CustomNeumorphicTheme.darkText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        conversation['time']!,
                        style: TextStyle(
                          fontSize: 10.sp, // Reduced from 11.sp
                          color: CustomNeumorphicTheme.lightText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h), // Kept minimal spacing
                  
                  // Message - single line for compactness
                  Text(
                    conversation['message']!,
                    style: TextStyle(
                      fontSize: 12.sp, // Reduced from 13.sp
                      color: CustomNeumorphicTheme.darkText,
                      height: 1.2, // Reduced line height
                    ),
                    maxLines: 1, // Changed from 2 to 1 for compactness
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h), // Reduced from 8.h
                  
                  // Project tag - compact display
                  Text(
                    conversation['project']!,
                    style: TextStyle(
                      fontSize: 10.sp, // Reduced from 11.sp
                      color: getTypeColor(conversation['type']!),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDatabaseDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🗑️ Clear Database'),
          content: const Text(
            'This will permanently delete ALL projects and data from the database.\n\n'
            'This action cannot be undone!\n\n'
            'Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const AlertDialog(
                      content: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Clearing database...'),
                        ],
                      ),
                    ),
                  );
                  
                  // Clear the database
                  await ref.read(projectNotifierProvider.notifier).clearAllData();
                  
                  // Close loading dialog
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Database cleared successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  // Close loading dialog
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error clearing database: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('DELETE ALL'),
            ),
          ],
        );
      },
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