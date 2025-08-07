import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/models/project_role_model.dart';
import '../../features/team_management/providers/project_role_provider.dart';
import '../theme/custom_neumorphic_theme.dart';

class RoleEditDialog extends ConsumerStatefulWidget {
  final ProjectRole? role;
  final String projectId;
  final bool isCreating;

  const RoleEditDialog({
    this.role,
    required this.projectId,
    this.isCreating = false,
    super.key,
  });

  @override
  ConsumerState<RoleEditDialog> createState() => _RoleEditDialogState();
}

class _RoleEditDialogState extends ConsumerState<RoleEditDialog>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _timeCommitmentController;
  late TextEditingController _skillController;

  String _selectedColor = '#7B68EE';
  int _priority = 5;
  List<String> _requiredSkills = [];
  List<String> _permissions = [];
  bool _isAssignable = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> _availablePermissions = [
    'view_project',
    'edit_tasks',
    'manage_team',
    'create_phases',
    'delete_tasks',
    'manage_deadlines',
    'view_reports',
    'manage_files'
  ];

  final List<String> _predefinedColors = [
    '#7B68EE', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', 
    '#06B6D4', '#84CC16', '#F97316', '#EC4899', '#6B7280'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  void _initializeControllers() {
    if (widget.role != null) {
      final role = widget.role!;
      _nameController = TextEditingController(text: role.name);
      _descriptionController = TextEditingController(text: role.description);
      _timeCommitmentController = TextEditingController(
        text: role.timeCommitment?.toString() ?? '',
      );
      _selectedColor = role.color;
      _priority = role.priority;
      _requiredSkills = List.from(role.requiredSkills);
      _permissions = List.from(role.permissions);
      _isAssignable = role.isAssignable;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _timeCommitmentController = TextEditingController();
      _permissions = ['view_project', 'edit_tasks'];
    }
    _skillController = TextEditingController();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _timeCommitmentController.dispose();
    _skillController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: MediaQuery.of(context).size.width > 600 ? 600 : double.infinity,
          ),
          child: NeumorphicContainer(
            borderRadius: BorderRadius.circular(24.r),
            color: CustomNeumorphicTheme.baseColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNameField(),
                        SizedBox(height: 20.h),
                        _buildDescriptionField(),
                        SizedBox(height: 20.h),
                        _buildColorSelector(),
                        SizedBox(height: 20.h),
                        _buildPrioritySelector(),
                        SizedBox(height: 20.h),
                        _buildSkillsSection(),
                        SizedBox(height: 20.h),
                        _buildPermissionsSection(),
                        SizedBox(height: 20.h),
                        _buildTimeCommitmentField(),
                        SizedBox(height: 20.h),
                        _buildOptionsSection(),
                        if (!widget.isCreating) ...[
                          SizedBox(height: 30.h),
                          _buildDeleteSection(),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: CustomNeumorphicTheme.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Row(
        children: [
          NeumorphicContainer(
            padding: EdgeInsets.all(8.w),
            borderRadius: BorderRadius.circular(12.r),
            color: Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))),
            child: Icon(
              widget.isCreating ? Icons.add : Icons.admin_panel_settings,
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
                  widget.isCreating ? 'Create Project Role' : 'Edit Project Role',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
                if (!widget.isCreating) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Last updated: ${_formatDate(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CustomNeumorphicTheme.lightText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: NeumorphicContainer(
              padding: EdgeInsets.all(8.w),
              borderRadius: BorderRadius.circular(12.r),
              color: CustomNeumorphicTheme.baseColor,
              child: Icon(
                Icons.close,
                color: CustomNeumorphicTheme.lightText,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return _buildFormField(
      label: 'Role Name *',
      controller: _nameController,
      hintText: 'e.g., Frontend Developer, UX Designer',
      maxLines: 1,
    );
  }

  Widget _buildDescriptionField() {
    return _buildFormField(
      label: 'Role Description *',
      controller: _descriptionController,
      hintText: 'Describe the responsibilities and expectations for this role...',
      maxLines: 3,
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        NeumorphicContainer(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          borderRadius: BorderRadius.circular(12.r),
          color: CustomNeumorphicTheme.cardColor,
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 14.sp,
              color: CustomNeumorphicTheme.darkText,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role Color',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _predefinedColors.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(8.r),
                  border: isSelected 
                    ? Border.all(color: CustomNeumorphicTheme.primaryPurple, width: 3)
                    : null,
                ),
                child: isSelected 
                  ? Icon(Icons.check, color: Colors.white, size: 20.sp)
                  : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority (1 = Most Critical)',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        NeumorphicContainer(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          borderRadius: BorderRadius.circular(12.r),
          color: CustomNeumorphicTheme.cardColor,
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: _priority.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: CustomNeumorphicTheme.primaryPurple,
                  onChanged: (value) => setState(() => _priority = value.toInt()),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: CustomNeumorphicTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '$_priority',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Skills',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        
        // Add skill input
        Row(
          children: [
            Expanded(
              child: NeumorphicContainer(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                borderRadius: BorderRadius.circular(12.r),
                color: CustomNeumorphicTheme.cardColor,
                child: TextField(
                  controller: _skillController,
                  style: TextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Add a skill...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: _addSkill,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            NeumorphicButton(
              onPressed: () => _addSkill(_skillController.text),
              borderRadius: BorderRadius.circular(12.r),
              padding: EdgeInsets.all(12.w),
              child: Icon(
                Icons.add,
                size: 16.sp,
                color: CustomNeumorphicTheme.primaryPurple,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12.h),
        
        // Skills chips
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _requiredSkills.map((skill) => _buildSkillChip(skill)).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: TextStyle(
              fontSize: 12.sp,
              color: CustomNeumorphicTheme.primaryPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () => _removeSkill(skill),
            child: Icon(
              Icons.close,
              size: 14.sp,
              color: CustomNeumorphicTheme.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role Permissions',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _availablePermissions.map((permission) {
            final isSelected = _permissions.contains(permission);
            return GestureDetector(
              onTap: () => _togglePermission(permission),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? CustomNeumorphicTheme.primaryPurple 
                    : CustomNeumorphicTheme.cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected 
                      ? Colors.transparent 
                      : CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  permission.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : CustomNeumorphicTheme.darkText,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeCommitmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Commitment (hours/week)',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        NeumorphicContainer(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          borderRadius: BorderRadius.circular(12.r),
          color: CustomNeumorphicTheme.cardColor,
          child: TextField(
            controller: _timeCommitmentController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'e.g., 20',
              suffixIcon: Icon(
                Icons.schedule,
                color: CustomNeumorphicTheme.lightText,
                size: 16.sp,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role Options',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        NeumorphicContainer(
          padding: EdgeInsets.all(16.w),
          borderRadius: BorderRadius.circular(12.r),
          color: CustomNeumorphicTheme.cardColor,
          child: Row(
            children: [
              Icon(
                Icons.person_add,
                color: CustomNeumorphicTheme.primaryPurple,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assignable Role',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                    ),
                    Text(
                      'Allow users to be assigned to this role',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: CustomNeumorphicTheme.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isAssignable,
                onChanged: (value) => setState(() => _isAssignable = value),
                activeColor: CustomNeumorphicTheme.primaryPurple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.2),
          thickness: 1,
        ),
        SizedBox(height: 16.h),
        Text(
          'Danger Zone',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.errorRed,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _showDeleteConfirmation,
          child: NeumorphicContainer(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            borderRadius: BorderRadius.circular(12.r),
            color: CustomNeumorphicTheme.errorRed.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  color: CustomNeumorphicTheme.errorRed,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete Role',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: CustomNeumorphicTheme.errorRed,
                        ),
                      ),
                      Text(
                        'This action cannot be undone',
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
                  color: CustomNeumorphicTheme.errorRed,
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: CustomNeumorphicTheme.cardColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: NeumorphicButton(
              onPressed: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(12.r),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: NeumorphicButton(
              onPressed: _isLoading ? null : _saveRole,
              isSelected: true,
              selectedColor: CustomNeumorphicTheme.primaryPurple,
              borderRadius: BorderRadius.circular(12.r),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: _isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.isCreating ? 'Create Role' : 'Save Changes',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _addSkill(String skill) {
    if (skill.trim().isNotEmpty && !_requiredSkills.contains(skill.trim())) {
      setState(() {
        _requiredSkills.add(skill.trim());
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _requiredSkills.remove(skill);
    });
  }

  void _togglePermission(String permission) {
    setState(() {
      if (_permissions.contains(permission)) {
        _permissions.remove(permission);
      } else {
        _permissions.add(permission);
      }
    });
  }

  void _saveRole() async {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and description are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final timeCommitment = double.tryParse(_timeCommitmentController.text);

      if (widget.isCreating) {
        await ref.read(projectRoleNotifierProvider(widget.projectId).notifier)
            .createCustomRole(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          color: _selectedColor,
          permissions: _permissions,
          requiredSkills: _requiredSkills,
          timeCommitment: timeCommitment,
          priority: _priority,
        );
      } else {
        // Update existing role
        final updatedRole = widget.role!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          color: _selectedColor,
          permissions: _permissions,
          requiredSkills: _requiredSkills,
          timeCommitment: timeCommitment,
          priority: _priority,
          isAssignable: _isAssignable,
        );
        
        await ref.read(projectRoleNotifierProvider(widget.projectId).notifier)
            .updateRole(updatedRole);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isCreating ? 'Role created successfully' : 'Role updated successfully'),
            backgroundColor: CustomNeumorphicTheme.primaryPurple,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving role: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CustomNeumorphicTheme.baseColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Role',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: CustomNeumorphicTheme.errorRed,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.role?.name}"? This action cannot be undone.',
          style: TextStyle(
            fontSize: 14.sp,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: CustomNeumorphicTheme.darkText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteRole();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: CustomNeumorphicTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteRole() async {
    if (widget.role == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(projectRoleNotifierProvider(widget.projectId).notifier)
          .deleteRole(widget.role!.id);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role deleted successfully'),
            backgroundColor: CustomNeumorphicTheme.primaryPurple,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting role: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}