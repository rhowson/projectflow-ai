import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/keyboard_dismissible_wrapper.dart';
import '../../../shared/widgets/keyboard_dismiss_button.dart';
import '../../../core/services/claude_ai_service.dart';
import '../../../core/services/document_service.dart';
import '../providers/project_provider.dart';
import '../providers/context_provider.dart';

class ProjectContextScreen extends ConsumerStatefulWidget {
  final String projectDescription;
  final String? documentContent;
  final DocumentUploadResult? documentUploadResult;
  
  const ProjectContextScreen({
    super.key,
    required this.projectDescription,
    this.documentContent,
    this.documentUploadResult,
  });

  @override
  ConsumerState<ProjectContextScreen> createState() => _ProjectContextScreenState();
}

class _ProjectContextScreenState extends ConsumerState<ProjectContextScreen> {
  final PageController _pageController = PageController();
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _answers = {};
  bool _isGeneratingProject = false;

  @override
  void initState() {
    super.initState();
    // Generate context questions when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contextQuestionsProvider.notifier).generateQuestions(
        widget.projectDescription,
        documentContent: widget.documentContent,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionsState = ref.watch(contextQuestionsProvider);
    
    return Scaffold(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      appBar: NeumorphicAppBar(
        title: Text(
          'Project Context',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        automaticallyImplyLeading: true,
        actions: [
          InlineKeyboardDismissButton(),
          SizedBox(width: 16.w),
        ],
      ),
      body: KeyboardDismissibleWrapper(
        child: questionsState.when(
        data: (contextData) {
          if (contextData.questions.isEmpty) {
            return const Center(
              child: LoadingIndicator(message: 'Generating questions...'),
            );
          }
          
          return Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(contextData.questions.length),
              
              // Question content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentQuestionIndex = index;
                    });
                  },
                  itemCount: contextData.questions.length,
                  itemBuilder: (context, index) {
                    final question = contextData.questions[index];
                    return _buildQuestionPage(question);
                  },
                ),
              ),
              
              // Navigation buttons
              _buildNavigationButtons(contextData.questions.length),
            ],
          );
        },
        loading: () => const Center(
          child: LoadingIndicator(message: 'Generating context questions...'),
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
                'Failed to generate questions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8.h),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              NeumorphicButton(
                onPressed: () {
                  ref.read(contextQuestionsProvider.notifier).generateQuestions(
                    widget.projectDescription,
                    documentContent: widget.documentContent,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Text(
                  'Retry',
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
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int totalQuestions) {
    final progress = totalQuestions > 0 ? (_currentQuestionIndex + 1) / totalQuestions : 0.0;
    final answeredCount = _answers.values.where((answer) => 
      answer != null && (answer is! String || answer.toString().trim().isNotEmpty)
    ).length;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: CustomNeumorphicTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '$answeredCount answered',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: CustomNeumorphicTheme.primaryPurple,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomNeumorphicTheme.primaryPurple,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          NeumorphicProgressBar(
            progress: progress,
            height: 8.h,
            progressColor: CustomNeumorphicTheme.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(ContextQuestion question) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 24.h),
          
          _buildAnswerInput(question),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(ContextQuestion question) {
    switch (question.type) {
      case QuestionType.text:
        return _buildTextInput(question);
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceInput(question);
      case QuestionType.boolean:
        return _buildBooleanInput(question);
    }
  }

  Widget _buildTextInput(ContextQuestion question) {
    return NeumorphicCard(
      padding: EdgeInsets.all(16.w),
      child: TextFormField(
        initialValue: _answers[question.id]?.toString() ?? '',
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Enter your answer here...',
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
        onChanged: (value) {
          setState(() {
            _answers[question.id] = value;
          });
        },
        onTapOutside: (event) {
          // Hide keyboard when tapping outside
          context.dismissKeyboard();
        },
        onEditingComplete: () {
          // Hide keyboard when user finishes editing
          context.dismissKeyboard();
        },
      ),
    );
  }

  Widget _buildMultipleChoiceInput(ContextQuestion question) {
    final options = question.options ?? [];
    final selectedOption = _answers[question.id]?.toString();

    return Column(
      children: options.map((option) {
        final isSelected = selectedOption == option;
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          child: NeumorphicButton(
            onPressed: () {
              // Hide keyboard first
              context.dismissKeyboard();
              setState(() {
                _answers[question.id] = option;
              });
            },
            isSelected: isSelected,
            selectedColor: CustomNeumorphicTheme.primaryPurple,
            borderRadius: BorderRadius.circular(12),
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.white : CustomNeumorphicTheme.darkText,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected ? Colors.white : CustomNeumorphicTheme.darkText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBooleanInput(ContextQuestion question) {
    final selectedValue = _answers[question.id] as bool?;

    return Row(
      children: [
        Expanded(
          child: NeumorphicButton(
            onPressed: () {
              // Hide keyboard first
              context.dismissKeyboard();
              setState(() {
                _answers[question.id] = true;
              });
            },
            isSelected: selectedValue == true,
            selectedColor: CustomNeumorphicTheme.primaryPurple,
            borderRadius: BorderRadius.circular(12),
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selectedValue == true ? Icons.check_circle : Icons.check_circle_outline,
                  color: selectedValue == true ? Colors.white : CustomNeumorphicTheme.darkText,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: selectedValue == true ? Colors.white : CustomNeumorphicTheme.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: NeumorphicButton(
            onPressed: () {
              // Hide keyboard first
              context.dismissKeyboard();
              setState(() {
                _answers[question.id] = false;
              });
            },
            isSelected: selectedValue == false,
            selectedColor: CustomNeumorphicTheme.lightText,
            borderRadius: BorderRadius.circular(12),
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selectedValue == false ? Icons.cancel : Icons.cancel_outlined,
                  color: selectedValue == false ? Colors.white : CustomNeumorphicTheme.darkText,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'No',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: selectedValue == false ? Colors.white : CustomNeumorphicTheme.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(int totalQuestions) {
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _currentQuestionIndex == totalQuestions - 1;
    final currentQuestion = ref.read(contextQuestionsProvider).value?.questions[_currentQuestionIndex];
    final hasAnswer = currentQuestion != null && _answers.containsKey(currentQuestion.id);

    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Skip option
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  context.dismissKeyboard();
                  _skipQuestion();
                },
                icon: Icon(
                  Icons.skip_next,
                  color: CustomNeumorphicTheme.lightText,
                  size: 16.sp,
                ),
                label: Text(
                  'Skip this question',
                  style: TextStyle(
                    color: CustomNeumorphicTheme.lightText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Navigation buttons
          Row(
            children: [
              if (!isFirstQuestion)
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () {
                      // Hide keyboard first
                      context.dismissKeyboard();
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: CustomNeumorphicTheme.primaryPurple,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Previous',
                          style: TextStyle(
                            color: CustomNeumorphicTheme.primaryPurple,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (!isFirstQuestion) SizedBox(width: 16.w),
              
              Expanded(
                child: NeumorphicButton(
                  onPressed: () {
                    // Hide keyboard first
                    context.dismissKeyboard();
                    if (isLastQuestion) {
                      _createProject();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  isSelected: hasAnswer,
                  selectedColor: CustomNeumorphicTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(12),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: _isGeneratingProject
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLastQuestion ? 'Create Project' : (hasAnswer ? 'Next' : 'Next (Unanswered)'),
                              style: TextStyle(
                                color: hasAnswer ? Colors.white : CustomNeumorphicTheme.primaryPurple,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (!isLastQuestion) ...[
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.arrow_forward,
                                color: hasAnswer ? Colors.white : CustomNeumorphicTheme.primaryPurple,
                                size: 16.sp,
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _skipQuestion() {
    final currentQuestion = ref.read(contextQuestionsProvider).value?.questions[_currentQuestionIndex];
    if (currentQuestion != null) {
      // Mark question as skipped by removing any existing answer
      setState(() {
        _answers.remove(currentQuestion.id);
      });
      
      // Move to next question or create project if last question
      if (_currentQuestionIndex == ref.read(contextQuestionsProvider).value!.questions.length - 1) {
        _createProject();
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _createProject() async {
    setState(() {
      _isGeneratingProject = true;
    });

    try {
      // Get the current context data to access the questions
      final contextData = ref.read(contextQuestionsProvider).value;
      final questions = contextData?.questions ?? [];
      
      // Create a properly structured answers map with question text as keys
      // Only include answered questions (skip unanswered ones)
      final structuredAnswers = <String, dynamic>{};
      for (final entry in _answers.entries) {
        final questionId = entry.key;
        final answer = entry.value;
        
        // Skip empty or null answers
        if (answer == null || (answer is String && answer.trim().isEmpty)) {
          continue;
        }
        
        // Find the question text by ID
        final question = questions.firstWhere(
          (q) => q.id == questionId,
          orElse: () => throw Exception('Question with ID $questionId not found'),
        );
        
        structuredAnswers[question.question] = answer;
      }
      
      // Extract title for the progress screen
      final projectTitle = widget.projectDescription.length > 50 
          ? '${widget.projectDescription.substring(0, 47)}...'
          : widget.projectDescription;

      if (mounted) {
        // Navigate to progress screen where the actual generation happens
        context.go('/project-generation-progress', extra: {
          'projectDescription': widget.projectDescription,
          'contextAnswers': structuredAnswers,
          'documentUploadResult': widget.documentUploadResult,
          'documentContent': widget.documentContent,
          'projectTitle': projectTitle,
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to prepare project: $error'),
            backgroundColor: CustomNeumorphicTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingProject = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}