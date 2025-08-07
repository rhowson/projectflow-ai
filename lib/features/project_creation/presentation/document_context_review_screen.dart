import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/widgets/keyboard_dismissible_wrapper.dart';
import '../../../core/services/claude_ai_service.dart';
import '../../../core/services/document_service.dart';
import '../providers/project_provider.dart';

class DocumentContextReviewScreen extends ConsumerStatefulWidget {
  final String projectDescription;
  final String? documentContent;
  final String? documentAcknowledgment;
  final DocumentUploadResult? documentUpload;
  final TempDocumentResult? tempDocument;
  
  const DocumentContextReviewScreen({
    super.key,
    required this.projectDescription,
    this.documentContent,
    this.documentAcknowledgment,
    this.documentUpload,
    this.tempDocument,
  });

  @override
  ConsumerState<DocumentContextReviewScreen> createState() => _DocumentContextReviewScreenState();
}

class _DocumentContextReviewScreenState extends ConsumerState<DocumentContextReviewScreen>
    with TickerProviderStateMixin {
  
  List<DocumentContextPoint> _extractedContext = [];
  bool _isLoading = true;
  String _loadingMessage = 'Analyzing document for key context points...';
  String? _errorMessage;
  DocumentExtractionErrorType? _errorType;
  List<String>? _suggestions;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _extractDocumentContext();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _extractDocumentContext() async {
    if (widget.documentContent == null || widget.documentAcknowledgment == null) {
      setState(() {
        _isLoading = false;
        _extractedContext = [];
        _errorMessage = 'No document content available for analysis';
        _errorType = DocumentExtractionErrorType.emptyDocument;
        _suggestions = ['Upload a document with text content', 'Try a different file format'];
      });
      return;
    }
    
    try {
      setState(() {
        _loadingMessage = 'Preparing document for AI analysis...';
      });
      
      await Future.delayed(const Duration(milliseconds: 1200));
      
      setState(() {
        _loadingMessage = 'Connecting to Claude AI service...';
      });
      
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _loadingMessage = 'AI is reading and analyzing your document...';
      });
      
      final claudeService = ref.read(claudeAIServiceProvider);
      final extractionResult = await claudeService.extractDocumentContext(
        widget.projectDescription,
        widget.documentContent!,
        widget.documentAcknowledgment!,
      );
      
      setState(() {
        _loadingMessage = 'Processing AI analysis results...';
      });
      
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (extractionResult.success && extractionResult.contextPoints != null) {
        setState(() {
          _extractedContext = extractionResult.contextPoints!;
          _isLoading = false;
          _errorMessage = null;
          _errorType = null;
          _suggestions = null;
        });
        
        _fadeController.forward();
      } else {
        // Handle extraction failure with detailed feedback
        setState(() {
          _isLoading = false;
          _extractedContext = [];
          _errorMessage = extractionResult.errorMessage;
          _errorType = extractionResult.errorType;
          _suggestions = extractionResult.suggestions;
        });
      }
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _extractedContext = [];
        _errorMessage = 'Unexpected error during document analysis';
        _errorType = DocumentExtractionErrorType.processingError;
        _suggestions = ['Try uploading the document again', 'Consider using a different document format'];
      });
      
      print('Unexpected error in document context extraction: $e');
    }
  }

  void _removeContextPoint(String id) {
    setState(() {
      _extractedContext.removeWhere((point) => point.id == id);
    });
  }

  void _proceedToContextQuestions() {
    // Navigate to context questions with the filtered context points
    final data = {
      'projectDescription': widget.projectDescription,
      'documentContent': widget.documentContent,
      'documentUploadResult': widget.documentUpload,
      'tempDocumentResult': widget.tempDocument,
      'extractedContext': _extractedContext,
    };
    
    context.go('/project-context', extra: data);
  }

  void _skipContextReview() {
    // Proceed without document context
    final data = {
      'projectDescription': widget.projectDescription,
      'documentContent': widget.documentContent,
      'documentUploadResult': widget.documentUpload,
      'tempDocumentResult': widget.tempDocument,
      'extractedContext': <DocumentContextPoint>[],
    };
    
    context.go('/project-context', extra: data);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissibleWrapper(
      child: Scaffold(
        backgroundColor: CustomNeumorphicTheme.baseColor,
        appBar: _buildAppBar(),
        body: _isLoading ? _buildLoadingView() : _buildContextReviewView(),
        bottomNavigationBar: !_isLoading ? _buildBottomActions() : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: NeumorphicButton(
        onPressed: () => context.pop(),
        borderRadius: BorderRadius.circular(12.r),
        padding: EdgeInsets.all(8.w),
        child: Icon(
          Icons.arrow_back_ios_new,
          color: CustomNeumorphicTheme.darkText,
          size: 20.sp,
        ),
      ),
      title: Text(
        'Document Context Review',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: CustomNeumorphicTheme.darkText,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeumorphicContainer(
            width: 80.w,
            height: 80.w,
            borderRadius: BorderRadius.circular(40.r),
            color: CustomNeumorphicTheme.primaryPurple,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    CustomNeumorphicTheme.primaryPurple,
                    CustomNeumorphicTheme.secondaryPurple,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 32.sp,
                color: Colors.white,
              ),
            ),
          ),
          
          SizedBox(height: 32.h),
          
          Text(
            _loadingMessage,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: CustomNeumorphicTheme.darkText,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 16.h),
          
          LinearProgressIndicator(
            backgroundColor: CustomNeumorphicTheme.lightText.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(CustomNeumorphicTheme.primaryPurple),
          ),
        ],
      ),
    );
  }

  Widget _buildContextReviewView() {
    // Show error view if there's an error message
    if (_errorMessage != null) {
      return _buildErrorView();
    }
    
    // Show no context view if no context was extracted (but no error)
    if (_extractedContext.isEmpty) {
      return _buildNoContextView();
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20.h),
            Expanded(
              child: _buildContextList(),
            ),
            SizedBox(height: 12.h),
            _buildInfoBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    final errorIcon = _getErrorIcon(_errorType);
    final errorColor = _getErrorColor(_errorType);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with color
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: errorColor.withValues(alpha: 0.1),
              ),
              child: Icon(
                errorIcon,
                size: 40.sp,
                color: errorColor,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            Text(
              'Document Analysis Issue',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: CustomNeumorphicTheme.darkText,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Main error message
            NeumorphicContainer(
              padding: EdgeInsets.all(16.w),
              borderRadius: BorderRadius.circular(12.r),
              child: Column(
                children: [
                  Text(
                    _errorMessage ?? 'Unknown error occurred',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: CustomNeumorphicTheme.darkText,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  if (_suggestions != null && _suggestions!.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Divider(color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.3)),
                    SizedBox(height: 16.h),
                    
                    // Suggestions section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'How to fix this:',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: CustomNeumorphicTheme.darkText,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    ...(_suggestions!.map((suggestion) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CustomNeumorphicTheme.lightText,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: CustomNeumorphicTheme.lightText,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () => context.pop(),
                    borderRadius: BorderRadius.circular(12.r),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Text(
                      'Upload Different Document',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: CustomNeumorphicTheme.lightText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                Expanded(
                  child: NeumorphicButton(
                    onPressed: _skipContextReview,
                    selectedColor: CustomNeumorphicTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(12.r),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    isSelected: true,
                    child: Text(
                      'Continue Anyway',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoContextView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
            
            SizedBox(height: 24.h),
            
            Text(
              'No Context Extracted',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: CustomNeumorphicTheme.darkText,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Text(
              'The AI couldn\'t extract specific context points from your document. You can still proceed to answer context questions.',
              style: TextStyle(
                fontSize: 14.sp,
                color: CustomNeumorphicTheme.lightText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Context Points',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        Text(
          'The AI found ${_extractedContext.length} key points from your document. Review and remove any that aren\'t relevant.',
          style: TextStyle(
            fontSize: 14.sp,
            color: CustomNeumorphicTheme.lightText,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildContextList() {
    return ListView.separated(
      itemCount: _extractedContext.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final contextPoint = _extractedContext[index];
        return _buildContextCard(contextPoint);
      },
    );
  }

  Widget _buildContextCard(DocumentContextPoint contextPoint) {
    return NeumorphicContainer(
      padding: EdgeInsets.all(16.w),
      borderRadius: BorderRadius.circular(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildCategoryChip(contextPoint.category),
              const Spacer(),
              _buildImportanceIndicator(contextPoint.importance),
              SizedBox(width: 8.w),
              NeumorphicButton(
                onPressed: () => _removeContextPoint(contextPoint.id),
                borderRadius: BorderRadius.circular(8.r),
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.close,
                  size: 16.sp,
                  color: CustomNeumorphicTheme.errorRed,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          Text(
            contextPoint.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: CustomNeumorphicTheme.darkText,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            contextPoint.description,
            style: TextStyle(
              fontSize: 14.sp,
              color: CustomNeumorphicTheme.lightText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final categoryColors = {
      'requirements': CustomNeumorphicTheme.primaryPurple,
      'technical': const Color(0xFF3498DB), // Blue color
      'business': CustomNeumorphicTheme.successGreen,
      'timeline': const Color(0xFFE67E22), // Orange color
      'stakeholders': CustomNeumorphicTheme.secondaryPurple,
      'constraints': CustomNeumorphicTheme.errorRed,
    };
    
    final color = categoryColors[category] ?? CustomNeumorphicTheme.lightText;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildImportanceIndicator(String importance) {
    final colors = {
      'high': CustomNeumorphicTheme.errorRed,
      'medium': const Color(0xFFE67E22), // Orange color
      'low': CustomNeumorphicTheme.lightText,
    };
    
    final color = colors[importance] ?? CustomNeumorphicTheme.lightText;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          importance == 'high' ? Icons.priority_high :
          importance == 'medium' ? Icons.remove : Icons.low_priority,
          size: 16.sp,
          color: color,
        ),
        SizedBox(width: 4.w),
        Text(
          importance.toUpperCase(),
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return NeumorphicEmbossedContainer(
      padding: EdgeInsets.all(16.w),
      borderRadius: BorderRadius.circular(12.r),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20.sp,
            color: const Color(0xFF3498DB), // Blue color
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'You can add more context later in the AI Context dialog on the project page.',
              style: TextStyle(
                fontSize: 12.sp,
                color: CustomNeumorphicTheme.lightText,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: CustomNeumorphicTheme.baseColor,
        boxShadow: [
          BoxShadow(
            color: CustomNeumorphicTheme.darkShadow.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: NeumorphicButton(
              onPressed: _skipContextReview,
              borderRadius: BorderRadius.circular(12.r),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ),
            ),
          ),
          
          SizedBox(width: 16.w),
          
          Expanded(
            flex: 2,
            child: NeumorphicButton(
              onPressed: _extractedContext.isNotEmpty ? _proceedToContextQuestions : _skipContextReview,
              selectedColor: CustomNeumorphicTheme.primaryPurple,
              borderRadius: BorderRadius.circular(12.r),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              isSelected: true,
              child: Text(
                _extractedContext.isNotEmpty ? 'Continue with Context' : 'Proceed Anyway',
                style: TextStyle(
                  fontSize: 16.sp,
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

  /// Get appropriate error icon based on error type
  IconData _getErrorIcon(DocumentExtractionErrorType? errorType) {
    switch (errorType) {
      case DocumentExtractionErrorType.emptyDocument:
        return Icons.description_outlined;
      case DocumentExtractionErrorType.insufficientContent:
        return Icons.short_text;
      case DocumentExtractionErrorType.unsupportedFormat:
        return Icons.file_present;
      case DocumentExtractionErrorType.protectedDocument:
        return Icons.lock_outline;
      case DocumentExtractionErrorType.processingError:
        return Icons.error_outline;
      case DocumentExtractionErrorType.networkError:
        return Icons.wifi_off;
      case DocumentExtractionErrorType.authError:
        return Icons.security;
      case DocumentExtractionErrorType.noContext:
        return Icons.search_off;
      default:
        return Icons.help_outline;
    }
  }

  /// Get appropriate error color based on error type
  Color _getErrorColor(DocumentExtractionErrorType? errorType) {
    switch (errorType) {
      case DocumentExtractionErrorType.protectedDocument:
      case DocumentExtractionErrorType.authError:
        return CustomNeumorphicTheme.errorRed;
      case DocumentExtractionErrorType.networkError:
      case DocumentExtractionErrorType.processingError:
        return const Color(0xFFE67E22); // Orange
      case DocumentExtractionErrorType.emptyDocument:
      case DocumentExtractionErrorType.insufficientContent:
      case DocumentExtractionErrorType.noContext:
        return CustomNeumorphicTheme.lightText;
      case DocumentExtractionErrorType.unsupportedFormat:
        return const Color(0xFF3498DB); // Blue
      default:
        return CustomNeumorphicTheme.lightText;
    }
  }
}