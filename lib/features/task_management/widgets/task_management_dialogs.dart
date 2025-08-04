import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/project_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../project_creation/providers/project_provider.dart';

class TaskManagementDialogs {
  static Future<void> showAddTaskDialog(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String phaseId,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddEditTaskDialog(
        projectId: projectId,
        phaseId: phaseId,
        task: null, // null means we're adding a new task
      ),
    );
  }

  static Future<void> showEditTaskDialog(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String phaseId,
    Task task,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddEditTaskDialog(
        projectId: projectId,
        phaseId: phaseId,
        task: task,
      ),
    );
  }

  static Future<bool> showDeleteTaskDialog(
    BuildContext context,
    Task task,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this task?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  static Future<String?> showMoveTaskDialog(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String currentPhaseId,
    Task task,
  ) async {
    final projectsState = ref.read(projectNotifierProvider);
    final projects = projectsState.value ?? [];
    final project = projects.firstWhere((p) => p.id == projectId);
    
    return showDialog<String>(
      context: context,
      builder: (context) => MoveTaskDialog(
        project: project,
        currentPhaseId: currentPhaseId,
        task: task,
      ),
    );
  }
}

class AddEditTaskDialog extends ConsumerStatefulWidget {
  final String projectId;
  final String phaseId;
  final Task? task; // null for adding new task

  const AddEditTaskDialog({
    required this.projectId,
    required this.phaseId,
    this.task,
    super.key,
  });

  @override
  ConsumerState<AddEditTaskDialog> createState() => _AddEditTaskDialogState();
}

class _AddEditTaskDialogState extends ConsumerState<AddEditTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _estimatedHoursController;
  late TaskStatus _selectedStatus;
  late Priority _selectedPriority;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _estimatedHoursController = TextEditingController(
      text: widget.task?.estimatedHours.toString() ?? '0',
    );
    _selectedStatus = widget.task?.status ?? TaskStatus.todo;
    _selectedPriority = widget.task?.priority ?? Priority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Task' : 'Add New Task'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field
                TextFormField(
                  controller: _titleController,
                  onTapOutside: (event) {
                    // Hide keyboard when tapping outside
                    FocusScope.of(context).unfocus();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Task Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description field
                TextFormField(
                  controller: _descriptionController,
                  onTapOutside: (event) {
                    // Hide keyboard when tapping outside
                    FocusScope.of(context).unfocus();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                
                // Estimated hours field
                TextFormField(
                  controller: _estimatedHoursController,
                  onTapOutside: (event) {
                    // Hide keyboard when tapping outside
                    FocusScope.of(context).unfocus();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Estimated Hours',
                    border: OutlineInputBorder(),
                    suffixText: 'hours',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final hours = double.tryParse(value);
                      if (hours == null || hours < 0) {
                        return 'Please enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Status selection
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: TaskStatus.values.map((status) {
                    final isSelected = _selectedStatus == status;
                    return FilterChip(
                      label: Text(_getStatusLabel(status)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        }
                      },
                      backgroundColor: _getStatusColor(status).withOpacity(0.1),
                      selectedColor: _getStatusColor(status).withOpacity(0.3),
                      checkmarkColor: _getStatusColor(status),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Priority selection
                Text(
                  'Priority',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: Priority.values.map((priority) {
                    final isSelected = _selectedPriority == priority;
                    return FilterChip(
                      label: Text(_getPriorityLabel(priority)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        }
                      },
                      backgroundColor: _getPriorityColor(priority).withOpacity(0.1),
                      selectedColor: _getPriorityColor(priority).withOpacity(0.3),
                      checkmarkColor: _getPriorityColor(priority),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final estimatedHours = double.tryParse(_estimatedHoursController.text) ?? 0.0;
      
      if (widget.task != null) {
        // Update existing task
        final updatedTask = Task(
          id: widget.task!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _selectedStatus,
          priority: _selectedPriority,
          assignedToId: widget.task!.assignedToId,
          createdAt: widget.task!.createdAt,
          dueDate: widget.task!.dueDate,
          attachmentIds: widget.task!.attachmentIds,
          dependencyIds: widget.task!.dependencyIds,
          estimatedHours: estimatedHours,
          actualHours: widget.task!.actualHours,
          comments: widget.task!.comments,
        );
        
        ref.read(projectNotifierProvider.notifier).updateTask(
          widget.projectId,
          widget.phaseId,
          updatedTask,
        );
      } else {
        // Create new task
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _selectedStatus,
          priority: _selectedPriority,
          assignedToId: null,
          createdAt: DateTime.now(),
          dueDate: null,
          attachmentIds: [],
          dependencyIds: [],
          estimatedHours: estimatedHours,
          actualHours: 0.0,
          comments: [],
        );
        
        ref.read(projectNotifierProvider.notifier).addTaskToPhase(
          widget.projectId,
          widget.phaseId,
          newTask,
        );
      }
      
      Navigator.of(context).pop();
    }
  }

  String _getStatusLabel(TaskStatus status) {
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

  String _getPriorityLabel(Priority priority) {
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
        return AppColors.statusBlocked;
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

class MoveTaskDialog extends StatefulWidget {
  final Project project;
  final String currentPhaseId;
  final Task task;

  const MoveTaskDialog({
    required this.project,
    required this.currentPhaseId,
    required this.task,
    super.key,
  });

  @override
  State<MoveTaskDialog> createState() => _MoveTaskDialogState();
}

class _MoveTaskDialogState extends State<MoveTaskDialog> {
  String? _selectedPhaseId;

  @override
  Widget build(BuildContext context) {
    final availablePhases = widget.project.phases
        .where((phase) => phase.id != widget.currentPhaseId)
        .toList();

    return AlertDialog(
      title: const Text('Move Task'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.task.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Phase selection
            Text(
              'Select destination phase:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            
            if (availablePhases.isEmpty)
              const Text(
                'No other phases available.',
                style: TextStyle(fontStyle: FontStyle.italic),
              )
            else
              ...availablePhases.map((phase) {
                return RadioListTile<String>(
                  title: Text(phase.name),
                  subtitle: Text(
                    '${phase.tasks.length} tasks',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  value: phase.id,
                  groupValue: _selectedPhaseId,
                  onChanged: (value) {
                    setState(() {
                      _selectedPhaseId = value;
                    });
                  },
                );
              }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedPhaseId != null
              ? () => Navigator.of(context).pop(_selectedPhaseId)
              : null,
          child: const Text('Move'),
        ),
      ],
    );
  }
}