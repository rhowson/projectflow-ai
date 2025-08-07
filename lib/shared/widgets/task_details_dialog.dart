import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/models/project_model.dart';
import '../theme/app_colors.dart';
import '../theme/custom_neumorphic_theme.dart';
import 'task_edit_dialog.dart';

class TaskDetailsDialog extends ConsumerStatefulWidget {
  final Task task;
  final Project project;

  const TaskDetailsDialog({
    required this.task,
    required this.project,
    super.key,
  });

  @override
  ConsumerState<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends ConsumerState<TaskDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16.w),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: CustomNeumorphicTheme.baseColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: CustomNeumorphicTheme.bottomEdgeShadow.withValues(alpha: 0.3),
              offset: const Offset(2, 4),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: CustomNeumorphicTheme.baseColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: Row(
                children: [
                  NeumorphicContainer(
                    padding: EdgeInsets.all(8.w),
                    borderRadius: BorderRadius.circular(12.r),
                    color: _getStatusColor(widget.task.status),
                    child: Icon(
                      _getStatusIcon(widget.task.status),
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task Details',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _getStatusText(widget.task.status),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: CustomNeumorphicTheme.lightText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Title
                    _buildDetailSection(
                      'Title',
                      widget.task.title,
                      icon: Icons.task_alt,
                    ),
                    SizedBox(height: 16.h),

                    // Task Description
                    if (widget.task.description.isNotEmpty) ...[
                      _buildDetailSection(
                        'Description',
                        widget.task.description,
                        icon: Icons.description,
                        isMultiline: true,
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // Status and Priority Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusPriorityCard(
                            'Status',
                            _getStatusText(widget.task.status),
                            _getStatusColor(widget.task.status),
                            _getStatusIcon(widget.task.status),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildStatusPriorityCard(
                            'Priority',
                            _getPriorityText(widget.task.priority),
                            _getPriorityColor(widget.task.priority),
                            _getPriorityIcon(widget.task.priority),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Time and Assignment Row
                    Row(
                      children: [
                        if (widget.task.estimatedHours > 0)
                          Expanded(
                            child: _buildInfoCard(
                              'Estimated',
                              '${widget.task.estimatedHours.toInt()}h',
                              Icons.schedule,
                              CustomNeumorphicTheme.primaryPurple,
                            ),
                          ),
                        if (widget.task.estimatedHours > 0 && widget.task.actualHours > 0)
                          SizedBox(width: 12.w),
                        if (widget.task.actualHours > 0)
                          Expanded(
                            child: _buildInfoCard(
                              'Actual',
                              '${widget.task.actualHours.toInt()}h',
                              Icons.timer,
                              CustomNeumorphicTheme.successGreen,
                            ),
                          ),
                        if (widget.task.estimatedHours == 0 && widget.task.actualHours == 0)
                          Expanded(
                            child: _buildInfoCard(
                              'Time',
                              'Not tracked',
                              Icons.schedule_outlined,
                              CustomNeumorphicTheme.lightText,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Due Date and Assignment
                    if (widget.task.dueDate != null || widget.task.assignedToId != null) ...[
                      Row(
                        children: [
                          if (widget.task.dueDate != null)
                            Expanded(
                              child: _buildInfoCard(
                                'Due Date',
                                DateFormat('MMM dd, yyyy').format(widget.task.dueDate!),
                                Icons.calendar_today,
                                _getDueDateColor(widget.task.dueDate!),
                              ),
                            ),
                          if (widget.task.dueDate != null && widget.task.assignedToId != null)
                            SizedBox(width: 12.w),
                          if (widget.task.assignedToId != null)
                            Expanded(
                              child: _buildInfoCard(
                                'Assigned',
                                'Team Member',
                                Icons.person,
                                CustomNeumorphicTheme.primaryPurple,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // Phase Information
                    _buildPhaseInfo(),
                    
                    SizedBox(height: 16.h), // Bottom padding for scroll
                  ],
                ),
              ),
            ),
            
            // Footer Actions
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: CustomNeumorphicTheme.baseColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
                border: Border(
                  top: BorderSide(
                    color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeumorphicButton(
                    onPressed: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12.r),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Text(
                      'Close',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: CustomNeumorphicTheme.lightText,
                      ),
                    ),
                  ),
                  NeumorphicButton(
                    onPressed: _editTask,
                    isSelected: true,
                    selectedColor: CustomNeumorphicTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(12.r),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Edit Task',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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

  Widget _buildDetailSection(String label, String value, {required IconData icon, bool isMultiline = false}) {
    return NeumorphicCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: CustomNeumorphicTheme.primaryPurple,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: CustomNeumorphicTheme.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          isMultiline
              ? _buildExpandableText(value)
              : Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildExpandableText(String value) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 6 * 1.4 * 14.sp, // Minimum height for 6 lines
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: CustomNeumorphicTheme.darkText,
          height: 1.4,
        ),
        maxLines: 10, // Maximum 10 lines
        overflow: TextOverflow.ellipsis,
        softWrap: true,
      ),
    );
  }

  Widget _buildStatusPriorityCard(String label, String value, Color color, IconData icon) {
    return NeumorphicCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: CustomNeumorphicTheme.lightText,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  size: 12.sp,
                  color: color,
                ),
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return NeumorphicCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: CustomNeumorphicTheme.lightText,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: color,
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: CustomNeumorphicTheme.darkText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseInfo() {
    // Find the phase containing this task
    ProjectPhase? currentPhase;
    for (final phase in widget.project.phases) {
      if (phase.tasks.any((t) => t.id == widget.task.id)) {
        currentPhase = phase;
        break;
      }
    }

    if (currentPhase == null) return const SizedBox.shrink();

    return NeumorphicCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder,
                size: 16.sp,
                color: CustomNeumorphicTheme.primaryPurple,
              ),
              SizedBox(width: 8.w),
              Text(
                'Phase',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: CustomNeumorphicTheme.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                width: 4.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: _getPhaseStatusColor(currentPhase.status),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPhase.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CustomNeumorphicTheme.darkText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (currentPhase.description.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        currentPhase.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CustomNeumorphicTheme.lightText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editTask() async {
    Navigator.of(context).pop(); // Close details dialog
    
    // Find the current phase for this task
    String? currentPhaseId;
    for (final phase in widget.project.phases) {
      if (phase.tasks.any((t) => t.id == widget.task.id)) {
        currentPhaseId = phase.id;
        break;
      }
    }
    
    if (currentPhaseId != null) {
      // Show edit dialog with seamless transition
      await showDialog(
        context: context,
        builder: (context) => TaskEditDialog(
          task: widget.task,
          project: widget.project,
          phaseId: currentPhaseId!,
          isCreating: false,
        ),
      );
    }
  }

  // Helper methods for colors and icons
  Color _getStatusColor(TaskStatus status) {
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
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.play_circle;
      case TaskStatus.review:
        return Icons.rate_review;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.blocked:
        return Icons.block;
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.review:
        return 'Review';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.blocked:
        return 'Blocked';
    }
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

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Icons.keyboard_arrow_down;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.keyboard_arrow_up;
      case Priority.urgent:
        return Icons.priority_high;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.urgent:
        return 'Urgent';
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return AppColors.error; // Overdue
    } else if (difference <= 3) {
      return AppColors.warning; // Due soon
    } else {
      return CustomNeumorphicTheme.successGreen; // On track
    }
  }

  Color _getPhaseStatusColor(PhaseStatus status) {
    switch (status) {
      case PhaseStatus.notStarted:
        return CustomNeumorphicTheme.lightText;
      case PhaseStatus.inProgress:
        return CustomNeumorphicTheme.primaryPurple;
      case PhaseStatus.completed:
        return CustomNeumorphicTheme.successGreen;
      case PhaseStatus.onHold:
        return Colors.orange;
    }
  }
}