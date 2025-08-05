import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/project_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/widgets/task_assignment_dialog.dart';
import '../../project_creation/providers/project_provider.dart';

class ResponsiveKanbanBoard extends ConsumerStatefulWidget {
  final Project project;
  final List<Task>? filteredTasks;
  
  const ResponsiveKanbanBoard({required this.project, this.filteredTasks, super.key});

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
    
    // Use filtered tasks if provided, otherwise get all tasks from all phases
    final allTasks = widget.filteredTasks ?? widget.project.phases
        .expand((phase) => phase.tasks)
        .toList();

    // Group tasks by status
    final taskGroups = {
      TaskStatus.todo: allTasks.where((task) => task.status == TaskStatus.todo).toList(),
      TaskStatus.inProgress: allTasks.where((task) => task.status == TaskStatus.inProgress).toList(),
      TaskStatus.review: allTasks.where((task) => task.status == TaskStatus.review).toList(),
      TaskStatus.completed: allTasks.where((task) => task.status == TaskStatus.completed).toList(),
    };

    return Container(
      decoration: BoxDecoration(
        color: CustomNeumorphicTheme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          // Single clean shadow for the main container
          BoxShadow(
            color: CustomNeumorphicTheme.bottomEdgeShadow.withOpacity(0.4),
            offset: const Offset(2, 3),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Mobile: Page indicator for swipeable columns
          if (isMobile) ...[
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    width: _currentPage == index ? 16.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _currentPage == index 
                          ? CustomNeumorphicTheme.primaryPurple
                          : CustomNeumorphicTheme.lightText.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4.r),
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
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isActive ? statusData['color'] as Color : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isActive ? Colors.transparent : (statusData['color'] as Color).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    statusData['title'] as String,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isActive 
                          ? Colors.white
                          : CustomNeumorphicTheme.darkText,
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
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: CustomNeumorphicTheme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: CustomNeumorphicTheme.bottomEdgeShadow.withOpacity(0.3),
            offset: const Offset(2, 3),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: CustomNeumorphicTheme.baseColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                // Simplified indicator - just colored bar
                Container(
                  width: 4.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: CustomNeumorphicTheme.darkText,
                    fontSize: 16.sp,
                  ),
                ),
                const Spacer(),
                // Simplified task count - just colored background
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
                          project: widget.project,
                          color: color,
                          onStatusChanged: (newStatus) => _moveTask(task, newStatus),
                          onPhaseChanged: (newPhaseId) => _moveTaskToPhase(task, newPhaseId),
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
              project: widget.project,
              status: TaskStatus.todo,
              color: AppColors.statusTodo,
              onTaskMoved: _moveTask,
              onTaskPhaseChanged: _moveTaskToPhase,
              isTablet: isTablet,
            ),
          ),
          SizedBox(width: columnSpacing),
          Expanded(
            child: ResponsiveKanbanColumn(
              title: 'In Progress',
              tasks: taskGroups[TaskStatus.inProgress]!,
              project: widget.project,
              status: TaskStatus.inProgress,
              color: AppColors.statusInProgress,
              onTaskMoved: _moveTask,
              onTaskPhaseChanged: _moveTaskToPhase,
              isTablet: isTablet,
            ),
          ),
          SizedBox(width: columnSpacing),
          Expanded(
            child: ResponsiveKanbanColumn(
              title: 'Review',
              tasks: taskGroups[TaskStatus.review]!,
              project: widget.project,
              status: TaskStatus.review,
              color: AppColors.statusReview,
              onTaskMoved: _moveTask,
              onTaskPhaseChanged: _moveTaskToPhase,
              isTablet: isTablet,
            ),
          ),
          SizedBox(width: columnSpacing),
          Expanded(
            child: ResponsiveKanbanColumn(
              title: 'Completed',
              tasks: taskGroups[TaskStatus.completed]!,
              project: widget.project,
              status: TaskStatus.completed,
              color: AppColors.statusCompleted,
              onTaskMoved: _moveTask,
              onTaskPhaseChanged: _moveTaskToPhase,
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

    final updatedProject = widget.project.copyWith(
      phases: updatedPhases,
    );

    // Update the project in the provider
    ref.read(projectNotifierProvider.notifier).updateProject(updatedProject);
  }

  void _moveTaskToPhase(Task task, String newPhaseId) {
    // Find the task in its current phase and move it to the new phase
    List<ProjectPhase> updatedPhases = [];
    
    for (final phase in widget.project.phases) {
      if (phase.tasks.any((t) => t.id == task.id)) {
        // Remove task from current phase
        final updatedTasks = phase.tasks.where((t) => t.id != task.id).toList();
        updatedPhases.add(ProjectPhase(
          id: phase.id,
          name: phase.name,
          description: phase.description,
          tasks: updatedTasks,
          status: phase.status,
          startDate: phase.startDate,
          endDate: phase.endDate,
        ));
      } else if (phase.id == newPhaseId) {
        // Add task to new phase
        final updatedTasks = [...phase.tasks, task];
        updatedPhases.add(ProjectPhase(
          id: phase.id,
          name: phase.name,
          description: phase.description,
          tasks: updatedTasks,
          status: phase.status,
          startDate: phase.startDate,
          endDate: phase.endDate,
        ));
      } else {
        // Keep phase unchanged
        updatedPhases.add(phase);
      }
    }

    final updatedProject = widget.project.copyWith(
      phases: updatedPhases,
    );

    // Update the project in the provider
    ref.read(projectNotifierProvider.notifier).updateProject(updatedProject);
  }
}

class ResponsiveKanbanColumn extends StatefulWidget {
  final String title;
  final List<Task> tasks;
  final Project project;
  final TaskStatus status;
  final Color color;
  final Function(Task, TaskStatus) onTaskMoved;
  final Function(Task, String) onTaskPhaseChanged;
  final bool isTablet;

