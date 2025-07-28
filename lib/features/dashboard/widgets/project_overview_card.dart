import 'package:flutter/material.dart';
import '../../../core/models/project_model.dart';
import '../../../shared/theme/app_colors.dart';
import 'package:intl/intl.dart';

class ProjectOverviewCard extends StatelessWidget {
  final Project project;
  
  const ProjectOverviewCard({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                _StatusChip(status: project.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              project.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.group,
                  label: '${project.teamMemberIds.length} members',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.schedule,
                  label: project.dueDate != null 
                      ? DateFormat('MMM dd, yyyy').format(project.dueDate!)
                      : 'No due date',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.category,
                  label: _getProjectTypeLabel(project.metadata.type),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Phases',
                    value: project.phases.length.toString(),
                    icon: Icons.layers,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    title: 'Total Tasks',
                    value: _getTotalTasks().toString(),
                    icon: Icons.task,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    title: 'Completed',
                    value: _getCompletedTasks().toString(),
                    icon: Icons.check_circle,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    title: 'Est. Hours',
                    value: project.metadata.estimatedHours.toInt().toString(),
                    icon: Icons.timer,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalTasks() {
    return project.phases.fold(0, (total, phase) => total + phase.tasks.length);
  }

  int _getCompletedTasks() {
    return project.phases.fold(0, (total, phase) {
      return total + phase.tasks.where((task) => task.status == TaskStatus.completed).length;
    });
  }

  String _getProjectTypeLabel(ProjectType type) {
    switch (type) {
      case ProjectType.web:
        return 'Web';
      case ProjectType.mobile:
        return 'Mobile';
      case ProjectType.desktop:
        return 'Desktop';
      case ProjectType.backend:
        return 'Backend';
      case ProjectType.fullStack:
        return 'Full Stack';
      case ProjectType.other:
        return 'Other';
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}