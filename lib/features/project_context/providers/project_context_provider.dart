import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/models/project_context_model.dart';
import '../../../core/services/firebase_service.dart';
import '../../project_creation/providers/project_provider.dart';

final projectContextNotifierProvider = StateNotifierProvider.family<ProjectContextNotifier, AsyncValue<ProjectContext?>, String>(
  (ref, projectId) => ProjectContextNotifier(projectId, ref.read(firebaseServiceProvider)),
);

class ProjectContextNotifier extends StateNotifier<AsyncValue<ProjectContext?>> {
  final String projectId;
  final FirebaseService _firebaseService;
  
  ProjectContextNotifier(this.projectId, this._firebaseService) : super(const AsyncValue.loading()) {
    _loadProjectContext();
  }

  Future<void> _loadProjectContext() async {
    try {
      state = const AsyncValue.loading();
      
      // Try to load from Firebase first
      final existingContext = await _firebaseService.loadProjectContext(projectId);
      
      if (existingContext != null) {
        state = AsyncValue.data(existingContext);
        return;
      }
      
      // If no context exists, create empty context
      final emptyContext = ProjectContext(
        projectId: projectId,
        contextQuestions: [],
        documents: [],
        lastUpdated: DateTime.now(),
        summary: null,
      );
      
      state = AsyncValue.data(emptyContext);
    } catch (error, stackTrace) {
      print('Error loading project context: $error');
      state = AsyncValue.error(error, stackTrace);
    }
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
      await _firebaseService.saveProjectContext(updatedContext);

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
      await _firebaseService.saveProjectContext(updatedContext);

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
      await _firebaseService.saveProjectContext(updatedContext);

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
      await _firebaseService.saveProjectContext(updatedContext);

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
      await _firebaseService.saveProjectContext(updatedContext);

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
      await _firebaseService.saveProjectContext(updatedContext);

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