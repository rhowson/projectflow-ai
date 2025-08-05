import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/widgets/keyboard_dismissible_wrapper.dart';
import '../../../shared/widgets/keyboard_dismiss_button.dart';
import '../../../core/services/document_service.dart';
import '../providers/project_provider.dart';

class ProjectCreationScreen extends ConsumerStatefulWidget {
  const ProjectCreationScreen({super.key});

  @override
  ConsumerState<ProjectCreationScreen> createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends ConsumerState<ProjectCreationScreen> 
    with SingleTickerProviderStateMixin {
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();
  DocumentUploadResult? _uploadedDocument;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Start subtle pulse animation after a brief delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && _uploadedDocument == null) {
        _animationController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          style: Theme.of(context).textTheme.headlineSmall,
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
      body: KeyboardDismissibleWrapper(
        child: LoadingOverlay(
          isLoading: projectState.isLoading,
          loadingMessage: 'Analyzing your project with AI...',
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.h),
                
                // Header Section - Dashboard style
                _buildCleanHeaderSection(context),
                
                SizedBox(height: 24.h),
                
                // Text Input Section - Matching dashboard style
                _buildInputSection(context),
                
                SizedBox(height: 24.h),
                
                // Error Section
                if (projectState.hasError) ...[ 
                  _buildErrorSection(context, projectState.error.toString()),
                  SizedBox(height: 24.h),
                ],
                
                // Action Buttons Section
                _buildActionButtons(context, projectState),
                SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCleanHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Clean header matching dashboard style
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 16.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Describe your project',
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // AI indicator badge
              NeumorphicContainer(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                borderRadius: BorderRadius.circular(16.r),
                color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      size: 13.sp,
                      color: CustomNeumorphicTheme.primaryPurple,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'AI-Powered',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
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
        // Subtitle description
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 16.h),
          child: Text(
            'Tell me about your project. What do you want to accomplish? The more details you provide, the better I can help you plan it.',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: CustomNeumorphicTheme.lightText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 16.h),
          child: Text(
            'Project Description',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        NeumorphicCard(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              _buildNeumorphicTextField(),
              if (_uploadedDocument != null) ...[
                SizedBox(height: 16.h),
                _buildUploadedDocumentDisplay(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection(BuildContext context, String error) {
    return NeumorphicCard(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          NeumorphicContainer(
            padding: EdgeInsets.all(10.w),
            borderRadius: BorderRadius.circular(12.r),
            color: CustomNeumorphicTheme.errorRed,
            child: Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Error',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: CustomNeumorphicTheme.errorRed,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  error,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: CustomNeumorphicTheme.errorRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AsyncValue projectState) {
    return Row(
      children: [
        Expanded(
          child: NeumorphicButton(
            onPressed: _clearForm,
            borderRadius: BorderRadius.circular(12.r),
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.clear_all, size: 16.sp, color: CustomNeumorphicTheme.lightText),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'Clear',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: CustomNeumorphicTheme.lightText,
                    ),
                    overflow: TextOverflow.ellipsis,
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
            borderRadius: BorderRadius.circular(12.r),
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
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
                  Icon(Icons.psychology_outlined, size: 16.sp, color: Colors.white),
                  SizedBox(width: 8.w),
                ],
                Flexible(
                  child: Text(
                    projectState.isLoading ? 'Creating Project...' : 'Create Project',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
      child: Stack(
        children: [
          TextFormField(
            controller: _descriptionController,
            maxLines: 8,
            textAlignVertical: TextAlignVertical.top,
            style: Theme.of(context).textTheme.bodyLarge,
            onTapOutside: (event) {
              // Hide keyboard when tapping outside
              context.dismissKeyboard();
            },
            onEditingComplete: () {
              // Hide keyboard when user finishes editing
              context.dismissKeyboard();
            },
            decoration: InputDecoration(
          hintText: '''Example: I want to build a mobile app for tracking fitness goals. Users should be able to set workout plans, track their progress, and share achievements with friends. The app should work on both iOS and Android, and include features like:

• User registration and profiles
• Workout planning and tracking
• Progress analytics
• Social sharing
• Push notifications for reminders

I have a design team but need help with the technical planning and development phases.''',
          hintStyle: Theme.of(context).textTheme.bodyMedium,
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
          contentPadding: EdgeInsets.only(
            left: 16.w,
            right: 60.w, // Extra space for upload buttons
            top: 16.h,
            bottom: 16.h,
          ),
          filled: true,
          fillColor: Colors.transparent,
          alignLabelWithHint: true,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty && _uploadedDocument == null) {
            return 'Please describe your project or upload a document';
          }
          if ((value?.trim().length ?? 0) < 10 && _uploadedDocument == null) {
            return 'Please provide more details or upload a document';
          }
          return null;
        },
      ),
      // Upload buttons positioned in top-right corner
      Positioned(
        top: 6.h,
        right: 6.w,
        child: _buildUploadButtons(),
      ),
    ],
  ),
);
  }

  Widget _buildUploadButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildUploadButton(
          icon: Icons.attach_file,
          tooltip: 'Upload PDF or Word document',
          onPressed: _uploadDocument,
          isProminent: true,
        ),
        SizedBox(width: 6.w),
        if (_uploadedDocument != null)
          _buildUploadButton(
            icon: Icons.close,
            tooltip: 'Remove document',
            onPressed: _removeDocument,
            color: CustomNeumorphicTheme.errorRed,
          ),
      ],
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
    bool isProminent = false,
  }) {
    Widget button = Tooltip(
      message: tooltip,
      child: NeumorphicButton(
        onPressed: onPressed,
        isSelected: isProminent,
        selectedColor: isProminent ? CustomNeumorphicTheme.primaryPurple : null,
        borderRadius: BorderRadius.circular(isProminent ? 8.r : 6.r),
        padding: EdgeInsets.all(isProminent ? 8.w : 6.w),
        child: Icon(
          icon,
          size: isProminent ? 18.sp : 14.sp,
          color: isProminent 
              ? Colors.white
              : (color ?? CustomNeumorphicTheme.lightText),
        ),
      ),
    );

    // Add subtle animation for prominent upload button
    if (isProminent && _uploadedDocument == null) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: button,
          );
        },
      );
    }

    return button;
  }

  Widget _buildUploadedDocumentDisplay() {
    if (_uploadedDocument == null) return const SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: CustomNeumorphicTheme.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: CustomNeumorphicTheme.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(_uploadedDocument!.fileExtension),
            size: 16.sp,
            color: CustomNeumorphicTheme.primaryPurple,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _uploadedDocument!.fileName,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.primaryPurple,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_uploadedDocument!.formattedSize} • Document uploaded',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _removeDocument,
            icon: Icon(
              Icons.close,
              size: 16.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
            constraints: BoxConstraints(
              minWidth: 24.w,
              minHeight: 24.h,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'txt':
        return Icons.text_snippet_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  void _uploadDocument() async {
    // Hide keyboard first
    FocusScope.of(context).unfocus();
    
    try {
      final documentService = ref.read(documentServiceProvider);
      final result = await documentService.pickAndValidateDocument();
      
      if (result != null) {
        setState(() {
          _uploadedDocument = result;
        });
        
        // Stop the pulse animation since document is now uploaded
        _animationController.stop();
        _animationController.reset();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document "${result.fileName}" uploaded successfully'),
            backgroundColor: CustomNeumorphicTheme.primaryPurple,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: ${e.toString()}'),
          backgroundColor: CustomNeumorphicTheme.errorRed,
        ),
      );
    }
  }

  void _removeDocument() {
    // Hide keyboard first
    FocusScope.of(context).unfocus();
    
    setState(() {
      _uploadedDocument = null;
    });
    
    // Restart the pulse animation since no document is uploaded
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _uploadedDocument == null) {
        _animationController.repeat(reverse: true);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document removed'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  void _clearForm() {
    print('Clear form button pressed'); // Debug log
    
    // Hide keyboard first
    context.dismissKeyboard();
    
    // Clear form validation first
    _formKey.currentState?.reset();
    
    // Then clear the text controller
    _descriptionController.clear();
    
    // Force a rebuild to ensure changes are reflected
    setState(() {
      // Remove uploaded document if exists
      _uploadedDocument = null;
    });
    
    // Restart the pulse animation since no document is uploaded
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _uploadedDocument == null) {
        _animationController.repeat(reverse: true);
      }
    });
    
    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form cleared'),
        backgroundColor: Colors.grey,
        duration: Duration(milliseconds: 700),
      ),
    );
    
    print('Text controller value after clear: "${_descriptionController.text}"'); // Debug log
  }

  void _createProject() async {
    print('_createProject method called!');
    
    // Hide keyboard first
    context.dismissKeyboard();
    
    if (_formKey.currentState!.validate()) {
      print('Form is valid, proceeding to context gathering...');
      
      // Navigate to context screen with project description, document content, and document result
      context.push('/project-context', extra: {
        'projectDescription': _descriptionController.text.trim(),
        'documentContent': _uploadedDocument?.content,
        'documentUploadResult': _uploadedDocument, // Pass the full document result
      });
    } else {
      print('Form validation failed');
    }
  }
}