import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../core/models/project_context_model.dart';
import '../providers/project_context_provider.dart';

class ProjectContextScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String projectTitle;

  const ProjectContextScreen({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  ConsumerState<ProjectContextScreen> createState() => _ProjectContextScreenState();
}

class _ProjectContextScreenState extends ConsumerState<ProjectContextScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contextAsync = ref.watch(projectContextNotifierProvider(widget.projectId));

    return Scaffold(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      appBar: AppBar(
        backgroundColor: CustomNeumorphicTheme.baseColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Context',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              widget.projectTitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: CustomNeumorphicTheme.lightText,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () => _showAddMenu(),
            icon: Icon(
              Icons.add,
              color: CustomNeumorphicTheme.primaryPurple,
              size: 24.sp,
            ),
          ),
        ],
      ),
      body: contextAsync.when(
        data: (context) {
          if (context == null || !context.hasContent) {
            return _buildEmptyState();
          }
          return _buildContextContent(context);
        },
        loading: () => const Center(
          child: LoadingIndicator(message: 'Loading project context...'),
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
                'Error loading context',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8.h),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeumorphicContainer(
              padding: EdgeInsets.all(24.w),
              borderRadius: BorderRadius.circular(30.r),
              color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
              child: Icon(
                Icons.library_books_outlined,
                size: 64.sp,
                color: CustomNeumorphicTheme.primaryPurple,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Context Available',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              'Add context questions and upload documents to help AI generate better tasks and provide project insights.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: CustomNeumorphicTheme.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            NeumorphicButton(
              onPressed: _showAddMenu,
              isSelected: true,
              selectedColor: CustomNeumorphicTheme.primaryPurple,
              borderRadius: BorderRadius.circular(15.r),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Add Context',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
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

  Widget _buildContextContent(ProjectContext context) {
    return Column(
      children: [
        // Summary Section
        if (context.summary != null) ...[
          Padding(
            padding: EdgeInsets.all(20.w),
            child: NeumorphicCard(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16.sp,
                        color: CustomNeumorphicTheme.primaryPurple,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'AI Summary',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: CustomNeumorphicTheme.darkText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    context.summary!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: CustomNeumorphicTheme.darkText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Tab Bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: NeumorphicContainer(
            padding: EdgeInsets.all(4.w),
            borderRadius: BorderRadius.circular(25.r),
            color: CustomNeumorphicTheme.baseColor,
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: CustomNeumorphicTheme.primaryPurple,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: CustomNeumorphicTheme.lightText,
              labelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text('Questions (${context.contextQuestions.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_outlined, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text('Documents (${context.documents.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 20.h),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildQuestionsTab(context.contextQuestions),
              _buildDocumentsTab(context.documents),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsTab(List<ContextQuestion> questions) {
    if (questions.isEmpty) {
      return _buildEmptyTabState(
        icon: Icons.quiz_outlined,
        title: 'No Questions Yet',
        subtitle: 'Context questions help AI understand your project better.',
        buttonText: 'Add Questions',
        onPressed: () => _showAddQuestionDialog(),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: questions.map((question) => _buildQuestionCard(question)).toList(),
      ),
    );
  }

  Widget _buildDocumentsTab(List<ProjectDocument> documents) {
    if (documents.isEmpty) {
      return _buildEmptyTabState(
        icon: Icons.folder_outlined,
        title: 'No Documents Yet',
        subtitle: 'Upload requirements, designs, and reference materials.',
        buttonText: 'Upload Files',
        onPressed: _uploadDocument,
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: documents.map((document) => _buildDocumentCard(document)).toList(),
      ),
    );
  }

  Widget _buildEmptyTabState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CustomNeumorphicTheme.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            NeumorphicButton(
              onPressed: onPressed,
              borderRadius: BorderRadius.circular(12.r),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: CustomNeumorphicTheme.primaryPurple,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(ContextQuestion question) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: NeumorphicCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getQuestionTypeColor(question.type).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    question.type.displayName,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: _getQuestionTypeColor(question.type),
                    ),
                  ),
                ),
                const Spacer(),
                if (question.isRequired)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: CustomNeumorphicTheme.errorRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Required',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: CustomNeumorphicTheme.errorRed,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              question.question,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: CustomNeumorphicTheme.darkText,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              question.answer,
              style: TextStyle(
                fontSize: 13.sp,
                color: CustomNeumorphicTheme.darkText,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(question.answeredAt),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
                const Spacer(),
                NeumorphicButton(
                  onPressed: () => _editQuestion(question),
                  borderRadius: BorderRadius.circular(8.r),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: CustomNeumorphicTheme.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(ProjectDocument document) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: NeumorphicCard(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            NeumorphicContainer(
              padding: EdgeInsets.all(12.w),
              borderRadius: BorderRadius.circular(12.r),
              color: _getDocumentTypeColor(document.type).withValues(alpha: 0.2),
              child: Icon(
                _getDocumentIcon(document.fileExtension),
                color: _getDocumentTypeColor(document.type),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  if (document.description != null) ...[
                    Text(
                      document.description!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: CustomNeumorphicTheme.lightText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                  ],
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _getDocumentTypeColor(document.type).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          document.type.displayName,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: _getDocumentTypeColor(document.type),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${document.formattedSize} • ${_formatDate(document.uploadedAt)}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: CustomNeumorphicTheme.lightText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            NeumorphicButton(
              onPressed: () => _showDocumentOptions(document),
              borderRadius: BorderRadius.circular(8.r),
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.more_vert,
                size: 16.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getQuestionTypeColor(ContextQuestionType type) {
    switch (type) {
      case ContextQuestionType.projectScope:
        return CustomNeumorphicTheme.primaryPurple;
      case ContextQuestionType.technicalRequirements:
        return Colors.blue;
      case ContextQuestionType.timeline:
        return Colors.orange;
      case ContextQuestionType.resources:
        return Colors.green;
      case ContextQuestionType.constraints:
        return Colors.red;
      case ContextQuestionType.other:
        return CustomNeumorphicTheme.lightText;
    }
  }

  Color _getDocumentTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.requirement:
        return Colors.blue;
      case DocumentType.design:
        return Colors.purple;
      case DocumentType.specification:
        return Colors.green;
      case DocumentType.reference:
        return Colors.orange;
      case DocumentType.asset:
        return Colors.teal;
      case DocumentType.other:
        return CustomNeumorphicTheme.lightText;
    }
  }

  IconData _getDocumentIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_file;
      case 'figma':
        return Icons.design_services;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddMenu() {
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
            ListTile(
              leading: NeumorphicContainer(
                padding: EdgeInsets.all(8.w),
                borderRadius: BorderRadius.circular(10.r),
                color: CustomNeumorphicTheme.primaryPurple,
                child: Icon(Icons.quiz, color: Colors.white, size: 20.sp),
              ),
              title: Text(
                'Add Context Question',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Add project details for better AI insights',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAddQuestionDialog();
              },
            ),
            ListTile(
              leading: NeumorphicContainer(
                padding: EdgeInsets.all(8.w),
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.green,
                child: Icon(Icons.upload_file, color: Colors.white, size: 20.sp),
              ),
              title: Text(
                'Upload Document',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Add requirements, designs, or references',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _uploadDocument();
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showAddQuestionDialog() {
    final questionController = TextEditingController();
    final answerController = TextEditingController();
    ContextQuestionType selectedType = ContextQuestionType.other;
    bool isRequired = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: CustomNeumorphicTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.quiz_outlined,
                color: CustomNeumorphicTheme.primaryPurple,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Add Context Question',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question',
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
                  color: CustomNeumorphicTheme.baseColor,
                  child: TextField(
                    controller: questionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Enter your question...',
                      hintStyle: TextStyle(
                        color: CustomNeumorphicTheme.lightText,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Answer',
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
                  color: CustomNeumorphicTheme.baseColor,
                  child: TextField(
                    controller: answerController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Provide a detailed answer...',
                      hintStyle: TextStyle(
                        color: CustomNeumorphicTheme.lightText,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Category',
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
                  color: CustomNeumorphicTheme.baseColor,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ContextQuestionType>(
                      value: selectedType,
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                      dropdownColor: CustomNeumorphicTheme.cardColor,
                      onChanged: (ContextQuestionType? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedType = newValue;
                          });
                        }
                      },
                      items: ContextQuestionType.values.map<DropdownMenuItem<ContextQuestionType>>((ContextQuestionType value) {
                        return DropdownMenuItem<ContextQuestionType>(
                          value: value,
                          child: Row(
                            children: [
                              Container(
                                width: 12.w,
                                height: 12.h,
                                decoration: BoxDecoration(
                                  color: _getQuestionTypeColor(value),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(value.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Checkbox(
                      value: isRequired,
                      onChanged: (bool? value) {
                        setState(() {
                          isRequired = value ?? false;
                        });
                      },
                      activeColor: CustomNeumorphicTheme.primaryPurple,
                    ),
                    Text(
                      'Mark as required',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            NeumorphicButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              borderRadius: BorderRadius.circular(10.r),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: CustomNeumorphicTheme.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            NeumorphicButton(
              onPressed: () async {
                if (questionController.text.trim().isNotEmpty &&
                    answerController.text.trim().isNotEmpty) {
                  Navigator.pop(dialogContext);
                  
                  try {
                    await ref
                        .read(projectContextNotifierProvider(widget.projectId).notifier)
                        .addContextQuestion(
                          questionController.text.trim(),
                          answerController.text.trim(),
                          selectedType,
                          isRequired: isRequired,
                        );
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Question added successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error adding question: $e'),
                          backgroundColor: CustomNeumorphicTheme.errorRed,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in both question and answer'),
                      backgroundColor: CustomNeumorphicTheme.errorRed,
                    ),
                  );
                }
              },
              isSelected: true,
              selectedColor: CustomNeumorphicTheme.primaryPurple,
              borderRadius: BorderRadius.circular(10.r),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                'Add Question',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editQuestion(ContextQuestion question) {
    final questionController = TextEditingController(text: question.question);
    final answerController = TextEditingController(text: question.answer);
    ContextQuestionType selectedType = question.type;
    bool isRequired = question.isRequired;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: CustomNeumorphicTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: CustomNeumorphicTheme.primaryPurple,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Edit Context Question',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question',
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
                  color: CustomNeumorphicTheme.baseColor,
                  child: TextField(
                    controller: questionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Enter your question...',
                      hintStyle: TextStyle(
                        color: CustomNeumorphicTheme.lightText,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Answer',
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
                  color: CustomNeumorphicTheme.baseColor,
                  child: TextField(
                    controller: answerController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Provide a detailed answer...',
                      hintStyle: TextStyle(
                        color: CustomNeumorphicTheme.lightText,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Category',
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
                  color: CustomNeumorphicTheme.baseColor,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ContextQuestionType>(
                      value: selectedType,
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                      dropdownColor: CustomNeumorphicTheme.cardColor,
                      onChanged: (ContextQuestionType? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedType = newValue;
                          });
                        }
                      },
                      items: ContextQuestionType.values.map<DropdownMenuItem<ContextQuestionType>>((ContextQuestionType value) {
                        return DropdownMenuItem<ContextQuestionType>(
                          value: value,
                          child: Row(
                            children: [
                              Container(
                                width: 12.w,
                                height: 12.h,
                                decoration: BoxDecoration(
                                  color: _getQuestionTypeColor(value),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(value.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Checkbox(
                      value: isRequired,
                      onChanged: (bool? value) {
                        setState(() {
                          isRequired = value ?? false;
                        });
                      },
                      activeColor: CustomNeumorphicTheme.primaryPurple,
                    ),
                    Text(
                      'Mark as required',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            NeumorphicButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              borderRadius: BorderRadius.circular(10.r),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: CustomNeumorphicTheme.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            NeumorphicButton(
              onPressed: () async {
                if (questionController.text.trim().isNotEmpty &&
                    answerController.text.trim().isNotEmpty) {
                  Navigator.pop(dialogContext);
                  
                  try {
                    await ref
                        .read(projectContextNotifierProvider(widget.projectId).notifier)
                        .updateQuestion(
                          question.id,
                          questionController.text.trim(),
                          answerController.text.trim(),
                          selectedType,
                          isRequired: isRequired,
                        );
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Question updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating question: $e'),
                          backgroundColor: CustomNeumorphicTheme.errorRed,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in both question and answer'),
                      backgroundColor: CustomNeumorphicTheme.errorRed,
                    ),
                  );
                }
              },
              isSelected: true,
              selectedColor: CustomNeumorphicTheme.primaryPurple,
              borderRadius: BorderRadius.circular(10.r),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadDocument() async {
    if (_isUploading) return;

    try {
      setState(() {
        _isUploading = true;
      });

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        _showDocumentUploadDialog(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting document: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showDocumentUploadDialog(PlatformFile file) {
    final descriptionController = TextEditingController();
    DocumentType selectedType = DocumentType.other;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: CustomNeumorphicTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.upload_file,
                color: Colors.green,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Upload Document',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File info
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: CustomNeumorphicTheme.baseColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        color: CustomNeumorphicTheme.primaryPurple,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: CustomNeumorphicTheme.darkText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${(file.size / 1024).toStringAsFixed(1)} KB',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: CustomNeumorphicTheme.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Document Type',
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
                  color: CustomNeumorphicTheme.baseColor,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DocumentType>(
                      value: selectedType,
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                      dropdownColor: CustomNeumorphicTheme.cardColor,
                      onChanged: (DocumentType? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedType = newValue;
                          });
                        }
                      },
                      items: DocumentType.values.map<DropdownMenuItem<DocumentType>>((DocumentType value) {
                        return DropdownMenuItem<DocumentType>(
                          value: value,
                          child: Row(
                            children: [
                              Container(
                                width: 12.w,
                                height: 12.h,
                                decoration: BoxDecoration(
                                  color: _getDocumentTypeColor(value),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(value.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
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
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  borderRadius: BorderRadius.circular(12.r),
                  color: CustomNeumorphicTheme.baseColor,
                  child: TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add a description for this document...',
                      hintStyle: TextStyle(
                        color: CustomNeumorphicTheme.lightText,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            NeumorphicButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              borderRadius: BorderRadius.circular(10.r),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: CustomNeumorphicTheme.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            NeumorphicButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                
                try {
                  await ref
                      .read(projectContextNotifierProvider(widget.projectId).notifier)
                      .addDocument(
                        file, 
                        selectedType, 
                        descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                      );
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Document "${file.name}" uploaded successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error uploading document: $e'),
                        backgroundColor: CustomNeumorphicTheme.errorRed,
                      ),
                    );
                  }
                }
              },
              isSelected: true,
              selectedColor: Colors.green,
              borderRadius: BorderRadius.circular(10.r),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                'Upload',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentOptions(ProjectDocument document) {
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
            ListTile(
              leading: Icon(Icons.open_in_new, color: CustomNeumorphicTheme.primaryPurple),
              title: Text('Open Document'),
              onTap: () {
                Navigator.pop(context);
                _openDocument(document);
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: Colors.green),
              title: Text('Download'),
              onTap: () {
                Navigator.pop(context);
                _downloadDocument(document);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.orange),
              title: Text('Edit Details'),
              onTap: () {
                Navigator.pop(context);
                _editDocumentDetails(document);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: CustomNeumorphicTheme.errorRed),
              title: Text('Remove'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(projectContextNotifierProvider(widget.projectId).notifier)
                    .removeDocument(document.id);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _openDocument(ProjectDocument document) {
    // For web implementation, we'll show document details
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: CustomNeumorphicTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              _getDocumentIcon(document.fileExtension),
              color: _getDocumentTypeColor(document.type),
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                document.name,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDocumentDetailRow('Type', document.type.displayName),
              SizedBox(height: 12.h),
              _buildDocumentDetailRow('Size', document.formattedSize),
              SizedBox(height: 12.h),
              _buildDocumentDetailRow('Uploaded', _formatDate(document.uploadedAt)),
              SizedBox(height: 12.h),
              _buildDocumentDetailRow('Uploaded by', document.uploadedBy),
              if (document.description != null) ...[
                SizedBox(height: 12.h),
                _buildDocumentDetailRow('Description', document.description!),
              ],
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: CustomNeumorphicTheme.baseColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16.sp,
                      color: CustomNeumorphicTheme.primaryPurple,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'This is a preview. In a production app, this would open the actual document.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: CustomNeumorphicTheme.lightText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          NeumorphicButton(
            onPressed: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(10.r),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'Close',
              style: TextStyle(
                fontSize: 14.sp,
                color: CustomNeumorphicTheme.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: CustomNeumorphicTheme.lightText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: CustomNeumorphicTheme.darkText,
            ),
          ),
        ),
      ],
    );
  }

  void _downloadDocument(ProjectDocument document) {
    // Show download simulation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: CustomNeumorphicTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.download,
              size: 48.sp,
              color: Colors.green,
            ),
            SizedBox(height: 16.h),
            Text(
              'Downloading Document',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: CustomNeumorphicTheme.darkText,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              document.name,
              style: TextStyle(
                fontSize: 12.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            LinearProgressIndicator(
              backgroundColor: CustomNeumorphicTheme.lightText.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: CustomNeumorphicTheme.baseColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'In a production app, this would download the actual file to your device.',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: CustomNeumorphicTheme.lightText,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate download progress
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document "${document.name}" downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _editDocumentDetails(ProjectDocument document) {
    final nameController = TextEditingController(text: document.name);
    final descriptionController = TextEditingController(text: document.description ?? '');
    DocumentType selectedType = document.type;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: CustomNeumorphicTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.edit_document,
                color: Colors.orange,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Edit Document Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document Name',
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
                  color: CustomNeumorphicTheme.baseColor,
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter document name...',
                      hintStyle: TextStyle(
                        color: CustomNeumorphicTheme.lightText,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
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
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  borderRadius: BorderRadius.circular(12.r),
                  color: CustomNeumorphicTheme.baseColor,
                  child: TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add a description...',
                      hintStyle: TextStyle(
                        color: CustomNeumorphicTheme.lightText,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Document Type',
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
                  color: CustomNeumorphicTheme.baseColor,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DocumentType>(
                      value: selectedType,
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                      dropdownColor: CustomNeumorphicTheme.cardColor,
                      onChanged: (DocumentType? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedType = newValue;
                          });
                        }
                      },
                      items: DocumentType.values.map<DropdownMenuItem<DocumentType>>((DocumentType value) {
                        return DropdownMenuItem<DocumentType>(
                          value: value,
                          child: Row(
                            children: [
                              Container(
                                width: 12.w,
                                height: 12.h,
                                decoration: BoxDecoration(
                                  color: _getDocumentTypeColor(value),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(value.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            NeumorphicButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              borderRadius: BorderRadius.circular(10.r),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: CustomNeumorphicTheme.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            NeumorphicButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.pop(dialogContext);
                  
                  try {
                    await ref
                        .read(projectContextNotifierProvider(widget.projectId).notifier)
                        .updateDocument(
                          document.id,
                          nameController.text.trim(),
                          descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                          selectedType,
                        );
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Document updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating document: $e'),
                          backgroundColor: CustomNeumorphicTheme.errorRed,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a document name'),
                      backgroundColor: CustomNeumorphicTheme.errorRed,
                    ),
                  );
                }
              },
              isSelected: true,
              selectedColor: Colors.orange,
              borderRadius: BorderRadius.circular(10.r),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}