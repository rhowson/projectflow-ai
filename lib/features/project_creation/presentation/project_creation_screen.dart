import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../providers/project_provider.dart';

class ProjectCreationScreen extends ConsumerStatefulWidget {
  const ProjectCreationScreen({super.key});

  @override
  ConsumerState<ProjectCreationScreen> createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends ConsumerState<ProjectCreationScreen> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectNotifierProvider);
    
    return Scaffold(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      appBar: NeumorphicAppBar(
        title: Text(
          'Create New Project',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        automaticallyImplyLeading: true,
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
      body: LoadingOverlay(
        isLoading: projectState.isLoading,
        loadingMessage: 'Analyzing your project with AI...',
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8.h),
                
                // Header Card - Flat styling
                NeumorphicFlatContainer(
                  padding: EdgeInsets.all(20.w),
                  color: CustomNeumorphicTheme.baseColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          NeumorphicContainer(
                            padding: EdgeInsets.all(12.w),
                            borderRadius: BorderRadius.circular(12),
                            color: CustomNeumorphicTheme.primaryPurple,
                            child: Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Describe your project',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: CustomNeumorphicTheme.darkText,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'AI-powered project planning',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: CustomNeumorphicTheme.lightText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Tell me about your project. What do you want to accomplish? The more details you provide, the better I can help you plan it.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CustomNeumorphicTheme.lightText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20.h),
                
                // Text Input Card
                NeumorphicCard(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project Description',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: CustomNeumorphicTheme.darkText,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildNeumorphicTextField(),
                    ],
                  ),
                ),
                
                SizedBox(height: 20.h),
                // Error Card
                if (projectState.hasError) ...[
                  NeumorphicCard(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        NeumorphicContainer(
                          padding: EdgeInsets.all(8.w),
                          borderRadius: BorderRadius.circular(8),
                          color: CustomNeumorphicTheme.errorRed,
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Error: ${projectState.error}',
                            style: TextStyle(
                              color: CustomNeumorphicTheme.errorRed,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: NeumorphicButton(
                        onPressed: () => context.pop(),
                        borderRadius: BorderRadius.circular(12),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close, size: 18.sp, color: CustomNeumorphicTheme.lightText),
                            SizedBox(width: 8.w),
                            Text(
                              'Cancel',
                              style: TextStyle(
                                color: CustomNeumorphicTheme.lightText,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      flex: 2,
                      child: NeumorphicButton(
                        onPressed: projectState.isLoading ? null : _createProject,
                        isSelected: true,
                        selectedColor: CustomNeumorphicTheme.primaryPurple,
                        borderRadius: BorderRadius.circular(12),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (projectState.isLoading) ...[
                              SizedBox(
                                width: 16.sp,
                                height: 16.sp,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 8.w),
                            ] else ...[
                              Icon(Icons.psychology, size: 18.sp, color: Colors.white),
                              SizedBox(width: 8.w),
                            ],
                            Text(
                              projectState.isLoading ? 'Analyzing...' : 'Analyze Project',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeumorphicTextField() {
    return Container(
      decoration: BoxDecoration(
        color: CustomNeumorphicTheme.baseColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CustomNeumorphicTheme.darkShadow.withOpacity(0.2),
            offset: const Offset(1, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 8,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: 14.sp,
          color: CustomNeumorphicTheme.darkText,
          height: 1.4,
        ),
        decoration: InputDecoration(
          hintText: '''Example: I want to build a mobile app for tracking fitness goals. Users should be able to set workout plans, track their progress, and share achievements with friends. The app should work on both iOS and Android, and include features like:

• User registration and profiles
• Workout planning and tracking
• Progress analytics
• Social sharing
• Push notifications for reminders

I have a design team but need help with the technical planning and development phases.''',
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: CustomNeumorphicTheme.subtleText,
            height: 1.4,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: CustomNeumorphicTheme.primaryPurple,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: CustomNeumorphicTheme.errorRed,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: CustomNeumorphicTheme.errorRed,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(16.w),
          filled: true,
          fillColor: Colors.transparent,
          alignLabelWithHint: true,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please describe your project';
          }
          if (value.trim().length < 50) {
            return 'Please provide more details (at least 50 characters)';
          }
          return null;
        },
      ),
    );
  }

  void _createProject() async {
    print('_createProject method called!');
    
    // Show immediate feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Button clicked! Starting analysis...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
    
    if (_formKey.currentState!.validate()) {
      print('Form is valid, proceeding...');
      try {
        await ref.read(projectNotifierProvider.notifier)
            .createProject(_descriptionController.text.trim());
        
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project analyzed successfully! Ready for planning.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to dashboard to see the new project
          context.pop();
        }
      } catch (e) {
        print('Error in _createProject: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error analyzing project: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('Form validation failed');
    }
  }
}