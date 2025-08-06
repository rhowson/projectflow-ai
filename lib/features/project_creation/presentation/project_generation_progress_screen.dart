import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';

enum GenerationStep {
  analyzing,
  structuring,
  detailing,
  finalizing,
  completed,
}

class ProjectGenerationProgressScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String projectTitle;
  final GenerationStep? currentStep;
  final String? message;
  final List<String>? completedSteps;
  final double? progress;
  final bool? isCompleted;
  final String? currentPhaseDescription;
  
  const ProjectGenerationProgressScreen({
    super.key,
    required this.projectId,
    required this.projectTitle,
    this.currentStep,
    this.message,
    this.completedSteps,
    this.progress,
    this.isCompleted,
    this.currentPhaseDescription,
  });

  @override
  ConsumerState<ProjectGenerationProgressScreen> createState() => _ProjectGenerationProgressScreenState();
}

class _ProjectGenerationProgressScreenState extends ConsumerState<ProjectGenerationProgressScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _successController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successRotationAnimation;
  
  GenerationStep _currentStep = GenerationStep.analyzing;
  bool _isCompleted = false;
  String _currentMessage = '';
  String _currentPhaseDescription = '';
  List<String> _completedSteps = [];
  
  final Map<GenerationStep, String> _stepMessages = {
    GenerationStep.analyzing: 'Analyzing project requirements with AI...',
    GenerationStep.structuring: 'Creating optimal phase structure...',
    GenerationStep.detailing: 'Generating detailed tasks and timelines...',
    GenerationStep.finalizing: 'Finalizing project breakdown...',
    GenerationStep.completed: 'Project generation completed!',
  };
  
  final Map<GenerationStep, List<String>> _phaseDescriptions = {
    GenerationStep.analyzing: [
      'Reading your project description...',
      'Identifying key requirements...',
      'Understanding project scope...',
      'Analyzing complexity factors...',
      'Categorizing project type...',
    ],
    GenerationStep.structuring: [
      'Creating project phases...',
      'Organizing workflow structure...',
      'Defining phase dependencies...',
      'Setting milestone markers...',
      'Optimizing phase distribution...',
    ],
    GenerationStep.detailing: [
      'Generating detailed tasks...',
      'Estimating task durations...',
      'Creating task dependencies...',
      'Assigning priority levels...',
      'Adding task descriptions...',
    ],
    GenerationStep.finalizing: [
      'Reviewing project structure...',
      'Optimizing task flow...',
      'Finalizing timelines...',
      'Preparing project data...',
      'Completing generation...',
    ],
    GenerationStep.completed: ['Project ready!'],
  };
  
  final Map<GenerationStep, IconData> _stepIcons = {
    GenerationStep.analyzing: Icons.analytics_outlined,
    GenerationStep.structuring: Icons.account_tree_outlined,
    GenerationStep.detailing: Icons.list_alt_outlined,
    GenerationStep.finalizing: Icons.tune_outlined,
    GenerationStep.completed: Icons.check_circle_outline,
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    // If we have external data, use it; otherwise simulate
    if (widget.currentStep != null) {
      _currentStep = widget.currentStep!;
      _currentMessage = widget.message ?? _stepMessages[_currentStep]!;
      _completedSteps = widget.completedSteps ?? [];
      _isCompleted = widget.isCompleted ?? false;
      _currentPhaseDescription = widget.currentPhaseDescription ?? _phaseDescriptions[_currentStep]?.first ?? '';
    } else {
      _currentPhaseDescription = _phaseDescriptions[GenerationStep.analyzing]?.first ?? 'Preparing to generate...';
      // Only start simulation if no external completion state is provided
      if (widget.isCompleted != true) {
        _startGeneration();
      }
    }
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutBack,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _successScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));
    
    _successRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.easeInOut,
    ));
    
    _mainController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _startGeneration() {
    _simulateGenerationProgress();
  }

  void _simulateGenerationProgress() async {
    // Step 1: Analyzing
    await _simulatePhase(GenerationStep.analyzing, const Duration(seconds: 2));
    
    // Step 2: Structuring
    await _simulatePhase(GenerationStep.structuring, const Duration(seconds: 2));
    
    // Step 3: Detailing
    await _simulatePhase(GenerationStep.detailing, const Duration(seconds: 2));
    
    // Step 4: Finalizing
    await _simulatePhase(GenerationStep.finalizing, const Duration(seconds: 1));
    
    // Step 5: Completed
    await _completeGeneration();
  }

  Future<void> _simulatePhase(GenerationStep step, Duration totalDuration) async {
    final descriptions = _phaseDescriptions[step] ?? [];
    if (descriptions.isEmpty) return;
    
    // Update step
    setState(() {
      _currentStep = step;
      _currentMessage = _stepMessages[step]!;
      _currentPhaseDescription = descriptions.first;
    });
    
    // Calculate time per description
    final timePerDescription = Duration(
      milliseconds: totalDuration.inMilliseconds ~/ descriptions.length,
    );
    
    // Cycle through descriptions
    for (int i = 0; i < descriptions.length; i++) {
      if (mounted) {
        setState(() {
          _currentPhaseDescription = descriptions[i];
        });
        await Future.delayed(timePerDescription);
      }
    }
  }


  Future<void> _updateStep(GenerationStep step, String message) async {
    if (mounted) {
      setState(() {
        if (_currentStep != GenerationStep.completed) {
          _completedSteps.add(_stepMessages[_currentStep]!);
        }
        _currentStep = step;
        _currentMessage = message;
      });
      
      // Restart animations for new step
      _mainController.reset();
      _mainController.forward();
    }
  }

  Future<void> _completeGeneration() async {
    if (mounted) {
      setState(() {
        _completedSteps.add(_stepMessages[_currentStep]!);
        _currentStep = GenerationStep.completed;
        _currentMessage = _stepMessages[GenerationStep.completed]!;
        _isCompleted = true;
      });
      
      _pulseController.stop();
      _successController.forward();
      
      // Wait for success animation then navigate to the project tab
      // Only navigate if this is a self-managed simulation (no external wrapper)
      if (widget.isCompleted == null) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.go('/tasks');
        }
      }
    }
  }

  @override
  void didUpdateWidget(ProjectGenerationProgressScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle external state updates
    bool shouldUpdate = false;
    
    if (widget.currentStep != oldWidget.currentStep && widget.currentStep != null) {
      _currentStep = widget.currentStep!;
      shouldUpdate = true;
    }
    
    if (widget.message != oldWidget.message && widget.message != null) {
      _currentMessage = widget.message!;
      shouldUpdate = true;
    }
    
    if (widget.currentPhaseDescription != oldWidget.currentPhaseDescription && widget.currentPhaseDescription != null) {
      _currentPhaseDescription = widget.currentPhaseDescription!;
      shouldUpdate = true;
    }
    
    if (widget.completedSteps != oldWidget.completedSteps && widget.completedSteps != null) {
      _completedSteps = widget.completedSteps!;
      shouldUpdate = true;
    }
    
    // Handle external completion state change
    if (widget.isCompleted == true && oldWidget.isCompleted != true && !_isCompleted) {
      _isCompleted = true;
      _currentStep = GenerationStep.completed;
      _currentMessage = _stepMessages[GenerationStep.completed]!;
      _currentPhaseDescription = 'Project ready!';
      
      _pulseController.stop();
      _successController.forward();
      shouldUpdate = true;
    }
    
    if (shouldUpdate && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      body: SafeArea(
        child: _isCompleted ? _buildSuccessView() : _buildSimpleProgressView(),
      ),
    );
  }


  Widget _buildSimpleProgressView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Project title
            NeumorphicContainer(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              borderRadius: BorderRadius.circular(20.r),
              child: Text(
                widget.projectTitle,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomNeumorphicTheme.darkText,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            SizedBox(height: 40.h),
            
            // Step indicators
            _buildStepIndicators(),
            
            SizedBox(height: 40.h),
            
            // Animated loading icon
            _buildSimpleLoadingAnimation(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicators() {
    final steps = [
      {'step': 1, 'label': 'Analyze', 'status': GenerationStep.analyzing},
      {'step': 2, 'label': 'Structure', 'status': GenerationStep.structuring},
      {'step': 3, 'label': 'Detail', 'status': GenerationStep.detailing},
      {'step': 4, 'label': 'Finalize', 'status': GenerationStep.finalizing},
      {'step': 5, 'label': 'Complete', 'status': GenerationStep.completed},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: steps.map((stepData) {
        final stepNumber = stepData['step'] as int;
        final label = stepData['label'] as String;
        final stepStatus = stepData['status'] as GenerationStep;
        
        // Determine step state
        bool isCompleted = _getStepIndex(_currentStep) > _getStepIndex(stepStatus);
        bool isCurrent = _currentStep == stepStatus;
        bool isPending = _getStepIndex(_currentStep) < _getStepIndex(stepStatus);
        
        return Row(
          children: [
            _buildStepIndicator(
              stepNumber: stepNumber,
              label: label,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isPending: isPending,
            ),
            if (stepNumber < 5) _buildStepConnector(isCompleted || isCurrent),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStepIndicator({
    required int stepNumber,
    required String label,
    required bool isCompleted,
    required bool isCurrent,
    required bool isPending,
  }) {
    Color indicatorColor;
    Color textColor;
    IconData? icon;
    
    if (isCompleted) {
      indicatorColor = CustomNeumorphicTheme.successGreen;
      textColor = CustomNeumorphicTheme.successGreen;
      icon = Icons.check;
    } else if (isCurrent) {
      indicatorColor = CustomNeumorphicTheme.primaryPurple;
      textColor = CustomNeumorphicTheme.primaryPurple;
    } else {
      indicatorColor = CustomNeumorphicTheme.lightText.withOpacity(0.3);
      textColor = CustomNeumorphicTheme.lightText;
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: indicatorColor,
            boxShadow: isCurrent ? [
              BoxShadow(
                color: indicatorColor.withOpacity(0.3),
                blurRadius: 8.r,
                spreadRadius: 2.r,
              ),
            ] : [],
          ),
          child: Center(
            child: isCompleted 
                ? Icon(
                    icon,
                    size: 16.sp,
                    color: Colors.white,
                  )
                : Text(
                    stepNumber.toString(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: isPending ? CustomNeumorphicTheme.lightText : Colors.white,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 24.w,
      height: 2.h,
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: isActive 
            ? CustomNeumorphicTheme.primaryPurple
            : CustomNeumorphicTheme.lightText.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1.r),
      ),
    );
  }

  int _getStepIndex(GenerationStep step) {
    switch (step) {
      case GenerationStep.analyzing:
        return 0;
      case GenerationStep.structuring:
        return 1;
      case GenerationStep.detailing:
        return 2;
      case GenerationStep.finalizing:
        return 3;
      case GenerationStep.completed:
        return 4;
    }
  }

  Widget _buildSimpleLoadingAnimation() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: NeumorphicContainer(
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
                boxShadow: [
                  BoxShadow(
                    color: CustomNeumorphicTheme.primaryPurple.withOpacity(0.3),
                    blurRadius: 15.r,
                    spreadRadius: 2.r,
                  ),
                ],
              ),
              child: Icon(
                _stepIcons[_currentStep] ?? Icons.auto_awesome,
                size: 32.sp,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: AnimatedBuilder(
          animation: _successController,
          builder: (context, child) {
            return Transform.scale(
              scale: _successScaleAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Project title
                  NeumorphicEmbossedContainer(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Text(
                      widget.projectTitle,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: CustomNeumorphicTheme.darkText,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  SizedBox(height: 60.h),
                  
                  // Success icon
                  NeumorphicContainer(
                    width: 100.w,
                    height: 100.w,
                    borderRadius: BorderRadius.circular(50.r),
                    color: CustomNeumorphicTheme.successGreen,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            CustomNeumorphicTheme.successGreen,
                            CustomNeumorphicTheme.successGreen.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: CustomNeumorphicTheme.successGreen.withOpacity(0.3),
                            blurRadius: 15.r,
                            spreadRadius: 2.r,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        size: 40.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 40.h),
                  
                  // Success text
                  Text(
                    'Project Created!',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomNeumorphicTheme.successGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 60.h),
                  
                  // View Project button
                  NeumorphicButton(
                    onPressed: () => context.go('/tasks'),
                    selectedColor: CustomNeumorphicTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(12.r),
                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
                    isSelected: true,
                    child: Text(
                      'View Project',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}