import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../core/models/project_model.dart';
import '../../project_creation/providers/project_provider.dart';
import '../../project_context/providers/project_context_provider.dart';
import '../../project_context/presentation/project_context_screen.dart';
import '../../task_management/widgets/responsive_kanban_board.dart';
import '../../../shared/widgets/loading_indicator.dart';

class TasksScreen extends ConsumerStatefulWidget {
  final String? projectId;
  final String? phaseId;
  
  const TasksScreen({super.key, this.projectId, this.phaseId});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String? selectedProjectId;
  String? selectedPhaseId;
  bool _isProjectSelectorCollapsed = false;
  bool _isEditingProjectName = false;
  late TextEditingController _projectNameController;
  late ScrollController _phaseFilterScrollController;
  late ScrollController _phaseCarouselScrollController;

  @override
  void initState() {
    super.initState();
    selectedProjectId = widget.projectId;
    selectedPhaseId = widget.phaseId;
    _projectNameController = TextEditingController();
    _phaseFilterScrollController = ScrollController();
    _phaseCarouselScrollController = ScrollController();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _phaseFilterScrollController.dispose();
    _phaseCarouselScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectNotifierProvider);
    
    return Scaffold(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      appBar: NeumorphicAppBar(
        title: Text(
          'Project',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        automaticallyImplyLeading: false,
        actions: _buildAppBarActions(),
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return _buildEmptyState();
          }
          
          // Find selected project or use first one
          Project? selectedProject;
          if (selectedProjectId != null) {
            selectedProject = projects.firstWhere(
              (p) => p.id == selectedProjectId,
              orElse: () => projects.first,
            );
          } else {
            selectedProject = projects.first;
            selectedProjectId = selectedProject.id;
          }
          
          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sections with horizontal padding
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Selection Section - Dashboard style
                      _buildProjectSelectionSection(projects, selectedProject),
                      
                      SizedBox(height: 24.h),
                      
                      // Phase Filter Section - Pill Buttons
                      if (selectedProject.phases.isNotEmpty) ...[
                        _buildPhaseFilterSection(selectedProject),
                        SizedBox(height: 24.h),
                      ],
                    ],
                  ),
                ),
                
                // Task Board Section - Full width with app margins only
                _buildTaskBoardSection(selectedProject),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: LoadingIndicator(message: 'Loading projects...'),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: CustomNeumorphicTheme.errorRed,
              ),
              SizedBox(height: 16.h),
              Text(
                'Error loading projects',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8.h),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CustomNeumorphicTheme.lightText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          SizedBox(height: 32.h),
          NeumorphicCard(
            padding: EdgeInsets.all(32.w),
            child: Column(
              children: [
                NeumorphicContainer(
                  padding: EdgeInsets.all(20.w),
                  borderRadius: BorderRadius.circular(25),
                  color: CustomNeumorphicTheme.primaryPurple,
                  child: Icon(
                    Icons.task_alt,
                    size: 40.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'No Projects Yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Create your first project to start managing tasks',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: CustomNeumorphicTheme.lightText,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                NeumorphicButton(
                  onPressed: () => context.go('/create-project'),
                  isSelected: true,
                  selectedColor: CustomNeumorphicTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(15),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Create Project',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
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
    );
  }

  // New Compact Project Summary Tiles with Neumorphic Design
  Widget _buildProjectSelectionSection(List<Project> projects, Project selectedProject) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Current Project',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Compact Switch Button
              NeumorphicButton(
                onPressed: () => _showProjectSelector(projects),
                borderRadius: BorderRadius.circular(18.r),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swap_horiz,
                      size: 14.sp,
                      color: CustomNeumorphicTheme.primaryPurple,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Switch',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: CustomNeumorphicTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Compact Project Summary Tiles Container
        NeumorphicContainer(
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
          borderRadius: BorderRadius.circular(18.r),
          color: CustomNeumorphicTheme.cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Project Info - Left Aligned to Container Edge
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Title - Left Aligned to Tile Edge
                  Text(
                    selectedProject.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 6.h),
                  
                  // Project Stats Row - Left Aligned to Tile Edge
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    alignment: WrapAlignment.start,
                    children: [
                      _buildProjectStatChip(
                        icon: Icons.view_module_outlined,
                        label: '${selectedProject.phases.length}',
                        sublabel: 'phases',
                      ),
                      _buildProjectStatChip(
                        icon: Icons.task_alt_outlined,
                        label: '${_getTotalTasks(selectedProject)}',
                        sublabel: 'tasks',
                      ),
                      _buildProjectStatusChip(selectedProject.status),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 10.h),
              
              // Action Buttons Row - Compact Design
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Edit Button - Compact
                  Expanded(
                    child: NeumorphicButton(
                      onPressed: () => _showProjectOptionsMenu(selectedProject),
                      borderRadius: BorderRadius.circular(10.r),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14.sp,
                            color: CustomNeumorphicTheme.primaryPurple,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: CustomNeumorphicTheme.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 8.w),
                  
                  // Context Button - Compact
                  Expanded(
                    child: _buildCompactContextButton(selectedProject),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // NEW: Compact Phase Filter - Single Row Design
  Widget _buildCompactPhaseFilterSection(Project selectedProject) {
    final currentPhaseName = selectedPhaseId == null 
      ? 'All Phases'
      : selectedProject.phases.firstWhere((p) => p.id == selectedPhaseId).name;
    final currentTaskCount = selectedPhaseId == null
      ? _getTotalTasks(selectedProject)
      : selectedProject.phases.firstWhere((p) => p.id == selectedPhaseId).tasks.length;

    return NeumorphicCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Phase Filter Icon and Label
          Icon(
            Icons.filter_list_outlined,
            size: 18.sp,
            color: CustomNeumorphicTheme.primaryPurple,
          ),
          SizedBox(width: 8.w),
          Text(
            'Phase:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: CustomNeumorphicTheme.darkText,
            ),
          ),
          SizedBox(width: 12.w),
          
          // Current Phase Selector - Dropdown style
          Expanded(
            child: NeumorphicButton(
              onPressed: () => _showPhaseSelector(selectedProject),
              borderRadius: BorderRadius.circular(12.r),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentPhaseName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: CustomNeumorphicTheme.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$currentTaskCount task${currentTaskCount == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: CustomNeumorphicTheme.lightText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16.sp,
                    color: CustomNeumorphicTheme.primaryPurple,
                  ),
                ],
              ),
            ),
          ),
          
          // Clear Filter Button (when active)
          if (selectedPhaseId != null) ...[
            SizedBox(width: 8.w),
            NeumorphicButton(
              onPressed: () {
                setState(() {
                  selectedPhaseId = null;
                });
              },
              borderRadius: BorderRadius.circular(8.r),
              padding: EdgeInsets.all(6.w),
              child: Icon(
                Icons.close,
                size: 14.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // NEW: Horizontal Phase Carousel - Better UX than dropdown
  Widget _buildPhaseCarousel(Project selectedProject) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h), // Reduced bottom padding
          child: Row(
            children: [
              Icon(
                Icons.filter_list_outlined,
                size: 14.sp, // Smaller icon
                color: CustomNeumorphicTheme.primaryPurple,
              ),
              SizedBox(width: 6.w), // Reduced spacing
              Expanded(
                child: Text(
                  'Filter by Phase',
                  style: TextStyle(
                    fontSize: 14.sp, // Smaller text
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
              ),
              if (selectedProject.phases.length > 2) // Show swipe hint when many phases
                NeumorphicContainer(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  borderRadius: BorderRadius.circular(12.r),
                  color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swipe_outlined,
                        size: 12.sp,
                        color: CustomNeumorphicTheme.primaryPurple,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Swipe',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: CustomNeumorphicTheme.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (selectedPhaseId != null) ...[
                SizedBox(width: 8.w),
                NeumorphicButton(
                  onPressed: () {
                    setState(() {
                      selectedPhaseId = null;
                    });
                    // Smooth scroll to first chip (All Phases) with animation
                    _phaseCarouselScrollController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: CustomNeumorphicTheme.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Horizontal Phase Carousel
        SizedBox(
          height: 68.h, // Increased height to prevent shadow clipping
          child: ListView.builder(
            controller: _phaseCarouselScrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 8.w, right: 16.w),
            itemCount: selectedProject.phases.length + 1, // +1 for "All Phases"
            itemBuilder: (context, index) {
              if (index == 0) {
                // "All Phases" card
                return _buildPhaseCard(
                  name: 'All Phases',
                  phaseId: null,
                  taskCount: _getTotalTasks(selectedProject),
                  isSelected: selectedPhaseId == null,
                  icon: Icons.select_all,
                  isFirst: true,
                );
              }
              
              final phase = selectedProject.phases[index - 1];
              return _buildPhaseCard(
                name: phase.name,
                phaseId: phase.id,
                taskCount: phase.tasks.length,
                isSelected: selectedPhaseId == phase.id,
                icon: Icons.view_module_outlined,
                status: phase.status,
                isFirst: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseCard({
    required String name,
    required String? phaseId,
    required int taskCount,
    required bool isSelected,
    required IconData icon,
    PhaseStatus? status,
    required bool isFirst,
  }) {
    return Container(
      width: 110.w, // Reduced width for compact design
      height: 44.h, // Fixed height to fit in 60.h container with shadow clearance
      margin: EdgeInsets.only(
        left: isFirst ? 0 : 8.w, // Reduced spacing between cards
        top: 11.h, // Slightly reduced margin to optimize section spacing
        bottom: 12.2.h, // Increased bottom margin by 10% to prevent clipping
      ),
      child: NeumorphicButton(
        onPressed: () {
          setState(() {
            selectedPhaseId = phaseId;
          });
        },
        isSelected: isSelected,
        selectedColor: CustomNeumorphicTheme.primaryPurple,
        borderRadius: BorderRadius.circular(12.r), // Slightly smaller radius
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h), // Compact padding
        child: Row(
          children: [
            // Compact icon
            NeumorphicContainer(
              width: 20.w, // Smaller icon container
              height: 20.w,
              borderRadius: BorderRadius.circular(10.r),
              color: isSelected 
                  ? Colors.white.withValues(alpha: 0.2)
                  : (status != null 
                      ? _getPhaseStatusColor(status)
                      : CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1)),
              child: Icon(
                icon,
                size: 10.sp, // Smaller icon
                color: isSelected 
                    ? Colors.white
                    : (status != null 
                        ? Colors.white
                        : CustomNeumorphicTheme.primaryPurple),
              ),
            ),
            
            SizedBox(width: 8.w),
            
            // Compact text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Phase name
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 11.sp, // Smaller text
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : CustomNeumorphicTheme.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Task count - more compact
                  Text(
                    '$taskCount task${taskCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 9.sp, // Even smaller text
                      color: isSelected 
                          ? Colors.white.withValues(alpha: 0.8)
                          : CustomNeumorphicTheme.lightText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection indicator - only show when selected
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 14.sp,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
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

  // Phase Selector Modal
  void _showPhaseSelector(Project selectedProject) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: CustomNeumorphicTheme.baseColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Phase',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  NeumorphicButton(
                    onPressed: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8.r),
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: CustomNeumorphicTheme.lightText,
                    ),
                  ),
                ],
              ),
            ),
            
            // Phase Options List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  // All Phases Option
                  _buildPhaseOption(
                    name: 'All Phases',
                    phaseId: null,
                    taskCount: _getTotalTasks(selectedProject),
                    isSelected: selectedPhaseId == null,
                    onTap: () {
                      setState(() {
                        selectedPhaseId = null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Individual Phase Options
                  ...selectedProject.phases.map((phase) =>
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _buildPhaseOption(
                        name: phase.name,
                        phaseId: phase.id,
                        taskCount: phase.tasks.length,
                        isSelected: selectedPhaseId == phase.id,
                        onTap: () {
                          setState(() {
                            selectedPhaseId = phase.id;
                          });
                          Navigator.pop(context);
                        },
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

  Widget _buildPhaseOption({
    required String name,
    required String? phaseId,
    required int taskCount,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return NeumorphicButton(
      onPressed: onTap,
      isSelected: isSelected,
      selectedColor: CustomNeumorphicTheme.primaryPurple,
      borderRadius: BorderRadius.circular(12.r),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // Phase Icon
          NeumorphicContainer(
            padding: EdgeInsets.all(8.w),
            borderRadius: BorderRadius.circular(8.r),
            color: isSelected
                ? Colors.white.withValues(alpha: 0.2)
                : CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
            child: Icon(
              phaseId == null ? Icons.select_all : Icons.view_module_outlined,
              size: 16.sp,
              color: isSelected ? Colors.white : CustomNeumorphicTheme.primaryPurple,
            ),
          ),
          SizedBox(width: 12.w),
          
          // Phase Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : CustomNeumorphicTheme.darkText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$taskCount task${taskCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isSelected 
                        ? Colors.white.withValues(alpha: 0.8)
                        : CustomNeumorphicTheme.lightText,
                  ),
                ),
              ],
            ),
          ),
          
          // Selection Indicator
          if (isSelected)
            Icon(
              Icons.check_circle,
              size: 20.sp,
              color: Colors.white,
            ),
        ],
      ),
    );
  }

  // ORIGINAL: Keep for rollback capability
  Widget _buildPhaseFilterSection(Project selectedProject) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 16.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Phase Filter',
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Edit Phases Button
              NeumorphicButton(
                onPressed: () => _showPhaseManagementDialog(selectedProject),
                borderRadius: BorderRadius.circular(10.r),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 12.sp,
                      color: CustomNeumorphicTheme.primaryPurple,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Edit',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: CustomNeumorphicTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedPhaseId != null) ...[
                SizedBox(width: 8.w),
                NeumorphicButton(
                  onPressed: () {
                    setState(() {
                      selectedPhaseId = null;
                    });
                    // Smooth scroll to first chip (All Phases) with animation
                    _phaseFilterScrollController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Clear',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: CustomNeumorphicTheme.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.close,
                        size: 12.sp,
                        color: CustomNeumorphicTheme.primaryPurple,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        // Horizontal Scrollable Phase Chips
        SizedBox(
          height: 68.h, // Increased height to prevent shadow clipping
          child: ListView.builder(
            controller: _phaseFilterScrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            itemCount: selectedProject.phases.length + 1, // +1 for "All Phases"
            itemBuilder: (context, index) {
              if (index == 0) {
                // All phases chip
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _buildPhaseChip('All Phases', null, selectedProject),
                );
              }
              
              final phase = selectedProject.phases[index - 1];
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _buildPhaseChip(phase.name, phase.id, selectedProject),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseChip(String label, String? phaseId, Project project) {
    final isSelected = selectedPhaseId == phaseId;
    final taskCount = phaseId == null 
      ? _getTotalTasks(project)
      : project.phases.firstWhere((p) => p.id == phaseId).tasks.length;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 13.h), // Increased bottom margin by 10% to prevent clipping
      child: NeumorphicButton(
        onPressed: () {
          setState(() {
            selectedPhaseId = phaseId;
          });
        },
        isSelected: isSelected,
        selectedColor: CustomNeumorphicTheme.primaryPurple,
        borderRadius: BorderRadius.circular(20.r),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : CustomNeumorphicTheme.darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isSelected 
                  ? Colors.white.withValues(alpha: 0.2)
                  : CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '$taskCount',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected 
                    ? Colors.white
                    : CustomNeumorphicTheme.primaryPurple,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildTaskBoardSection(Project selectedProject) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with app margins
        Padding(
          padding: EdgeInsets.only(left: 24.w, right: 20.w, bottom: 16.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Board',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (selectedPhaseId != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Showing tasks for: ${selectedProject.phases.firstWhere((p) => p.id == selectedPhaseId).name}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CustomNeumorphicTheme.primaryPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Showing all tasks from all phases',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CustomNeumorphicTheme.lightText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              NeumorphicButton(
                onPressed: () => _showAddTaskDialog(selectedProject),
                isSelected: true,
                selectedColor: CustomNeumorphicTheme.primaryPurple,
                borderRadius: BorderRadius.circular(12.r),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 14.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Add Task',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
        // Task Board Container - Full width with app margins only
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SizedBox(
            height: 520.h,
            child: ResponsiveKanbanBoard(
              project: selectedProject,
              filteredTasks: _getFilteredTasks(selectedProject),
            ),
          ),
        ),
      ],
    );
  }


  void _showProjectSelector(List<Project> projects) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: CustomNeumorphicTheme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Text(
                    'Select Project',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                  const Spacer(),
                  NeumorphicButton(
                    onPressed: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    padding: EdgeInsets.all(8.w),
                    child: Icon(
                      Icons.close,
                      color: CustomNeumorphicTheme.lightText,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  final isSelected = project.id == selectedProjectId;
                  
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    child: NeumorphicCard(
                      onTap: () {
                        setState(() {
                          selectedProjectId = project.id;
                          selectedPhaseId = null; // Reset phase selection
                        });
                        Navigator.pop(context);
                        // Update URL to reflect selected project
                        context.go('/tasks/${project.id}');
                      },
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          NeumorphicContainer(
                            padding: EdgeInsets.all(8.w),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected 
                                ? CustomNeumorphicTheme.primaryPurple 
                                : CustomNeumorphicTheme.lightText,
                            child: Icon(
                              Icons.work,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.title,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: CustomNeumorphicTheme.darkText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (project.phases.isNotEmpty) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${project.phases.length} phases',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: CustomNeumorphicTheme.lightText,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: CustomNeumorphicTheme.primaryPurple,
                              size: 20.sp,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      NeumorphicButton(
        onPressed: () => context.push('/profile'),
        borderRadius: BorderRadius.circular(25),
        padding: EdgeInsets.all(8.w),
        child: Icon(
          Icons.person,
          color: CustomNeumorphicTheme.primaryPurple,
          size: 20.sp,
        ),
      ),
      SizedBox(width: 16.w),
    ];
  }

  void _showDeleteProjectDialog(String projectId) {
    final projectsAsync = ref.read(projectNotifierProvider);
    Project? project;
    
    projectsAsync.whenData((projects) {
      project = projects.firstWhere((p) => p.id == projectId, orElse: () => projects.first);
    });
    
    if (project == null) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CustomNeumorphicTheme.baseColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: CustomNeumorphicTheme.errorRed,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Delete Project',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "${project!.title}"?',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: CustomNeumorphicTheme.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: CustomNeumorphicTheme.errorRed.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This action cannot be undone. This will permanently:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: CustomNeumorphicTheme.errorRed,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '• Delete the project\n• Delete all ${project!.phases.length} phases\n• Delete all tasks\n• Remove all project data',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: CustomNeumorphicTheme.errorRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            NeumorphicButton(
              onPressed: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(8.r),
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            NeumorphicButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProject(projectId);
              },
              isSelected: true,
              selectedColor: CustomNeumorphicTheme.errorRed,
              borderRadius: BorderRadius.circular(8.r),
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              child: Text(
                'Delete Project',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteProject(String projectId) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12.w),
              Text('Deleting project...'),
            ],
          ),
          backgroundColor: CustomNeumorphicTheme.primaryPurple,
          duration: Duration(seconds: 2),
        ),
      );

      // Delete the project
      await ref.read(projectNotifierProvider.notifier).deleteProject(projectId);
      
      if (mounted) {
        // Hide loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        
        // Navigate back to dashboard
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete project: $e'),
            backgroundColor: CustomNeumorphicTheme.errorRed,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Helper methods for new dashboard-style layout
  int _getTotalTasks(Project project) {
    return project.phases.fold<int>(
      0, 
      (sum, phase) => sum + phase.tasks.length
    );
  }

  List<Task> _getFilteredTasks(Project project) {
    if (selectedPhaseId == null) {
      return project.phases.expand((phase) => phase.tasks).toList();
    }
    
    final selectedPhase = project.phases.firstWhere(
      (phase) => phase.id == selectedPhaseId,
      orElse: () => project.phases.first,
    );
    
    return selectedPhase.tasks;
  }

  Widget _buildProjectContextButton(Project project) {
    final contextAsync = ref.watch(projectContextNotifierProvider(project.id));
    
    return contextAsync.when(
      data: (projectContext) {
        final hasContext = projectContext?.hasContent ?? false;
        final itemCount = projectContext?.totalItems ?? 0;
        
        return SizedBox(
          width: 56.w,
          height: 56.h,
          child: NeumorphicButton(
            onPressed: () => context.push(
              '/project-context/${project.id}?title=${Uri.encodeComponent(project.title)}',
            ),
            borderRadius: BorderRadius.circular(8.r),
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Icon(
                      Icons.library_books_outlined,
                      color: CustomNeumorphicTheme.primaryPurple,
                      size: 16.sp,
                    ),
                    if (hasContext && itemCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: CustomNeumorphicTheme.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 14.w,
                            minHeight: 14.w,
                          ),
                          child: Text(
                            itemCount > 9 ? '9+' : itemCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'Context',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: CustomNeumorphicTheme.primaryPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => NeumorphicButton(
        onPressed: null,
        borderRadius: BorderRadius.circular(8.r),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16.sp,
              height: 16.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  CustomNeumorphicTheme.lightText,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Context',
              style: TextStyle(
                fontSize: 10.sp,
                color: CustomNeumorphicTheme.lightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => NeumorphicButton(
        onPressed: () => context.push(
          '/project-context/${project.id}?title=${Uri.encodeComponent(project.title)}',
        ),
        borderRadius: BorderRadius.circular(8.r),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_books_outlined,
              color: CustomNeumorphicTheme.lightText,
              size: 16.sp,
            ),
            SizedBox(height: 2.h),
            Text(
              'Context',
              style: TextStyle(
                fontSize: 10.sp,
                color: CustomNeumorphicTheme.lightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(Project project) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        project: project,
        onTaskAdded: (task, phaseId) => _addTaskToProject(project, task, phaseId),
      ),
    );
  }

  void _addTaskToProject(Project project, Task newTask, String phaseId) async {
    try {
      // Find the target phase and add the task
      final updatedPhases = project.phases.map((phase) {
        if (phase.id == phaseId) {
          return ProjectPhase(
            id: phase.id,
            name: phase.name,
            description: phase.description,
            tasks: [...phase.tasks, newTask],
            status: phase.status,
            startDate: phase.startDate,
            endDate: phase.endDate,
          );
        }
        return phase;
      }).toList();

      final updatedProject = project.copyWith(
        phases: updatedPhases,
      );

      // Update the project in the provider (saves to database)
      await ref.read(projectNotifierProvider.notifier).updateProject(updatedProject);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${newTask.title}" added successfully'),
          backgroundColor: CustomNeumorphicTheme.primaryPurple,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add task: $e'),
          backgroundColor: CustomNeumorphicTheme.errorRed,
        ),
      );
    }
  }

  void _showTaskDetailsDialog(Task task, Project project) {
    // Implementation for task details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            SizedBox(height: 16.h),
            Text('Status: ${task.status.name}'),
            Text('Priority: ${task.priority.name}'),
            if (task.estimatedHours > 0)
              Text('Estimated: ${task.estimatedHours}h'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to task edit screen
            },
            child: Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProjectTitle(Project selectedProject) {
    if (_isEditingProjectName) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CustomNeumorphicTheme.baseColor,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: CustomNeumorphicTheme.darkShadow.withValues(alpha: 0.2),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                controller: _projectNameController,
                autofocus: true,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  hintText: 'Enter project name',
                ),
                onSubmitted: (value) => _saveProjectName(selectedProject, value),
                maxLines: 1,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Save button
          NeumorphicButton(
            onPressed: () => _saveProjectName(selectedProject, _projectNameController.text),
            isSelected: true,
            selectedColor: CustomNeumorphicTheme.primaryPurple,
            borderRadius: BorderRadius.circular(8.r),
            padding: EdgeInsets.zero,
            child: Container(
              width: 34.w,
              height: 34.w,
              alignment: Alignment.center,
              child: Icon(
                Icons.check,
                size: 18.sp,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          // Cancel button
          NeumorphicButton(
            onPressed: _cancelEditingProjectName,
            borderRadius: BorderRadius.circular(8.r),
            padding: EdgeInsets.zero,
            child: Container(
              width: 34.w,
              height: 34.w,
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                size: 18.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _startEditingProjectName(selectedProject),
              child: Text(
                selectedProject.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Edit options button with label
          SizedBox(
            width: 56.w,
            height: 56.h,
            child: NeumorphicButton(
              onPressed: () => _showProjectOptionsMenu(selectedProject),
              borderRadius: BorderRadius.circular(8.r),
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 16.sp,
                    color: CustomNeumorphicTheme.primaryPurple,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: CustomNeumorphicTheme.primaryPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  void _startEditingProjectName(Project project) {
    setState(() {
      _isEditingProjectName = true;
      _projectNameController.text = project.title;
    });
  }

  void _cancelEditingProjectName() {
    setState(() {
      _isEditingProjectName = false;
      _projectNameController.clear();
    });
  }

  void _showProjectOptionsMenu(Project project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NeumorphicContainer(
        margin: EdgeInsets.all(16.w),
        borderRadius: BorderRadius.circular(20.r),
        color: CustomNeumorphicTheme.cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
              decoration: BoxDecoration(
                color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Options',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    project.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.lightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: NeumorphicContainer(
                padding: EdgeInsets.all(8.w),
                borderRadius: BorderRadius.circular(10.r),
                color: CustomNeumorphicTheme.primaryPurple,
                child: Icon(Icons.edit, color: Colors.white, size: 20.sp),
              ),
              title: Text(
                'Edit Project Name',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Change the project title',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _startEditingProjectName(project);
              },
            ),
            ListTile(
              leading: NeumorphicContainer(
                padding: EdgeInsets.all(8.w),
                borderRadius: BorderRadius.circular(10.r),
                color: CustomNeumorphicTheme.errorRed,
                child: Icon(Icons.delete_outline, color: Colors.white, size: 20.sp),
              ),
              title: Text(
                'Delete Project',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.errorRed,
                ),
              ),
              subtitle: Text(
                'Permanently delete this project',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteProjectDialog(project.id);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _saveProjectName(Project project, String newName) async {
    if (newName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project name cannot be empty'),
          backgroundColor: CustomNeumorphicTheme.errorRed,
        ),
      );
      return;
    }

    if (newName.trim() == project.title) {
      // No change, just cancel editing
      _cancelEditingProjectName();
      return;
    }

    try {
      // Create updated project with new title
      final updatedProject = project.copyWith(
        title: newName.trim(),
      );

      // Update the project in the provider (which saves to database)
      await ref.read(projectNotifierProvider.notifier).updateProject(updatedProject);

      setState(() {
        _isEditingProjectName = false;
        _projectNameController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project name updated successfully'),
          backgroundColor: CustomNeumorphicTheme.primaryPurple,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update project name: $e'),
          backgroundColor: CustomNeumorphicTheme.errorRed,
        ),
      );
    }
  }

  void _updateTaskStatus(Task task, TaskStatus newStatus, Project project) {
    // Implementation for updating task status
    setState(() {
      // Update task status logic would go here
      // This would integrate with the existing project provider
    });
  }

  void _showPhaseManagementDialog(Project project) {
    showDialog(
      context: context,
      builder: (context) => PhaseManagementDialog(
        project: project,
        onPhasesUpdated: (updatedProject) => _updateProject(updatedProject),
      ),
    );
  }

  Future<void> _updateProject(Project updatedProject) async {
    try {
      await ref.read(projectNotifierProvider.notifier).updateProject(updatedProject);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text('Project updated successfully'),
            ],
          ),
          backgroundColor: CustomNeumorphicTheme.primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          margin: EdgeInsets.all(16.w),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text('Failed to update project: $e'),
            ],
          ),
          backgroundColor: CustomNeumorphicTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          margin: EdgeInsets.all(16.w),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Compact Design Helper Methods

  Widget _buildProjectStatChip({
    required IconData icon,
    required String label,
    required String sublabel,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.sp,
            color: CustomNeumorphicTheme.primaryPurple,
          ),
          SizedBox(width: 4.w),
          RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: CustomNeumorphicTheme.primaryPurple,
              ),
              children: [
                TextSpan(
                  text: ' $sublabel',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectStatusChip(ProjectStatus status) {
    final statusInfo = _getProjectStatusInfo(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: statusInfo['color'].withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: statusInfo['color'],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            statusInfo['label'],
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: statusInfo['color'],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactContextButton(Project project) {
    final contextAsync = ref.watch(projectContextNotifierProvider(project.id));
    
    return contextAsync.when(
      data: (projectContext) {
        final hasContext = projectContext?.hasContent ?? false;
        final itemCount = projectContext?.totalItems ?? 0;
        
        return NeumorphicButton(
          onPressed: () => context.push(
            '/project-context/${project.id}?title=${Uri.encodeComponent(project.title)}',
          ),
          borderRadius: BorderRadius.circular(10.r),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 14.sp,
                    color: CustomNeumorphicTheme.primaryPurple,
                  ),
                  if (hasContext && itemCount > 0)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: CustomNeumorphicTheme.primaryPurple,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CustomNeumorphicTheme.cardColor,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            itemCount > 9 ? '9+' : itemCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 6.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  'Context',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.primaryPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => NeumorphicButton(
        onPressed: null,
        borderRadius: BorderRadius.circular(10.r),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14.sp,
              height: 14.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  CustomNeumorphicTheme.lightText,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                'Context',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.lightText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => NeumorphicButton(
        onPressed: () => context.push(
          '/project-context/${project.id}?title=${Uri.encodeComponent(project.title)}',
        ),
        borderRadius: BorderRadius.circular(10.r),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 14.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                'Context',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.lightText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProjectStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return CustomNeumorphicTheme.primaryPurple;
      case ProjectStatus.inProgress:
        return CustomNeumorphicTheme.primaryPurple;
      case ProjectStatus.completed:
        return CustomNeumorphicTheme.successGreen;
      case ProjectStatus.onHold:
        return Colors.orange;
      case ProjectStatus.cancelled:
        return CustomNeumorphicTheme.errorRed;
    }
  }

  Map<String, dynamic> _getProjectStatusInfo(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return {'label': 'Planning', 'color': CustomNeumorphicTheme.primaryPurple};
      case ProjectStatus.inProgress:
        return {'label': 'In Progress', 'color': CustomNeumorphicTheme.primaryPurple};
      case ProjectStatus.completed:
        return {'label': 'Completed', 'color': CustomNeumorphicTheme.successGreen};
      case ProjectStatus.onHold:
        return {'label': 'On Hold', 'color': Colors.orange};
      case ProjectStatus.cancelled:
        return {'label': 'Cancelled', 'color': CustomNeumorphicTheme.errorRed};
    }
  }
}

class AddTaskDialog extends StatefulWidget {
  final Project project;
  final Function(Task, String) onTaskAdded;

  const AddTaskDialog({
    required this.project,
    required this.onTaskAdded,
    super.key,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedHoursController = TextEditingController();

  TaskStatus _selectedStatus = TaskStatus.todo;
  Priority _selectedPriority = Priority.medium;
  String? _selectedPhaseId;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    // Default to first phase if available
    if (widget.project.phases.isNotEmpty) {
      _selectedPhaseId = widget.project.phases.first.id;
    }
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
                      Icons.add_task,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Add New Task',
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

                      // Phase Selection
                      _buildPhaseDropdown(),
                      SizedBox(height: 16.h),

                      // Status and Priority Row
                      Row(
                        children: [
                          Expanded(child: _buildStatusDropdown()),
                          SizedBox(width: 12.w),
                          Expanded(child: _buildPriorityDropdown()),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Estimated Hours and Due Date Row
                      Row(
                        children: [
                          Expanded(child: _buildEstimatedHoursField()),
                          SizedBox(width: 12.w),
                          Expanded(child: _buildDueDateField()),
                        ],
                      ),
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
                    onPressed: _addTask,
                    isSelected: true,
                    selectedColor: CustomNeumorphicTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(12.r),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Text(
                      'Add Task',
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
            style: TextStyle(
              fontSize: 14.sp,
              color: CustomNeumorphicTheme.darkText,
            ),
            maxLines: maxLines,
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

  void _selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDueDate = selectedDate;
      });
    }
  }

  void _addTask() {
    if (_formKey.currentState!.validate() && _selectedPhaseId != null) {
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
        estimatedHours: double.tryParse(_estimatedHoursController.text) ?? 0.0,
        actualHours: 0.0,
        comments: [],
      );

      widget.onTaskAdded(newTask, _selectedPhaseId!);
      Navigator.of(context).pop();
    }
  }
}

class PhaseManagementDialog extends StatefulWidget {
  final Project project;
  final Function(Project) onPhasesUpdated;

  const PhaseManagementDialog({
    required this.project,
    required this.onPhasesUpdated,
    super.key,
  });

  @override
  State<PhaseManagementDialog> createState() => _PhaseManagementDialogState();
}

class _PhaseManagementDialogState extends State<PhaseManagementDialog> {
  late List<ProjectPhase> phases;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    phases = List.from(widget.project.phases);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16.w),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
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
            // Header - Cleaner Design
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: CustomNeumorphicTheme.baseColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: CustomNeumorphicTheme.primaryPurple,
                    ),
                    child: Icon(
                      Icons.view_module_outlined,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Manage Phases',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  Text(
                    'Long press to reorder',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: CustomNeumorphicTheme.lightText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  NeumorphicButton(
                    onPressed: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(8.r),
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.close,
                      color: CustomNeumorphicTheme.lightText,
                      size: 14.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Phases List
            Flexible(
              child: phases.isEmpty ? _buildEmptyState() : _buildPhasesList(),
            ),

            // Footer Actions - Cleaner Design
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: CustomNeumorphicTheme.baseColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
                border: Border(
                  top: BorderSide(
                    color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: NeumorphicButton(
                      onPressed: _addNewPhase,
                      isSelected: true,
                      selectedColor: CustomNeumorphicTheme.primaryPurple,
                      borderRadius: BorderRadius.circular(10.r),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'Add Phase',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: NeumorphicButton(
                      onPressed: _saveChanges,
                      borderRadius: BorderRadius.circular(10.r),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, color: CustomNeumorphicTheme.primaryPurple, size: 16.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'Save Changes',
                            style: TextStyle(
                              color: CustomNeumorphicTheme.primaryPurple,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.view_module_outlined,
              size: 28.sp,
              color: CustomNeumorphicTheme.primaryPurple,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'No Phases Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: CustomNeumorphicTheme.darkText,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Add phases to organize your project tasks',
            style: TextStyle(
              fontSize: 14.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhasesList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: phases.length,
      onReorder: _reorderPhases,
      buildDefaultDragHandles: false, // Disable default drag handles
      itemBuilder: (context, index) {
        final phase = phases[index];
        final taskCount = phase.tasks.length;
        
        return ReorderableDragStartListener(
          key: ValueKey(phase.id),
          index: index,
          child: Container(
            margin: EdgeInsets.only(bottom: 8.h),
            child: NeumorphicCard(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  // Phase Number Indicator
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: _getPhaseStatusColor(phase.status),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  
                  // Phase Info - Takes most space
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phase.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: CustomNeumorphicTheme.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (taskCount > 0) ...[
                          SizedBox(height: 2.h),
                          Text(
                            '$taskCount task${taskCount == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: CustomNeumorphicTheme.lightText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  SizedBox(width: 16.w), // More generous spacing
                  
                  // Action Buttons - Larger and more accessible
                  NeumorphicButton(
                    onPressed: () => _editPhase(index),
                    borderRadius: BorderRadius.circular(8.r),
                    padding: EdgeInsets.all(8.w),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16.sp,
                      color: CustomNeumorphicTheme.primaryPurple,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  NeumorphicButton(
                    onPressed: taskCount > 0 ? null : () => _deletePhase(index),
                    borderRadius: BorderRadius.circular(8.r),
                    padding: EdgeInsets.all(8.w),
                    child: Icon(
                      Icons.delete_outline,
                      size: 16.sp,
                      color: taskCount > 0 
                        ? CustomNeumorphicTheme.lightText.withValues(alpha: 0.4)
                        : CustomNeumorphicTheme.errorRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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

  void _reorderPhases(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final phase = phases.removeAt(oldIndex);
      phases.insert(newIndex, phase);
    });
  }

  void _addNewPhase() {
    _showPhaseEditDialog();
  }

  void _editPhase(int index) {
    _showPhaseEditDialog(phase: phases[index], index: index);
  }

  void _deletePhase(int index) {
    final phase = phases[index];
    final taskCount = phase.tasks.length;
    
    if (taskCount > 0) {
      _showCannotDeleteDialog(phase, taskCount);
      return;
    }
    
    _showDeleteConfirmationDialog(index);
  }

  void _showCannotDeleteDialog(ProjectPhase phase, int taskCount) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: CustomNeumorphicTheme.baseColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: CustomNeumorphicTheme.bottomEdgeShadow.withValues(alpha: 0.2),
                offset: const Offset(2, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeumorphicContainer(
                padding: EdgeInsets.all(12.w),
                borderRadius: BorderRadius.circular(15.r),
                color: Colors.orange.withValues(alpha: 0.1),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Cannot Delete Phase',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'The phase "${phase.name}" has $taskCount task${taskCount == 1 ? '' : 's'} assigned to it.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: CustomNeumorphicTheme.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Please move or delete the tasks first before deleting this phase.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              NeumorphicButton(
                onPressed: () => Navigator.of(context).pop(),
                isSelected: true,
                selectedColor: CustomNeumorphicTheme.primaryPurple,
                borderRadius: BorderRadius.circular(12.r),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                child: Text(
                  'Got it',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    final phase = phases[index];
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: CustomNeumorphicTheme.baseColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: CustomNeumorphicTheme.bottomEdgeShadow.withValues(alpha: 0.2),
                offset: const Offset(2, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeumorphicContainer(
                padding: EdgeInsets.all(12.w),
                borderRadius: BorderRadius.circular(15.r),
                color: CustomNeumorphicTheme.errorRed.withValues(alpha: 0.1),
                child: Icon(
                  Icons.delete_outline,
                  color: CustomNeumorphicTheme.errorRed,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Delete Phase?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Are you sure you want to delete "${phase.name}"?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: CustomNeumorphicTheme.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: NeumorphicButton(
                      onPressed: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(12.r),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: CustomNeumorphicTheme.lightText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: NeumorphicButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          phases.removeAt(index);
                        });
                      },
                      isSelected: true,
                      selectedColor: CustomNeumorphicTheme.errorRed,
                      borderRadius: BorderRadius.circular(12.r),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhaseEditDialog({ProjectPhase? phase, int? index}) {
    final isEditing = phase != null;
    final nameController = TextEditingController(text: phase?.name ?? '');
    final descriptionController = TextEditingController(text: phase?.description ?? '');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.w),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: CustomNeumorphicTheme.baseColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: CustomNeumorphicTheme.bottomEdgeShadow.withValues(alpha: 0.2),
                offset: const Offset(2, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Phase' : 'Add New Phase',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
              SizedBox(height: 20.h),
              
              // Phase Name
              Text(
                'Phase Name *',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
              SizedBox(height: 8.h),
              NeumorphicContainer(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                borderRadius: BorderRadius.circular(12.r),
                color: CustomNeumorphicTheme.baseColor,
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter phase name',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: CustomNeumorphicTheme.lightText,
                      fontSize: 14.sp,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              
              // Phase Description
              Text(
                'Description (Optional)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
              SizedBox(height: 8.h),
              NeumorphicContainer(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                borderRadius: BorderRadius.circular(12.r),
                color: CustomNeumorphicTheme.baseColor,
                child: TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter phase description',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: CustomNeumorphicTheme.lightText,
                      fontSize: 14.sp,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: NeumorphicButton(
                      onPressed: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(12.r),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: CustomNeumorphicTheme.lightText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: NeumorphicButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          return;
                        }
                        
                        final newPhase = ProjectPhase(
                          id: phase?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          tasks: phase?.tasks ?? [],
                          status: phase?.status ?? PhaseStatus.notStarted,
                          startDate: phase?.startDate,
                          endDate: phase?.endDate,
                        );
                        
                        setState(() {
                          if (isEditing && index != null) {
                            phases[index] = newPhase;
                          } else {
                            phases.add(newPhase);
                          }
                        });
                        
                        Navigator.of(context).pop();
                      },
                      isSelected: true,
                      selectedColor: CustomNeumorphicTheme.primaryPurple,
                      borderRadius: BorderRadius.circular(12.r),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Text(
                        isEditing ? 'Update' : 'Add Phase',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() {
    final updatedProject = widget.project.copyWith(phases: phases);
    widget.onPhasesUpdated(updatedProject);
    Navigator.of(context).pop();
  }
}