import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                    color: CustomNeumorphicTheme.primaryPurple,
                    child: Icon(
                      isEditing ? Icons.edit : Icons.add_task,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Task' : 'Add New Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Title
                      _buildTextFormField(
                        controller: _titleController,
                        label: 'Task Title *',
                        hint: 'Enter task title',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Task title is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Task Description
                      _buildTextFormField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter task description (optional)',
                        maxLines: 3,
                      ),
                      SizedBox(height: 16.h),

                      // Phase Selection - only show for creating new tasks
                      if (!isEditing) ...[
                        _buildPhaseDropdown(),
                        SizedBox(height: 16.h),
                      ],

                      // Status and Priority Row
                      Row(
                        children: [
                          Expanded(child: _buildStatusDropdown()),
                          SizedBox(width: 12.w),
                          Expanded(child: _buildPriorityDropdown()),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Hours and Due Date Row
                      Row(
                        children: [
                          Expanded(child: _buildEstimatedHoursField()),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: isEditing 
                                ? _buildActualHoursField() 
                                : _buildDueDateField(),
                          ),
                        ],
                      ),
                      
                      // Due Date Field - Only show separately when editing
                      if (isEditing) ...[
                        SizedBox(height: 16.h),
                        _buildDueDateField(),
                      ],
                      
                      SizedBox(height: 16.h), // Bottom padding for scroll
                    ],
                  ),
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
                mainAxisAlignment: MainAxisAlignment.end,
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
                  SizedBox(width: 12.w),
                  NeumorphicButton(
                    onPressed: _saveTask,
                    isSelected: true,
                    selectedColor: CustomNeumorphicTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(12.r),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Text(
                      isEditing ? 'Update Task' : 'Add Task',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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


  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        NeumorphicContainer(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          borderRadius: BorderRadius.circular(12.r),
          color: CustomNeumorphicTheme.baseColor,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: CustomNeumorphicTheme.lightText,
                fontSize: 14.sp,
              ),
            ),
            maxLines: maxLines,
            style: TextStyle(fontSize: 14.sp),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phase *',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        NeumorphicContainer(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          borderRadius: BorderRadius.circular(12.r),
          color: CustomNeumorphicTheme.baseColor,
          child: DropdownButtonFormField<String>(
            value: _selectedPhaseId,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Select phase',
            ),
            items: widget.project.phases.map((phase) {
              return DropdownMenuItem<String>(
                value: phase.id,
                child: Text(
                  phase.name,
                  style: TextStyle(fontSize: 14.sp),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPhaseId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a phase';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        NeumorphicContainer(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          borderRadius: BorderRadius.circular(12.r),
          color: CustomNeumorphicTheme.baseColor,
          child: DropdownButtonFormField<TaskStatus>(
            value: _selectedStatus,
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            items: TaskStatus.values.map((status) {
              return DropdownMenuItem<TaskStatus>(
                value: status,
                child: Text(
                  _getStatusDisplayName(status),
                  style: TextStyle(fontSize: 14.sp),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value ?? TaskStatus.todo;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        NeumorphicContainer(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          borderRadius: BorderRadius.circular(12.r),
          color: CustomNeumorphicTheme.baseColor,
          child: DropdownButtonFormField<Priority>(
            value: _selectedPriority,
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            items: Priority.values.map((priority) {
              return DropdownMenuItem<Priority>(
                value: priority,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _getPriorityDisplayName(priority),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPriority = value ?? Priority.medium;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatedHoursField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimated Hours',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        NeumorphicContainer(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          borderRadius: BorderRadius.circular(12.r),
          color: CustomNeumorphicTheme.baseColor,
          child: TextFormField(
            controller: _estimatedHoursController,
            decoration: InputDecoration(
              hintText: '0',
              border: InputBorder.none,
              suffixText: 'hrs',
            ),
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildActualHoursField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actual Hours',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        NeumorphicContainer(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          borderRadius: BorderRadius.circular(12.r),
          color: CustomNeumorphicTheme.baseColor,
          child: TextFormField(
            controller: _actualHoursController,
            decoration: InputDecoration(
              hintText: '0',
              border: InputBorder.none,
              suffixText: 'hrs',
            ),
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildDueDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        NeumorphicContainer(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          borderRadius: BorderRadius.circular(12.r),
          color: CustomNeumorphicTheme.baseColor,
          child: GestureDetector(
            onTap: _selectDueDate,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDueDate != null
                        ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _selectedDueDate != null
                          ? CustomNeumorphicTheme.darkText
                          : CustomNeumorphicTheme.lightText,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 16.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }


  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final estimatedHours = double.tryParse(_estimatedHoursController.text) ?? 0.0;
      final actualHours = double.tryParse(_actualHoursController.text) ?? 0.0;
      
      if (widget.isCreating) {
        // Create new task
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _selectedStatus,
          priority: _selectedPriority,
          assignedToId: null,
          createdAt: DateTime.now(),
          dueDate: _selectedDueDate,
          attachmentIds: [],
          dependencyIds: [],
          estimatedHours: estimatedHours,
          actualHours: 0.0,
          comments: [],
        );
        
        if (_selectedPhaseId != null) {
          ref.read(projectNotifierProvider.notifier).addTaskToPhase(
            widget.project.id,
            _selectedPhaseId!,
            newTask,
          );
        }
      } else {
        // Update existing task
        final updatedTask = Task(
          id: widget.task.id,
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
        
        ref.read(projectNotifierProvider.notifier).updateTask(
          widget.project.id,
          widget.phaseId,
          updatedTask,
        );
      }
      
      Navigator.of(context).pop();
    }
  }

  String _getStatusDisplayName(TaskStatus status) {
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

  String _getPriorityDisplayName(Priority priority) {
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