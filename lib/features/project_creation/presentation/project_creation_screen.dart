import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
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
      appBar: const CustomAppBar(title: 'Create New Project'),
      body: LoadingOverlay(
        isLoading: projectState.isLoading,
        loadingMessage: 'Analyzing your project with AI...',
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Describe your project',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell me about your project. What do you want to accomplish? The more details you provide, the better I can help you plan it.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: '''Example: I want to build a mobile app for tracking fitness goals. Users should be able to set workout plans, track their progress, and share achievements with friends. The app should work on both iOS and Android, and include features like:
- User registration and profiles
- Workout planning and tracking
- Progress analytics
- Social sharing
- Push notifications for reminders

I have a design team but need help with the technical planning and development phases.''',
                      border: OutlineInputBorder(),
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
                ),
                const SizedBox(height: 24),
                if (projectState.hasError) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Error: ${projectState.error}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: projectState.isLoading ? null : _createProject,
                        child: projectState.isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.psychology, size: 20),
                                SizedBox(width: 8),
                                Text('Analyze Project'),
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
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