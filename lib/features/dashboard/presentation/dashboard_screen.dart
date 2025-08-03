import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../core/models/project_model.dart';
import '../../../core/widgets/database_status_widget.dart';
import '../../../shared/theme/app_colors.dart';
import '../../project_creation/providers/project_provider.dart';
import '../widgets/project_overview_card.dart';
import '../widgets/project_progress_chart.dart';
import '../widgets/phases_list.dart';
import '../../task_management/widgets/responsive_kanban_board.dart';

class DashboardScreen extends ConsumerWidget {
  final String? projectId;
  
  const DashboardScreen({super.key, this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsState = ref.watch(projectNotifierProvider);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'ProjectFlow AI',
        automaticallyImplyLeading: false, // No back button on dashboard (root page)
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showProjectMenu(context),
          ),
        ],
      ),
      body: projectsState.when(
        data: (projects) {
          if (projects.isEmpty) {
            return _buildEmptyState(context);
          }
          
          if (projectId != null) {
            final project = projects.firstWhere(
              (p) => p.id == projectId,
              orElse: () => projects.first,
            );
            return _buildProjectDashboard(context, project);
          }
          
          return _buildProjectsList(context, projects);
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
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(projectNotifierProvider);
                },
                child: const Text('Retry'),
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
            ElevatedButton.icon(
              onPressed: () {
                context.push('/create-project');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Project'),
            ),
            const SizedBox(height: 24),
            // Database status widget for testing
            const DatabaseStatusWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList(BuildContext context, List<Project> projects) {
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
          // Quick Stats Cards
          _buildQuickStats(context, totalProjects, activeProjects, totalTasks, openTasks),
          SizedBox(height: 24.h),
          
          // Recent Projects Header
          Text(
            'Recent Projects',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          
          // Projects List - Simplified
          ...projects.take(5).map((project) => _buildProjectCard(context, project)),
          
          if (projects.length > 5) ...[
            SizedBox(height: 16.h),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to full projects list
                },
                child: Text('View All Projects (${projects.length})'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectDashboard(BuildContext context, Project project) {
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
          
          // Quick Stats for this project
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Tasks',
                  '$completedTasks/$projectTasks',
                  'Completed',
                  Icons.check_circle,
                  AppColors.projectCompleted,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  'In Progress',
                  '$inProgressTasks',
                  'Active Tasks',
                  Icons.refresh,
                  AppColors.projectInProgress,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/tasks?project=${project.id}'),
                  icon: const Icon(Icons.task_alt),
                  label: const Text('View Tasks'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/create-task?project=${project.id}'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
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
      child: Card(
        child: InkWell(
          onTap: () => context.push('/tasks?project=$projectId&phase=${phase.id}'),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        phase.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                if (phase.description.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    phase.description,
                    style: Theme.of(context).textTheme.bodySmall,
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(progress),
                            ),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getProgressColor(progress),
                          ),
                        ),
                        Text(
                          '$completedTasks/$phaseTasks tasks',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, int totalProjects, int activeProjects, int totalTasks, int openTasks) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Projects',
            '$activeProjects/$totalProjects',
            'Active',
            Icons.dashboard,
            AppColors.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            context,
            'Open Tasks',
            '$openTasks',
            totalTasks > 0 ? '${((totalTasks - openTasks) / totalTasks * 100).round()}% Done' : 'No tasks',
            Icons.task_alt,
            AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
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
      margin: EdgeInsets.only(bottom: 12.h),
      child: Card(
        child: InkWell(
          onTap: () => context.push('/dashboard/${project.id}'),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _StatusChip(status: project.status),
                  ],
                ),
                SizedBox(height: 8.h),
                if (project.description.isNotEmpty) ...[
                  Text(
                    project.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(progress),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getProgressColor(progress),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.task, size: 14.sp, color: AppColors.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      '$completedTasks/$projectTasks tasks',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(width: 16.w),
                    Icon(Icons.timeline, size: 14.sp, color: AppColors.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      '${project.phases.length} phases',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppColors.projectCompleted;
    if (progress >= 0.5) return AppColors.projectInProgress;
    return AppColors.projectPlanning;
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
        color = AppColors.projectPlanning;
        label = 'Planning';
        break;
      case ProjectStatus.inProgress:
        color = AppColors.projectInProgress;
        label = 'In Progress';
        break;
      case ProjectStatus.completed:
        color = AppColors.projectCompleted;
        label = 'Completed';
        break;
      case ProjectStatus.onHold:
        color = AppColors.projectOnHold;
        label = 'On Hold';
        break;
      case ProjectStatus.cancelled:
        color = AppColors.projectCancelled;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}