  const ResponsiveKanbanColumn({
    required this.title,
    required this.tasks,
    required this.project,
    required this.status,
    required this.color,
    required this.onTaskMoved,
    required this.onTaskPhaseChanged,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: CustomNeumorphicTheme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: _isDraggedOver 
            ? Border.all(color: widget.color, width: 2.w)
            : null,
        boxShadow: [
          BoxShadow(
            color: CustomNeumorphicTheme.bottomEdgeShadow.withOpacity(0.3),
            offset: const Offset(2, 3),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(widget.isTablet ? 10.w : 12.w),
            decoration: BoxDecoration(
              color: CustomNeumorphicTheme.baseColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                // Simplified indicator - just colored bar
                Container(
                  width: 4.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: CustomNeumorphicTheme.darkText,
                    fontSize: widget.isTablet ? 14.sp : 16.sp,
                  ),
                ),
                const Spacer(),
                // Simplified task count - just colored background
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.tasks.length}',
                    style: TextStyle(
                      fontSize: widget.isTablet ? 10.sp : 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
                                project: widget.project,
                                color: widget.color,
                                isTablet: widget.isTablet,
                                onPhaseChanged: (newPhaseId) => widget.onTaskPhaseChanged(task, newPhaseId),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ), // Column
    ); // AnimatedContainer
  }
}

class ResponsiveTaskCard extends StatelessWidget {
  final Task task;
  final Project project;
  final Color color;
  final bool isTablet;
  final Function(String) onPhaseChanged;

