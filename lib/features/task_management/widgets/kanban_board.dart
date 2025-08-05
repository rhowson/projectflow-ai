import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/project_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../project_creation/providers/project_provider.dart';

class KanbanBoard extends ConsumerStatefulWidget {
  final Project project;
  
  const KanbanBoard({required this.project, super.key});

  @override
  ConsumerState<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends ConsumerState<KanbanBoard> {
  @override
  Widget build(BuildContext context) {
    // Get all tasks from all phases
    final allTasks = widget.project.phases
        .expand((phase) => phase.tasks)
        .toList();

    // Group tasks by status
    final todoTasks = allTasks.where((task) => task.status == TaskStatus.todo).toList();
    final inProgressTasks = allTasks.where((task) => task.status == TaskStatus.inProgress).toList();
    final reviewTasks = allTasks.where((task) => task.status == TaskStatus.review).toList();
    final completedTasks = allTasks.where((task) => task.status == TaskStatus.completed).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Task Board',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Text(
                  '${allTasks.length} tasks',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: KanbanColumn(
                      title: 'To Do',
                      tasks: todoTasks,
                      status: TaskStatus.todo,
                      color: AppColors.statusTodo,
                      onTaskMoved: _moveTask,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KanbanColumn(
                      title: 'In Progress',
                      tasks: inProgressTasks,
                      status: TaskStatus.inProgress,
                      color: AppColors.statusInProgress,
                      onTaskMoved: _moveTask,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KanbanColumn(
                      title: 'Review',
                      tasks: reviewTasks,
                      status: TaskStatus.review,
                      color: AppColors.statusReview,
                      onTaskMoved: _moveTask,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KanbanColumn(
                      title: 'Completed',
                      tasks: completedTasks,
                      status: TaskStatus.completed,
                      color: AppColors.statusCompleted,
                      onTaskMoved: _moveTask,
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

  void _moveTask(Task task, TaskStatus newStatus) {
    // Find the task in the project and update its status
    final updatedPhases = widget.project.phases.map((phase) {
      final updatedTasks = phase.tasks.map((t) {
        if (t.id == task.id) {
          return Task(
            id: t.id,
            title: t.title,
            description: t.description,
            status: newStatus,
            priority: t.priority,
            assignedToId: t.assignedToId,
            createdAt: t.createdAt,
            dueDate: t.dueDate,
            attachmentIds: t.attachmentIds,
            dependencyIds: t.dependencyIds,
            estimatedHours: t.estimatedHours,
            actualHours: t.actualHours,
            comments: t.comments,
          );
        }
        return t;
      }).toList();
      
      return ProjectPhase(
        id: phase.id,
        name: phase.name,
        description: phase.description,
        tasks: updatedTasks,
        status: phase.status,
        startDate: phase.startDate,
        endDate: phase.endDate,
      );
    }).toList();

    final updatedProject = Project(
      id: widget.project.id,
      title: widget.project.title,
      description: widget.project.description,
      status: widget.project.status,
      createdAt: widget.project.createdAt,
      dueDate: widget.project.dueDate,
      ownerId: widget.project.ownerId,
      teamMemberIds: widget.project.teamMemberIds,
      phases: updatedPhases,
      metadata: widget.project.metadata,
    );

    // Update the project in the provider
    ref.read(projectNotifierProvider.notifier).updateProject(updatedProject);
  }
}

class KanbanColumn extends StatefulWidget {
  final String title;
  final List<Task> tasks;
  final TaskStatus status;
  final Color color;
  final Function(Task, TaskStatus) onTaskMoved;

  const KanbanColumn({
    required this.title,
    required this.tasks,
    required this.status,
    required this.color,
    required this.onTaskMoved,
    super.key,
  });

  @override
  State<KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends State<KanbanColumn> {
  bool _isDraggedOver = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDraggedOver 
              ? widget.color.withOpacity(0.5)
              : widget.color.withOpacity(0.2),
          width: _isDraggedOver ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: widget.color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.tasks.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<Task>(
              onWillAcceptWithDetails: (details) {
                setState(() {
                  _isDraggedOver = true;
                });
                return details.data.status != widget.status;
              },
              onLeave: (data) {
                setState(() {
                  _isDraggedOver = false;
                });
              },
              onAcceptWithDetails: (details) {
                setState(() {
                  _isDraggedOver = false;
                });
                widget.onTaskMoved(details.data, widget.status);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  child: widget.tasks.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 32,
                                  color: widget.color.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No tasks',
                                  style: TextStyle(
                                    color: widget.color.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: widget.tasks.length,
                          itemBuilder: (context, index) {
                            final task = widget.tasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TaskCard(
                                task: task,
                                color: widget.color,
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final Color color;

  const TaskCard({
    required this.task,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<Task>(
      data: task,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildTaskCard(context),
      ),
      child: _buildTaskCard(context),
    );
  }

  Widget _buildTaskCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.description,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (task.estimatedHours > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '${task.estimatedHours.toInt()}h',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return AppColors.priorityLow;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.high:
        return AppColors.priorityHigh;
      case Priority.urgent:
        return AppColors.priorityUrgent;
    }
  }
}