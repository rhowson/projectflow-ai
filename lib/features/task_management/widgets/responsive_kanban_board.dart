import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/project_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../project_creation/providers/project_provider.dart';

class ResponsiveKanbanBoard extends ConsumerStatefulWidget {
  final Project project;
  
  const ResponsiveKanbanBoard({required this.project, super.key});

  @override
  ConsumerState<ResponsiveKanbanBoard> createState() => _ResponsiveKanbanBoardState();
}

class _ResponsiveKanbanBoardState extends ConsumerState<ResponsiveKanbanBoard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isMobile = screenWidth < 600;
    
    // Get all tasks from all phases
    final allTasks = widget.project.phases
        .expand((phase) => phase.tasks)
        .toList();

    // Group tasks by status
    final taskGroups = {
      TaskStatus.todo: allTasks.where((task) => task.status == TaskStatus.todo).toList(),
      TaskStatus.inProgress: allTasks.where((task) => task.status == TaskStatus.inProgress).toList(),
      TaskStatus.review: allTasks.where((task) => task.status == TaskStatus.review).toList(),
      TaskStatus.completed: allTasks.where((task) => task.status == TaskStatus.completed).toList(),
    };

    return Card(
      margin: EdgeInsets.all(isMobile ? 8.0 : 16.0),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).colorScheme.primary,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  'Task Board',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: isMobile ? 18 : 20,
                  ),
                ),
                const Spacer(),
                Text(
                  '${allTasks.length} tasks',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Mobile: Page indicator for swipeable columns
          if (isMobile) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: _currentPage == index ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            _buildMobileStatusTabs(),
          ],
          
          // Content
          Expanded(
            child: isMobile 
                ? _buildMobileKanban(taskGroups)
                : _buildDesktopKanban(taskGroups, isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatusTabs() {
    final statuses = [
      {'status': TaskStatus.todo, 'title': 'To Do', 'color': AppColors.statusTodo},
      {'status': TaskStatus.inProgress, 'title': 'In Progress', 'color': AppColors.statusInProgress},
      {'status': TaskStatus.review, 'title': 'Review', 'color': AppColors.statusReview},
      {'status': TaskStatus.completed, 'title': 'Completed', 'color': AppColors.statusCompleted},
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: statuses.asMap().entries.map((entry) {
          final index = entry.key;
          final statusData = entry.value;
          final isActive = _currentPage == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isActive 
                      ? (statusData['color'] as Color).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isActive 
                      ? Border.all(color: statusData['color'] as Color, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    statusData['title'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive 
                          ? statusData['color'] as Color
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileKanban(Map<TaskStatus, List<Task>> taskGroups) {
    return PageView(
      controller: _pageController,
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      children: [
        _buildMobileColumn('To Do', taskGroups[TaskStatus.todo]!, TaskStatus.todo, AppColors.statusTodo),
        _buildMobileColumn('In Progress', taskGroups[TaskStatus.inProgress]!, TaskStatus.inProgress, AppColors.statusInProgress),
        _buildMobileColumn('Review', taskGroups[TaskStatus.review]!, TaskStatus.review, AppColors.statusReview),
        _buildMobileColumn('Completed', taskGroups[TaskStatus.completed]!, TaskStatus.completed, AppColors.statusCompleted),
      ],
    );
  }

  Widget _buildMobileColumn(String title, List<Task> tasks, TaskStatus status, Color color) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: color.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No tasks',
                          style: TextStyle(
                            color: color.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: tasks.length,
                    onReorder: (oldIndex, newIndex) {
                      // Handle reordering within the same column
                      if (newIndex > oldIndex) newIndex--;
                      // Implementation for reordering
                    },
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        key: ValueKey(task.id),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: MobileTaskCard(
                          task: task,
                          color: color,
                          onStatusChanged: (newStatus) => _moveTask(task, newStatus),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopKanban(Map<TaskStatus, List<Task>> taskGroups, bool isTablet) {
    final columnSpacing = isTablet ? 12.0 : 16.0;
    
    return Padding(
      padding: EdgeInsets.all(columnSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ResponsiveKanbanColumn(
              title: 'To Do',
              tasks: taskGroups[TaskStatus.todo]!,
              status: TaskStatus.todo,
              color: AppColors.statusTodo,
              onTaskMoved: _moveTask,
              isTablet: isTablet,
            ),
          ),
          SizedBox(width: columnSpacing),
          Expanded(
            child: ResponsiveKanbanColumn(
              title: 'In Progress',
              tasks: taskGroups[TaskStatus.inProgress]!,
              status: TaskStatus.inProgress,
              color: AppColors.statusInProgress,
              onTaskMoved: _moveTask,
              isTablet: isTablet,
            ),
          ),
          SizedBox(width: columnSpacing),
          Expanded(
            child: ResponsiveKanbanColumn(
              title: 'Review',
              tasks: taskGroups[TaskStatus.review]!,
              status: TaskStatus.review,
              color: AppColors.statusReview,
              onTaskMoved: _moveTask,
              isTablet: isTablet,
            ),
          ),
          SizedBox(width: columnSpacing),
          Expanded(
            child: ResponsiveKanbanColumn(
              title: 'Completed',
              tasks: taskGroups[TaskStatus.completed]!,
              status: TaskStatus.completed,
              color: AppColors.statusCompleted,
              onTaskMoved: _moveTask,
              isTablet: isTablet,
            ),
          ),
        ],
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
      teamMemberIds: widget.project.teamMemberIds,
      phases: updatedPhases,
      metadata: widget.project.metadata,
    );

    // Update the project in the provider
    ref.read(projectNotifierProvider.notifier).updateProject(updatedProject);
  }
}

class ResponsiveKanbanColumn extends StatefulWidget {
  final String title;
  final List<Task> tasks;
  final TaskStatus status;
  final Color color;
  final Function(Task, TaskStatus) onTaskMoved;
  final bool isTablet;

  const ResponsiveKanbanColumn({
    required this.title,
    required this.tasks,
    required this.status,
    required this.color,
    required this.onTaskMoved,
    required this.isTablet,
    super.key,
  });

  @override
  State<ResponsiveKanbanColumn> createState() => _ResponsiveKanbanColumnState();
}

class _ResponsiveKanbanColumnState extends State<ResponsiveKanbanColumn> {
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
            padding: EdgeInsets.all(widget.isTablet ? 10 : 12),
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
                    fontSize: widget.isTablet ? 14 : 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.tasks.length}',
                    style: TextStyle(
                      fontSize: widget.isTablet ? 10 : 12,
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
                            padding: EdgeInsets.all(widget.isTablet ? 16 : 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: widget.isTablet ? 24 : 32,
                                  color: widget.color.withOpacity(0.5),
                                ),
                                SizedBox(height: widget.isTablet ? 4 : 8),
                                Text(
                                  'No tasks',
                                  style: TextStyle(
                                    color: widget.color.withOpacity(0.7),
                                    fontSize: widget.isTablet ? 10 : 12,
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
                              child: ResponsiveTaskCard(
                                task: task,
                                color: widget.color,
                                isTablet: widget.isTablet,
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

class ResponsiveTaskCard extends StatelessWidget {
  final Task task;
  final Color color;
  final bool isTablet;

  const ResponsiveTaskCard({
    required this.task,
    required this.color,
    required this.isTablet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = isTablet ? 180.0 : 200.0;
    
    return Draggable<Task>(
      data: task,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: cardWidth,
          padding: EdgeInsets.all(isTablet ? 10 : 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 2),
          ),
          child: _buildCardContent(context),
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
      padding: EdgeInsets.all(isTablet ? 10 : 12),
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
      child: _buildCardContent(context),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 12 : 14,
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
          SizedBox(height: isTablet ? 6 : 8),
          Text(
            task.description,
            style: TextStyle(
              fontSize: isTablet ? 10 : 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (task.estimatedHours > 0) ...[
          SizedBox(height: isTablet ? 6 : 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: isTablet ? 12 : 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                '${task.estimatedHours.toInt()}h',
                style: TextStyle(
                  fontSize: isTablet ? 9 : 11,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ],
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

class MobileTaskCard extends StatelessWidget {
  final Task task;
  final Color color;
  final Function(TaskStatus) onStatusChanged;

  const MobileTaskCard({
    required this.task,
    required this.color,
    required this.onStatusChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showStatusChangeDialog(context),
      child: Container(
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
                GestureDetector(
                  onTap: () => _showStatusChangeDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.more_horiz,
                      size: 16,
                      color: color,
                    ),
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
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                if (task.estimatedHours > 0) ...[
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
                const Spacer(),
                Text(
                  'Long press to move',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusChangeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Move Task',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              task.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            _buildStatusOption(context, 'To Do', TaskStatus.todo, AppColors.statusTodo),
            _buildStatusOption(context, 'In Progress', TaskStatus.inProgress, AppColors.statusInProgress),
            _buildStatusOption(context, 'Review', TaskStatus.review, AppColors.statusReview),
            _buildStatusOption(context, 'Completed', TaskStatus.completed, AppColors.statusCompleted),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(BuildContext context, String title, TaskStatus status, Color color) {
    final isCurrentStatus = task.status == status;
    
    return ListTile(
      leading: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color.withOpacity(isCurrentStatus ? 1.0 : 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isCurrentStatus ? FontWeight.w600 : FontWeight.normal,
          color: isCurrentStatus ? color : null,
        ),
      ),
      trailing: isCurrentStatus ? const Icon(Icons.check) : null,
      onTap: isCurrentStatus ? null : () {
        onStatusChanged(status);
        Navigator.pop(context);
      },
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