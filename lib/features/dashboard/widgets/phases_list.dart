import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/project_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../task_management/widgets/task_management_dialogs.dart';
import '../../project_creation/providers/project_provider.dart';

class PhasesList extends ConsumerWidget {
  final List<ProjectPhase> phases;
  final String projectId;
  
  const PhasesList({required this.phases, required this.projectId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (phases.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.layers_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No phases yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Phases will appear here once your project is analyzed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.layers,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Project Phases',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Text(
                  '${phases.length} phases',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: phases.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final phase = phases[index];
                return _PhaseItem(
                  phase: phase,
                  phaseNumber: index + 1,
                  projectId: projectId,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseItem extends ConsumerStatefulWidget {
  final ProjectPhase phase;
  final int phaseNumber;
  final String projectId;

  const _PhaseItem({
    required this.phase,
    required this.phaseNumber,
    required this.projectId,
  });

  @override
  ConsumerState<_PhaseItem> createState() => _PhaseItemState();
}

class _PhaseItemState extends ConsumerState<_PhaseItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final completedTasks = widget.phase.tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;
    final totalTasks = widget.phase.tasks.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.phase.status == PhaseStatus.completed 
                            ? AppColors.statusCompleted
                            : _getPhaseStatusColor(widget.phase.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getPhaseStatusColor(widget.phase.status).withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: widget.phase.status == PhaseStatus.completed
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : Text(
                                widget.phaseNumber.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getPhaseStatusColor(widget.phase.status),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.phase.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.phase.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: isExpanded ? null : 2,
                            overflow: isExpanded ? null : TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _PhaseStatusChip(status: widget.phase.status),
                        const SizedBox(height: 4),
                        Text(
                          '$completedTasks/$totalTasks tasks',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => _showAddTaskDialog(),
                      tooltip: 'Add Task',
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getPhaseStatusColor(widget.phase.status),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (isExpanded && widget.phase.tasks.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tasks',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.phase.tasks.map((task) => _TaskItem(
                  task: task,
                  projectId: widget.projectId,
                  phaseId: widget.phase.id,
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showAddTaskDialog() {
    TaskManagementDialogs.showAddTaskDialog(
      context,
      ref,
      widget.projectId,
      widget.phase.id,
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

class _PhaseStatusChip extends StatelessWidget {
  final PhaseStatus status;

  const _PhaseStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case PhaseStatus.notStarted:
        color = AppColors.statusTodo;
        label = 'Not Started';
        break;
      case PhaseStatus.inProgress:
        color = AppColors.statusInProgress;
        label = 'In Progress';
        break;
      case PhaseStatus.completed:
        color = AppColors.statusCompleted;
        label = 'Completed';
        break;
      case PhaseStatus.onHold:
        color = AppColors.statusBlocked;
        label = 'On Hold';
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
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TaskItem extends ConsumerStatefulWidget {
  final Task task;
  final String projectId;
  final String phaseId;

  const _TaskItem({
    required this.task,
    required this.projectId,
    required this.phaseId,
  });

  @override
  ConsumerState<_TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends ConsumerState<_TaskItem> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.task.status == TaskStatus.completed
                  ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.task.status == TaskStatus.completed
                    ? AppColors.statusCompleted.withOpacity(0.3)
                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
      child: Row(
        children: [
          // Completion toggle button
          GestureDetector(
            onTap: () => _toggleTaskCompletion(),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.task.status == TaskStatus.completed
                      ? AppColors.statusCompleted
                      : Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
                color: widget.task.status == TaskStatus.completed
                    ? AppColors.statusCompleted
                    : Colors.transparent,
              ),
              child: widget.task.status == TaskStatus.completed
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Status icon (smaller, supplementary)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getTaskStatusColor(widget.task.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _showEditTaskDialog(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: widget.task.status == TaskStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: widget.task.status == TaskStatus.completed
                          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                          : null,
                    ),
                  ),
                  if (widget.task.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.task.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(
                          widget.task.status == TaskStatus.completed ? 0.4 : 0.6
                        ),
                        decoration: widget.task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (widget.task.estimatedHours > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${widget.task.estimatedHours.toInt()}h estimated',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(
                          widget.task.status == TaskStatus.completed ? 0.4 : 0.6
                        ),
                        decoration: widget.task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _TaskPriorityIndicator(priority: widget.task.priority),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'move',
                child: Row(
                  children: [
                    Icon(Icons.move_to_inbox, size: 16),
                    SizedBox(width: 8),
                    Text('Move to Phase'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleMenuAction(context, value),
          ),
        ],
      ),
          ),
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context) {
    TaskManagementDialogs.showEditTaskDialog(
      context,
      ref,
      widget.projectId,
      widget.phaseId,
      widget.task,
    );
  }

  void _toggleTaskCompletion() {
    // Play animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    // Update state
    ref.read(projectNotifierProvider.notifier).toggleTaskCompletion(
      widget.projectId,
      widget.phaseId,
      widget.task.id,
    );
  }

  void _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'edit':
        _showEditTaskDialog(context);
        break;
      case 'move':
        final newPhaseId = await TaskManagementDialogs.showMoveTaskDialog(
          context,
          ref,
          widget.projectId,
          widget.phaseId,
          widget.task,
        );
        if (newPhaseId != null) {
          ref.read(projectNotifierProvider.notifier).moveTaskToPhase(
            widget.projectId,
            widget.phaseId,
            newPhaseId,
            widget.task.id,
          );
        }
        break;
      case 'delete':
        final shouldDelete = await TaskManagementDialogs.showDeleteTaskDialog(
          context,
          widget.task,
        );
        if (shouldDelete) {
          ref.read(projectNotifierProvider.notifier).deleteTask(
            widget.projectId,
            widget.phaseId,
            widget.task.id,
          );
        }
        break;
    }
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppColors.statusTodo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.review:
        return AppColors.statusReview;
      case TaskStatus.completed:
        return AppColors.statusCompleted;
      case TaskStatus.blocked:
        return AppColors.statusBlocked;
    }
  }
}

class _TaskPriorityIndicator extends StatelessWidget {
  final Priority priority;

  const _TaskPriorityIndicator({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case Priority.low:
        color = AppColors.priorityLow;
        break;
      case Priority.medium:
        color = AppColors.priorityMedium;
        break;
      case Priority.high:
        color = AppColors.priorityHigh;
        break;
      case Priority.urgent:
        color = AppColors.priorityUrgent;
        break;
    }

    return Container(
      width: 4,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}