import 'package:flutter/material.dart';
import '../../../core/models/project_model.dart';
import '../../../shared/theme/app_colors.dart';

class ProjectProgressChart extends StatelessWidget {
  final Project project;
  
  const ProjectProgressChart({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    final stats = _calculateProjectStats();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Project Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Overall Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${(stats.overallProgress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: stats.overallProgress,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Task Status Breakdown
            Text(
              'Task Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _TaskStatusItem(
                    label: 'To Do',
                    count: stats.todoTasks,
                    color: AppColors.statusTodo,
                  ),
                ),
                Expanded(
                  child: _TaskStatusItem(
                    label: 'In Progress',
                    count: stats.inProgressTasks,
                    color: AppColors.statusInProgress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TaskStatusItem(
                    label: 'Review',
                    count: stats.reviewTasks,
                    color: AppColors.statusReview,
                  ),
                ),
                Expanded(
                  child: _TaskStatusItem(
                    label: 'Completed',
                    count: stats.completedTasks,
                    color: AppColors.statusCompleted,
                  ),
                ),
              ],
            ),
            
            if (stats.blockedTasks > 0) ...[
              const SizedBox(height: 8),
              _TaskStatusItem(
                label: 'Blocked',
                count: stats.blockedTasks,
                color: AppColors.statusBlocked,
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Phase Progress
            if (project.phases.isNotEmpty) ...[
              Text(
                'Phase Progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...project.phases.map((phase) => _PhaseProgressItem(phase: phase)),
            ],
          ],
        ),
      ),
    );
  }

  ProjectStats _calculateProjectStats() {
    int totalTasks = 0;
    int todoTasks = 0;
    int inProgressTasks = 0;
    int reviewTasks = 0;
    int completedTasks = 0;
    int blockedTasks = 0;

    for (final phase in project.phases) {
      totalTasks += phase.tasks.length;
      for (final task in phase.tasks) {
        switch (task.status) {
          case TaskStatus.todo:
            todoTasks++;
            break;
          case TaskStatus.inProgress:
            inProgressTasks++;
            break;
          case TaskStatus.review:
            reviewTasks++;
            break;
          case TaskStatus.completed:
            completedTasks++;
            break;
          case TaskStatus.blocked:
            blockedTasks++;
            break;
        }
      }
    }

    final overallProgress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return ProjectStats(
      totalTasks: totalTasks,
      todoTasks: todoTasks,
      inProgressTasks: inProgressTasks,
      reviewTasks: reviewTasks,
      completedTasks: completedTasks,
      blockedTasks: blockedTasks,
      overallProgress: overallProgress,
    );
  }
}

class _TaskStatusItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _TaskStatusItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PhaseProgressItem extends StatelessWidget {
  final ProjectPhase phase;

  const _PhaseProgressItem({required this.phase});

  @override
  Widget build(BuildContext context) {
    final completedTasks = phase.tasks.where((task) => task.status == TaskStatus.completed).length;
    final totalTasks = phase.tasks.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  phase.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$completedTasks/$totalTasks',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getPhaseStatusColor(phase.status),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPhaseStatusColor(PhaseStatus status) {
    switch (status) {
      case PhaseStatus.notStarted:
        return AppColors.statusTodo;
      case PhaseStatus.inProgress:
        return AppColors.statusInProgress;
      case PhaseStatus.completed:
        return AppColors.statusCompleted;
      case PhaseStatus.onHold:
        return AppColors.statusBlocked;
    }
  }
}

class ProjectStats {
  final int totalTasks;
  final int todoTasks;
  final int inProgressTasks;
  final int reviewTasks;
  final int completedTasks;
  final int blockedTasks;
  final double overallProgress;

  const ProjectStats({
    required this.totalTasks,
    required this.todoTasks,
    required this.inProgressTasks,
    required this.reviewTasks,
    required this.completedTasks,
    required this.blockedTasks,
    required this.overallProgress,
  });
}