  const ResponsiveTaskCard({
    required this.task,
    required this.project,
    required this.color,
    required this.isTablet,
    required this.onPhaseChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = isTablet ? 180.0 : 200.0;
    
    return Draggable<Task>(
      data: task,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: cardWidth,
          child: NeumorphicCard(
            padding: EdgeInsets.all(isTablet ? 10.w : 12.w),
            child: _buildCardContent(context),
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
    return GestureDetector(
      onDoubleTap: () => _showTaskOptionsDialog(context),
      child: NeumorphicCard(
        padding: EdgeInsets.all(isTablet ? 10.w : 12.w),
        child: _buildCardContent(context),
      ),
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
                  fontSize: isTablet ? 12.sp : 14.sp,
                  color: CustomNeumorphicTheme.darkText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 4.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        if (task.description.isNotEmpty) ...[
          SizedBox(height: isTablet ? 6.h : 8.h),
          Text(
            task.description,
            style: TextStyle(
              fontSize: isTablet ? 10.sp : 12.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (task.estimatedHours > 0) ...[
          SizedBox(height: isTablet ? 6.h : 8.h),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: isTablet ? 12.sp : 14.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
              SizedBox(width: 4.w),
              Text(
                '${task.estimatedHours.toInt()}h',
                style: TextStyle(
                  fontSize: isTablet ? 9.sp : 11.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ),
              // Assignment indicator
              if (task.assignedToId != null) ...[
                SizedBox(width: 8.w),
                Icon(
                  Icons.person,
                  size: isTablet ? 12.sp : 14.sp,
                  color: CustomNeumorphicTheme.primaryPurple,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Assigned',
                  style: TextStyle(
                    fontSize: isTablet ? 9.sp : 11.sp,
                    color: CustomNeumorphicTheme.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  void _showTaskOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: CustomNeumorphicTheme.baseColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: CustomNeumorphicTheme.lightText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            
            Text(
              'Task Options',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: CustomNeumorphicTheme.darkText,
              ),
            ),
            SizedBox(height: 8.h),
            
            // Task info
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: CustomNeumorphicTheme.cardColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.task_alt,
                    color: CustomNeumorphicTheme.primaryPurple,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Options
            _buildOptionItem(
              context,
              icon: Icons.person_add,
              title: 'Assign Task',
              subtitle: task.assignedToId != null 
                  ? 'Currently assigned' 
                  : 'Not assigned',
              onTap: () {
                Navigator.pop(context);
                _showAssignmentDialog(context);
              },
            ),
            
            SizedBox(height: 12.h),
            
            _buildOptionItem(
              context,
              icon: Icons.folder_open,
              title: 'Move to Phase',
              subtitle: 'Change task phase',
              onTap: () {
                Navigator.pop(context);
                _showPhaseDialog(context);
              },
            ),
            
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: CustomNeumorphicTheme.cardColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: CustomNeumorphicTheme.primaryPurple,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CustomNeumorphicTheme.lightText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: CustomNeumorphicTheme.lightText,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignmentDialog(BuildContext context) {
    // Find the current phase for this task
    String? currentPhaseId;
    for (final phase in project.phases) {
      if (phase.tasks.any((t) => t.id == task.id)) {
        currentPhaseId = phase.id;
        break;
      }
    }
    
    if (currentPhaseId != null) {
      showDialog(
        context: context,
        builder: (context) => TaskAssignmentDialog(
          projectId: project.id,
          phaseId: currentPhaseId!,
          task: task,
        ),
      );
    }
  }

  void _showPhaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CustomNeumorphicTheme.baseColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Move Task',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Text(
                'Move to Phase:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Constrain height and make scrollable
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: project.phases.map((phase) {
                      // Check if task is currently in this phase
                      final isCurrentPhase = phase.tasks.any((t) => t.id == task.id);
                      
                      return ListTile(
                        leading: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: CustomNeumorphicTheme.primaryPurple.withOpacity(
                              isCurrentPhase ? 1.0 : 0.3
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        title: Text(
                          phase.name,
                          style: TextStyle(
                            fontWeight: isCurrentPhase ? FontWeight.w600 : FontWeight.normal,
                            color: isCurrentPhase ? CustomNeumorphicTheme.primaryPurple : null,
                          ),
                        ),
                        subtitle: Text('${phase.tasks.length} tasks'),
                        trailing: isCurrentPhase ? const Icon(Icons.check) : null,
                        onTap: isCurrentPhase ? null : () {
                          onPhaseChanged(phase.id);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
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

class MobileTaskCard extends StatelessWidget {
  final Task task;
  final Project project;
  final Color color;
  final Function(TaskStatus) onStatusChanged;
  final Function(String) onPhaseChanged;

  const MobileTaskCard({
    required this.task,
    required this.project,
    required this.color,
    required this.onStatusChanged,
    required this.onPhaseChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showStatusChangeDialog(context),
      child: NeumorphicCard(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showStatusChangeDialog(context),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.more_horiz,
                      size: 16.sp,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 8.h),
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 8.w),
                if (task.estimatedHours > 0) ...[
                  Icon(
                    Icons.schedule,
                    size: 14.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${task.estimatedHours.toInt()}h',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: CustomNeumorphicTheme.lightText,
                    ),
                  ),
                ],
                // Assignment indicator
                if (task.assignedToId != null) ...[
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.person,
                    size: 14.sp,
                    color: CustomNeumorphicTheme.primaryPurple,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Assigned',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: CustomNeumorphicTheme.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  'Long press to move',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: CustomNeumorphicTheme.subtleText,
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
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
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Status:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusOption(context, 'To Do', TaskStatus.todo, AppColors.statusTodo),
                      _buildStatusOption(context, 'In Progress', TaskStatus.inProgress, AppColors.statusInProgress),
                      _buildStatusOption(context, 'Review', TaskStatus.review, AppColors.statusReview),
                      _buildStatusOption(context, 'Completed', TaskStatus.completed, AppColors.statusCompleted),
                      const SizedBox(height: 24),
                      Text(
                        'Move to Phase:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...project.phases.map((phase) => _buildPhaseOption(context, phase)),
                      const SizedBox(height: 16), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildPhaseOption(BuildContext context, ProjectPhase phase) {
    // Check if task is currently in this phase
    final isCurrentPhase = phase.tasks.any((t) => t.id == task.id);
    
    return ListTile(
      leading: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: CustomNeumorphicTheme.primaryPurple.withOpacity(isCurrentPhase ? 1.0 : 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      title: Text(
        phase.name,
        style: TextStyle(
          fontWeight: isCurrentPhase ? FontWeight.w600 : FontWeight.normal,
          color: isCurrentPhase ? CustomNeumorphicTheme.primaryPurple : null,
        ),
      ),
      subtitle: Text('${phase.tasks.length} tasks'),
      trailing: isCurrentPhase ? const Icon(Icons.check) : null,
      onTap: isCurrentPhase ? null : () {
        onPhaseChanged(phase.id);
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