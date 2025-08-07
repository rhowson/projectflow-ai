import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/models/project_model.dart';
import '../theme/app_colors.dart';
import '../theme/custom_neumorphic_theme.dart';
import '../../features/project_creation/providers/project_provider.dart';

class TaskEditDialog extends ConsumerStatefulWidget {
  final Task task;
  final Project project;
  final String phaseId;
  final bool isCreating;

  const TaskEditDialog({
    required this.task,
    required this.project,
    required this.phaseId,
    this.isCreating = false,
    super.key,
  });

  @override
  ConsumerState<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends ConsumerState<TaskEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _estimatedHoursController;
  late final TextEditingController _actualHoursController;

  late TaskStatus _selectedStatus;
  late Priority _selectedPriority;
  DateTime? _selectedDueDate;
  String? _selectedPhaseId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _estimatedHoursController = TextEditingController(
      text: widget.task.estimatedHours > 0 ? widget.task.estimatedHours.toString() : '',
    );
    _actualHoursController = TextEditingController(
      text: widget.task.actualHours > 0 ? widget.task.actualHours.toString() : '',
    );
    
    _selectedStatus = widget.task.status;
    _selectedPriority = widget.task.priority;
    _selectedDueDate = widget.task.dueDate;
    
    // Find current phase for editing
    if (widget.isCreating && widget.project.phases.isNotEmpty) {
      _selectedPhaseId = widget.project.phases.first.id;
    } else if (!widget.isCreating) {
      // Find the phase containing this task
      for (final phase in widget.project.phases) {
        if (phase.tasks.any((t) => t.id == widget.task.id)) {
          _selectedPhaseId = phase.id;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedHoursController.dispose();
    _actualHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = !widget.isCreating;

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
        child: Form(
          key: _formKey,
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
                      color: CustomNeumorphicTheme.primaryPurple,
                      child: Icon(
                        isEditing ? Icons.edit : Icons.add_task,
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
                            isEditing ? 'Edit Task' : 'Create New Task',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            isEditing ? 'Update task details' : 'Add a new task to project',
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
                      _buildEditSection(
                        'Title',
                        icon: Icons.task_alt,
                        child: _buildTextFormField(
                          controller: _titleController,
                          hint: 'Enter task title',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Task title is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Task Description
                      _buildEditSection(
                        'Description',
                        icon: Icons.description,
                        child: _buildTextFormField(
                          controller: _descriptionController,
                          hint: 'Enter task description (optional)',
                          minLines: 6,
                          maxLines: 10,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Phase Selection - only show for creating new tasks
                      if (!isEditing) ...[
                        _buildEditSection(
                          'Phase',
                          icon: Icons.folder,
                          child: _buildPhaseDropdown(),
                        ),
                        SizedBox(height: 16.h),
                      ],

                      // Status and Priority Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditCard(
                              'Status',
                              child: _buildStatusDropdown(),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildEditCard(
                              'Priority',
                              child: _buildPriorityDropdown(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Time and Assignment Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditCard(
                              'Estimated Hours',
                              child: _buildTextFormField(
                                controller: _estimatedHoursController,
                                hint: '0',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final hours = double.tryParse(value);
                                    if (hours == null || hours < 0) {
                                      return 'Enter valid hours';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildEditCard(
                              isEditing ? 'Actual Hours' : 'Due Date',
                              child: isEditing 
                                  ? _buildTextFormField(
                                      controller: _actualHoursController,
                                      hint: '0',
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          final hours = double.tryParse(value);
                                          if (hours == null || hours < 0) {
                                            return 'Enter valid hours';
                                          }
                                        }
                                        return null;
                                      },
                                    )
                                  : _buildDueDateField(),
                            ),
                          ),
                        ],
                      ),
                      
                      // Due Date Field - Only show separately when editing
                      if (isEditing) ...[
                        SizedBox(height: 16.h),
                        _buildEditSection(
                          'Due Date',
                          icon: Icons.calendar_today,
                          child: _buildDueDateField(),
                        ),
                      ],
                      
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
                        'Cancel',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: CustomNeumorphicTheme.lightText,
                        ),
                      ),
                    ),
                    NeumorphicButton(
                      onPressed: _saveTask,
                      isSelected: true,
                      selectedColor: CustomNeumorphicTheme.primaryPurple,
                      borderRadius: BorderRadius.circular(12.r),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEditing ? Icons.save : Icons.add,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            isEditing ? 'Save Changes' : 'Create Task',
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
      ),
    );
  }

  // Helper method to build edit sections that match the view layout
  Widget _buildEditSection(String label, {required IconData icon, required Widget child}) {
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
          child,
        ],
      ),
    );
  }

  // Helper method to build edit cards that match the view layout
  Widget _buildEditCard(String label, {required Widget child}) {
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
          child,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    String? hint,
    int? maxLines,
    int? minLines,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines ?? 1,
      minLines: minLines,
      keyboardType: keyboardType,
      validator: validator,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: CustomNeumorphicTheme.darkText,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.6),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<TaskStatus>(
      value: _selectedStatus,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: _getStatusColor(_selectedStatus),
        fontWeight: FontWeight.w600,
      ),
      items: TaskStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  _getStatusIcon(status),
                  size: 12.sp,
                  color: _getStatusColor(status),
                ),
              ),
              SizedBox(width: 6.w),
              Text(_getStatusText(status)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedStatus = value;
          });
        }
      },
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<Priority>(
      value: _selectedPriority,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: _getPriorityColor(_selectedPriority),
        fontWeight: FontWeight.w600,
      ),
      items: Priority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  _getPriorityIcon(priority),
                  size: 12.sp,
                  color: _getPriorityColor(priority),
                ),
              ),
              SizedBox(width: 6.w),
              Text(_getPriorityText(priority)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPriority = value;
          });
        }
      },
    );
  }

  Widget _buildPhaseDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPhaseId,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: CustomNeumorphicTheme.darkText,
      ),
      items: widget.project.phases.map((phase) {
        return DropdownMenuItem(
          value: phase.id,
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: _getPhaseStatusColor(phase.status),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  phase.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPhaseId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a phase';
        }
        return null;
      },
    );
  }

  Widget _buildDueDateField() {
    return InkWell(
      onTap: _selectDueDate,
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 14.sp,
            color: _selectedDueDate != null 
                ? _getDueDateColor(_selectedDueDate!) 
                : CustomNeumorphicTheme.lightText,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              _selectedDueDate != null 
                  ? DateFormat('MMM dd, yyyy').format(_selectedDueDate!)
                  : 'Select due date',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _selectedDueDate != null
                    ? CustomNeumorphicTheme.darkText
                    : CustomNeumorphicTheme.lightText.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_selectedDueDate != null)
            InkWell(
              onTap: () {
                setState(() {
                  _selectedDueDate = null;
                });
              },
              child: Icon(
                Icons.clear,
                size: 12.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDueDate = selectedDate;
      });
    }
  }

  void _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final estimatedHours = double.tryParse(_estimatedHoursController.text) ?? 0.0;
    final actualHours = double.tryParse(_actualHoursController.text) ?? 0.0;

    final updatedTask = Task(
      id: widget.isCreating ? DateTime.now().millisecondsSinceEpoch.toString() : widget.task.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
      assignedToId: widget.task.assignedToId,
      createdAt: widget.task.createdAt,
      dueDate: _selectedDueDate,
      attachmentIds: widget.task.attachmentIds,
      dependencyIds: widget.task.dependencyIds,
      estimatedHours: estimatedHours,
      actualHours: actualHours,
      comments: widget.task.comments,
    );

    try {
      if (widget.isCreating) {
        await ref.read(projectNotifierProvider.notifier).addTaskToPhase(
          widget.project.id,
          _selectedPhaseId!,
          updatedTask,
        );
      } else {
        await ref.read(projectNotifierProvider.notifier).updateTask(
          widget.project.id,
          widget.phaseId,
          updatedTask,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${widget.isCreating ? 'create' : 'update'} task: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Helper methods for colors and icons (matching TaskDetailsDialog)
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