import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/models/project_context_model.dart';

final projectContextNotifierProvider = StateNotifierProvider.family<ProjectContextNotifier, AsyncValue<ProjectContext?>, String>(
  (ref, projectId) => ProjectContextNotifier(projectId),
);

class ProjectContextNotifier extends StateNotifier<AsyncValue<ProjectContext?>> {
  final String projectId;
  
  ProjectContextNotifier(this.projectId) : super(const AsyncValue.loading()) {
    _loadProjectContext();
  }

  void _loadProjectContext() {
    // Mock data for demonstration - in real app, this would load from database
    final mockQuestions = [
      ContextQuestion(
        id: '1',
        question: 'What is the primary goal of this project?',
        answer: 'Create a modern project management app with AI assistance for breaking down complex projects into manageable tasks.',
        type: ContextQuestionType.projectScope,
        answeredAt: DateTime.now().subtract(const Duration(days: 2)),
        isRequired: true,
      ),
      ContextQuestion(
        id: '2',
        question: 'What technology stack should be used?',
        answer: 'Flutter for mobile/web frontend, Firebase for backend services, Claude AI for intelligent project analysis.',
        type: ContextQuestionType.technicalRequirements,
        answeredAt: DateTime.now().subtract(const Duration(days: 2)),
        isRequired: true,
      ),
      ContextQuestion(
        id: '3',
        question: 'What is the target timeline for completion?',
        answer: '3 months for MVP, 6 months for full version with all features.',
        type: ContextQuestionType.timeline,
        answeredAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    final mockDocuments = [
      ProjectDocument(
        id: '1',
        name: 'Project Requirements.pdf',
        path: '/documents/requirements.pdf',
        mimeType: 'application/pdf',
        sizeInBytes: 245760, // 240KB
        uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        uploadedBy: 'current_user',
        type: DocumentType.requirement,
        description: 'Detailed project requirements and specifications',
      ),
      ProjectDocument(
        id: '2',
        name: 'UI Mockups.figma',
        path: '/documents/ui_mockups.figma',
        mimeType: 'application/figma',
        sizeInBytes: 1048576, // 1MB
        uploadedAt: DateTime.now().subtract(const Duration(hours: 12)),
        uploadedBy: 'designer_user',
        type: DocumentType.design,
        description: 'User interface mockups and design system',
      ),
    ];

    final context = ProjectContext(
      projectId: projectId,
      contextQuestions: mockQuestions,
      documents: mockDocuments,
      lastUpdated: DateTime.now(),
      summary: 'AI-powered project management app with Flutter frontend and Firebase backend. 3-month timeline with focus on intelligent task breakdown.',
    );

    state = AsyncValue.data(context);
  }

  Future<void> addDocument(PlatformFile file, DocumentType type, String? description) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      state = const AsyncValue.loading();

      // In real app, upload file to storage service
      final document = ProjectDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: file.name,
        path: '/documents/${file.name}',
        mimeType: file.extension != null ? 'application/${file.extension}' : 'application/octet-stream',
        sizeInBytes: file.size,
        uploadedAt: DateTime.now(),
        uploadedBy: 'current_user', // Get from user provider
        type: type,
        description: description,
      );

      final updatedDocuments = [...currentState.documents, document];
      final updatedContext = currentState.copyWith(
        documents: updatedDocuments,
        lastUpdated: DateTime.now(),
      );

      // Save to database
      // await _saveProjectContext(updatedContext);

      state = AsyncValue.data(updatedContext);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeDocument(String documentId) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      state = const AsyncValue.loading();

      final updatedDocuments = currentState.documents
          .where((doc) => doc.id != documentId)
          .toList();

      final updatedContext = currentState.copyWith(
        documents: updatedDocuments,
        lastUpdated: DateTime.now(),
      );

      // Save to database and remove file from storage
      // await _removeDocumentFromStorage(documentId);
      // await _saveProjectContext(updatedContext);

      state = AsyncValue.data(updatedContext);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateDocument(String documentId, String name, String? description, DocumentType type) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      state = const AsyncValue.loading();

      final updatedDocuments = currentState.documents.map((doc) {
        if (doc.id == documentId) {
          return ProjectDocument(
            id: doc.id,
            name: name,
            path: doc.path,
            mimeType: doc.mimeType,
            sizeInBytes: doc.sizeInBytes,
            uploadedAt: doc.uploadedAt,
            uploadedBy: doc.uploadedBy,
            type: type,
            description: description,
          );
        }
        return doc;
      }).toList();

      final updatedContext = currentState.copyWith(
        documents: updatedDocuments,
        lastUpdated: DateTime.now(),
      );

      // Save to database
      // await _saveProjectContext(updatedContext);

      state = AsyncValue.data(updatedContext);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateContextAnswer(String questionId, String answer) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      state = const AsyncValue.loading();

      final updatedQuestions = currentState.contextQuestions.map((question) {
        if (question.id == questionId) {
          return ContextQuestion(
            id: question.id,
            question: question.question,
            answer: answer,
            type: question.type,
            answeredAt: DateTime.now(),
            isRequired: question.isRequired,
          );
        }
        return question;
      }).toList();

      final updatedContext = currentState.copyWith(
        contextQuestions: updatedQuestions,
        lastUpdated: DateTime.now(),
      );

      // Save to database
      // await _saveProjectContext(updatedContext);

      state = AsyncValue.data(updatedContext);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addContextQuestion(String question, String answer, ContextQuestionType type, {bool isRequired = false}) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      state = const AsyncValue.loading();

      final newQuestion = ContextQuestion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: question,
        answer: answer,
        type: type,
        answeredAt: DateTime.now(),
        isRequired: isRequired,
      );

      final updatedQuestions = [...currentState.contextQuestions, newQuestion];
      final updatedContext = currentState.copyWith(
        contextQuestions: updatedQuestions,
        lastUpdated: DateTime.now(),
      );

      // Save to database
      // await _saveProjectContext(updatedContext);

      state = AsyncValue.data(updatedContext);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateQuestion(String questionId, String question, String answer, ContextQuestionType type, {bool isRequired = false}) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      state = const AsyncValue.loading();

      final updatedQuestions = currentState.contextQuestions.map((q) {
        if (q.id == questionId) {
          return ContextQuestion(
            id: q.id,
            question: question,
            answer: answer,
            type: type,
            answeredAt: DateTime.now(),
            isRequired: isRequired,
          );
        }
        return q;
      }).toList();

      final updatedContext = currentState.copyWith(
        contextQuestions: updatedQuestions,
        lastUpdated: DateTime.now(),
      );

      // Save to database
      // await _saveProjectContext(updatedContext);

      state = AsyncValue.data(updatedContext);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshContext() async {
    state = const AsyncValue.loading();
    _loadProjectContext();
  }
}