import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../core/models/project_model.dart';
import '../../project_creation/providers/project_provider.dart';
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

  @override
  void initState() {
    super.initState();
    selectedProjectId = widget.projectId;
    selectedPhaseId = widget.phaseId;
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectNotifierProvider);
    
    return Scaffold(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      appBar: NeumorphicAppBar(
        title: Text(
          'Task Management',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
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
        ],
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
          
          return Column(
            children: [
              // Collapsible Project/Phase selector header
              _buildCollapsibleProjectPhaseSelector(projects, selectedProject),
              
              // Task board
              Expanded(
                child: _buildTaskBoard(selectedProject),
              ),
            ],
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
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
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

  Widget _buildCollapsibleProjectPhaseSelector(List<Project> projects, Project selectedProject) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, _isProjectSelectorCollapsed ? 8.w : 16.w),
      child: NeumorphicFlatContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16.r),
        color: CustomNeumorphicTheme.baseColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Always visible: Compact project header with collapse button
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.w, 16.w, 16.w),
              child: Row(
                children: [
                  NeumorphicContainer(
                    padding: EdgeInsets.all(8.w),
                    borderRadius: BorderRadius.circular(10),
                    color: CustomNeumorphicTheme.primaryPurple,
                    child: Icon(
                      Icons.task_alt,
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
                          selectedProject.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: CustomNeumorphicTheme.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (selectedPhaseId != null) ...[ 
                          SizedBox(height: 2.h),
                          Text(
                            selectedProject.phases.firstWhere((p) => p.id == selectedPhaseId).name,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: CustomNeumorphicTheme.lightText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  NeumorphicButton(
                    onPressed: () => _showProjectSelector(projects),
                    borderRadius: BorderRadius.circular(10),
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.swap_horiz,
                      color: CustomNeumorphicTheme.primaryPurple,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  NeumorphicButton(
                    onPressed: () => setState(() => _isProjectSelectorCollapsed = !_isProjectSelectorCollapsed),
                    borderRadius: BorderRadius.circular(10),
                    padding: EdgeInsets.all(6.w),
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: _isProjectSelectorCollapsed ? 0.5 : 0,
                      child: Icon(
                        Icons.expand_more,
                        color: CustomNeumorphicTheme.primaryPurple,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Collapsible content: Phase selector
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isProjectSelectorCollapsed ? 0 : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isProjectSelectorCollapsed ? 0 : 1,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                  child: selectedProject.phases.isNotEmpty ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 1.h,
                        margin: EdgeInsets.only(bottom: 16.h),
                        color: CustomNeumorphicTheme.lightText.withOpacity(0.2),
                      ),
                      Text(
                        'Phase Filter',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: CustomNeumorphicTheme.lightText,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.fromLTRB(0, 8.h, 0, 20.h),
                        child: Row(
                          children: [
                            _buildPhaseChip(
                              'All Phases',
                              selectedPhaseId == null,
                              () => setState(() => selectedPhaseId = null),
                            ),
                            SizedBox(width: 8.w),
                            ...selectedProject.phases.map((phase) => Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: _buildPhaseChip(
                                phase.name,
                                selectedPhaseId == phase.id,
                                () => setState(() => selectedPhaseId = phase.id),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ) : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseChip(String label, bool isSelected, VoidCallback onTap) {
    return NeumorphicButton(
      onPressed: onTap,
      isSelected: isSelected,
      selectedColor: CustomNeumorphicTheme.primaryPurple,
      borderRadius: BorderRadius.circular(20),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : CustomNeumorphicTheme.darkText,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTaskBoard(Project selectedProject) {
    // Filter project based on selected phase
    Project filteredProject = selectedProject;
    
    if (selectedPhaseId != null) {
      final selectedPhase = selectedProject.phases.firstWhere(
        (phase) => phase.id == selectedPhaseId,
        orElse: () => selectedProject.phases.first,
      );
      
      // Create a filtered project with only the selected phase
      filteredProject = Project(
        id: selectedProject.id,
        title: selectedProject.title,
        description: selectedProject.description,
        status: selectedProject.status,
        createdAt: selectedProject.createdAt,
        dueDate: selectedProject.dueDate,
        teamMemberIds: selectedProject.teamMemberIds,
        phases: [selectedPhase],
        metadata: selectedProject.metadata,
      );
    }
    
    // Task board without extra spacing - ResponsiveKanbanBoard has its own margins
    return ResponsiveKanbanBoard(project: filteredProject);
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
}