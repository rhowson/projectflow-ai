import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/create-project');
            },
          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create-project');
        },
        child: const Icon(Icons.add),
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              project.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatusChip(status: project.status),
                    const SizedBox(width: 8),
                    Text(
                      '${project.phases.length} phases',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              context.push('/dashboard/${project.id}');
            },
          ),
        );
      },
    );
  }

  Widget _buildProjectDashboard(BuildContext context, Project project) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 768; // Show kanban board only on tablets and desktop
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectOverviewCard(project: project),
          const SizedBox(height: 16),
          ProjectProgressChart(project: project),
          const SizedBox(height: 16),
          // Show Kanban Board only on larger screens
          if (isLargeScreen) ...[
            SizedBox(
              height: 600, // Fixed height for the kanban board
              child: ResponsiveKanbanBoard(project: project),
            ),
            const SizedBox(height: 16),
          ] else ...[
            // Mobile-friendly info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Drag & drop task board is available on larger screens. Manage tasks using the phases below.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Phases list - Always show, primary task view on mobile
          PhasesList(phases: project.phases, projectId: project.id),
        ],
      ),
    );
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