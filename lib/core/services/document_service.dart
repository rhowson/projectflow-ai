import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import '../models/project_context_model.dart';

class DocumentService {
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB limit
  
  // AI-supported file types with specific restrictions
  static const List<String> aiSupportedExtensions = ['txt', 'pdf', 'doc', 'docx', 'md'];
  static const List<String> allowedExtensions = ['pdf', 'doc', 'docx', 'txt', 'md'];
  
  // File types explicitly not supported by AI
  static const Map<String, String> restrictedExtensions = {
    'exe': 'Executable files are not supported',
    'zip': 'Archive files cannot be processed by AI',
    'rar': 'Archive files cannot be processed by AI', 
    '7z': 'Archive files cannot be processed by AI',
    'dmg': 'Disk images are not supported',
    'iso': 'Disk images are not supported',
    'js': 'JavaScript files may contain sensitive code',
    'ts': 'TypeScript files may contain sensitive code',
    'py': 'Python files may contain sensitive code',
    'java': 'Java files may contain sensitive code',
    'cpp': 'C++ files may contain sensitive code',
    'c': 'C files may contain sensitive code',
    'sql': 'SQL files may contain sensitive database information',
    'env': 'Environment files contain sensitive configuration',
    'key': 'Key files contain sensitive credentials',
    'pem': 'Certificate files contain sensitive credentials',
    'json': 'JSON files may contain sensitive configuration',
    'xml': 'XML files may contain sensitive configuration',
    'csv': 'CSV files with potentially sensitive data - use TXT format instead',
    'xlsx': 'Excel files not supported - export as PDF or TXT instead',
    'xls': 'Excel files not supported - export as PDF or TXT instead',
    'ppt': 'PowerPoint files not supported - export as PDF instead',
    'pptx': 'PowerPoint files not supported - export as PDF instead',
  };
  
  static const String _storageBucket = 'gs://projectflow-1e82a.firebasestorage.app';
  
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<DocumentUploadResult?> pickAndValidateDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        
        // Validate file size
        if (file.size > maxFileSizeBytes) {
          throw DocumentException('File size must be less than 5MB');
        }
        
        // Validate file extension
        final extension = path.extension(file.name).toLowerCase().replaceAll('.', '');
        
        // Check if file type is explicitly restricted
        if (restrictedExtensions.containsKey(extension)) {
          throw DocumentException('${restrictedExtensions[extension]}. Please convert to a supported format: ${aiSupportedExtensions.join(', ').toUpperCase()}');
        }
        
        // Check if file type is supported by AI
        if (!aiSupportedExtensions.contains(extension)) {
          throw DocumentException('File type .$extension is not supported by AI. Supported formats: ${aiSupportedExtensions.join(', ').toUpperCase()}');
        }
        
        // Read file content
        Uint8List? fileBytes;
        String? content;
        
        if (kIsWeb) {
          fileBytes = file.bytes;
        } else {
          final fileObj = File(file.path!);
          fileBytes = await fileObj.readAsBytes();
        }
        
        if (fileBytes != null) {
          content = await _extractTextFromFile(fileBytes, extension);
        }
        
        return DocumentUploadResult(
          fileName: file.name,
          fileSize: file.size,
          fileExtension: extension,
          content: content ?? '',
          originalBytes: fileBytes,
        );
      }
    } catch (e) {
      if (e is DocumentException) {
        rethrow;
      }
      throw DocumentException('Failed to pick document: $e');
    }
    return null;
  }
  
  Future<String> _extractTextFromFile(Uint8List bytes, String extension) async {
    switch (extension) {
      case 'txt':
        return String.fromCharCodes(bytes);
      case 'pdf':
        return await _extractTextFromPDF(bytes);
      case 'doc':
      case 'docx':
        return await _extractTextFromWord(bytes);
      default:
        throw DocumentException('Unsupported file type: $extension');
    }
  }
  
  Future<String> _extractTextFromPDF(Uint8List bytes) async {
    // For now, return a placeholder. In production, you'd use a PDF parsing library
    // like pdf or syncfusion_flutter_pdf
    return '[PDF content extraction not implemented yet. Please provide project details in the text field above.]';
  }
  
  Future<String> _extractTextFromWord(Uint8List bytes) async {
    // For now, return a placeholder. In production, you'd use a Word parsing library
    // or convert to text via an API
    return '[Word document content extraction not implemented yet. Please provide project details in the text field above.]';
  }
  
  /// Upload document to temporary storage for AI processing with secure codified filename
  Future<TempDocumentResult> uploadToTemporaryStorage({
    required DocumentUploadResult document,
    required String sessionId,
  }) async {
    try {
      // Generate secure codified document ID to prevent direct access
      final codifiedId = _generateSecureDocumentId();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempId = 'temp_${codifiedId}_${timestamp}_${sessionId}';
      final fileExtension = path.extension(document.fileName);
      
      // Create temporary storage path with codified filename
      final codifiedFileName = '$codifiedId$fileExtension';
      final storagePath = 'temp_documents/$tempId/$codifiedFileName';
      final storageRef = _storage.ref().child(storagePath);
      
      // Upload file bytes to Firebase Storage
      if (document.originalBytes == null) {
        throw DocumentException('Document bytes not available for upload');
      }
      
      // Set metadata with expiry (24 hours) and security flags
      final expiryTime = DateTime.now().add(const Duration(hours: 24));
      final metadata = SettableMetadata(
        contentType: _getMimeType(document.fileExtension),
        customMetadata: {
          'originalFileName': document.fileName,
          'codifiedFileName': codifiedFileName,
          'sessionId': sessionId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'expiresAt': expiryTime.toIso8601String(),
          'isTemporary': 'true',
          'aiAccessible': 'true',
          'fileSecured': 'true',
          'purposeForAI': 'project_context_analysis',
        },
      );
      
      // Upload to Firebase Storage
      final uploadTask = storageRef.putData(document.originalBytes!, metadata);
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('Document uploaded to temporary storage: $storagePath');
      
      return TempDocumentResult(
        tempId: tempId,
        downloadUrl: downloadUrl,
        storagePath: storagePath,
        fileName: document.fileName,
        codifiedFileName: codifiedFileName,
        content: document.content,
        expiresAt: expiryTime,
        isSecured: true,
      );
      
    } catch (e) {
      print('Error uploading document to temporary storage: $e');
      throw DocumentException('Failed to upload document temporarily: $e');
    }
  }

  /// Upload document to Firebase Storage and return ProjectDocument
  Future<ProjectDocument> uploadDocumentToFirebase({
    required DocumentUploadResult document,
    required String projectId,
    required String uploadedBy,
    DocumentType type = DocumentType.other,
    String? description,
  }) async {
    try {
      // Generate unique document ID
      final documentId = '${DateTime.now().millisecondsSinceEpoch}_${document.fileName}';
      
      // Create storage path: projects/{projectId}/documents/{documentId}
      final storagePath = 'projects/$projectId/documents/$documentId';
      final storageRef = _storage.ref().child(storagePath);
      
      // Upload file bytes to Firebase Storage
      if (document.originalBytes == null) {
        throw DocumentException('Document bytes not available for upload');
      }
      
      // Set metadata
      final metadata = SettableMetadata(
        contentType: _getMimeType(document.fileExtension),
        customMetadata: {
          'originalFileName': document.fileName,
          'projectId': projectId,
          'uploadedBy': uploadedBy,
          'documentType': type.name,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Upload to Firebase Storage
      final uploadTask = storageRef.putData(document.originalBytes!, metadata);
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Create ProjectDocument model
      final projectDocument = ProjectDocument(
        id: documentId,
        name: document.fileName,
        path: downloadUrl, // Use download URL as path
        mimeType: _getMimeType(document.fileExtension),
        sizeInBytes: document.fileSize,
        uploadedAt: DateTime.now(),
        uploadedBy: uploadedBy,
        type: type,
        description: description,
      );
      
      print('Document uploaded successfully: $storagePath');
      return projectDocument;
      
    } catch (e) {
      print('Error uploading document to Firebase Storage: $e');
      throw DocumentException('Failed to upload document: $e');
    }
  }

  /// Move document from temporary storage to project storage with codified name
  Future<ProjectDocument> codifyAndMoveDocument({
    required TempDocumentResult tempDocument,
    required String projectId,
    required String uploadedBy,
    DocumentType type = DocumentType.other,
    String? description,
  }) async {
    try {
      // Generate codified document ID to prevent direct access
      final codifiedId = _generateSecureDocumentId();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalDocumentId = '${codifiedId}_$timestamp';
      
      // Create final storage path with codified name
      final finalStoragePath = 'projects/$projectId/documents/$finalDocumentId';
      final finalStorageRef = _storage.ref().child(finalStoragePath);
      
      // Get the temporary document
      final tempStorageRef = _storage.ref().child(tempDocument.storagePath);
      
      // Download from temp storage
      final tempBytes = await tempStorageRef.getData();
      if (tempBytes == null) {
        throw DocumentException('Failed to retrieve temporary document');
      }
      
      // Set metadata for final document
      final metadata = SettableMetadata(
        contentType: _getMimeType(path.extension(tempDocument.fileName).replaceAll('.', '')),
        customMetadata: {
          'originalFileName': tempDocument.fileName,
          'projectId': projectId,
          'uploadedBy': uploadedBy,
          'documentType': type.name,
          'uploadedAt': DateTime.now().toIso8601String(),
          'codified': 'true',
          'aiAccessible': 'true',
        },
      );
      
      // Upload to final location with codified name
      final uploadTask = finalStorageRef.putData(tempBytes, metadata);
      final snapshot = await uploadTask;
      
      // Get download URL for final location
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Clean up temporary document
      try {
        await tempStorageRef.delete();
        print('Temporary document cleaned up: ${tempDocument.storagePath}');
      } catch (e) {
        print('Warning: Failed to cleanup temporary document: $e');
      }
      
      // Create ProjectDocument model with codified info
      final projectDocument = ProjectDocument(
        id: finalDocumentId,
        name: tempDocument.fileName, // Keep original name for display
        path: downloadUrl,
        mimeType: _getMimeType(path.extension(tempDocument.fileName).replaceAll('.', '')),
        sizeInBytes: tempBytes.length,
        uploadedAt: DateTime.now(),
        uploadedBy: uploadedBy,
        type: type,
        description: description ?? 'Context document from project creation',
      );
      
      print('Document codified and moved: $finalStoragePath');
      return projectDocument;
      
    } catch (e) {
      print('Error codifying and moving document: $e');
      throw DocumentException('Failed to codify document: $e');
    }
  }

  /// Generate secure document ID to prevent direct access
  String _generateSecureDocumentId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    var result = '';
    
    for (int i = 0; i < 16; i++) {
      final index = (random.codeUnitAt(i % random.length) + i) % chars.length;
      result += chars[index];
    }
    
    return result;
  }
  
  /// Delete document from Firebase Storage
  Future<void> deleteDocumentFromFirebase(String storagePath) async {
    try {
      await _storage.ref().child(storagePath).delete();
      print('Document deleted from Firebase Storage: $storagePath');
    } catch (e) {
      print('Error deleting document from Firebase Storage: $e');
      throw DocumentException('Failed to delete document: $e');
    }
  }
  
  /// Get MIME type for file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  void cleanupDocument(DocumentUploadResult document) {
    // Clear sensitive data from memory
    document.originalBytes?.fillRange(0, document.originalBytes!.length, 0);
  }
  
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class DocumentUploadResult {
  final String fileName;
  final int fileSize;
  final String fileExtension;
  final String content;
  final Uint8List? originalBytes;
  
  const DocumentUploadResult({
    required this.fileName,
    required this.fileSize,
    required this.fileExtension,
    required this.content,
    this.originalBytes,
  });
  
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class TempDocumentResult {
  final String tempId;
  final String downloadUrl;
  final String storagePath;
  final String fileName;
  final String codifiedFileName;
  final String content;
  final DateTime expiresAt;
  final bool isSecured;
  
  const TempDocumentResult({
    required this.tempId,
    required this.downloadUrl,
    required this.storagePath,
    required this.fileName,
    required this.codifiedFileName,
    required this.content,
    required this.expiresAt,
    required this.isSecured,
  });
}

class DocumentException implements Exception {
  final String message;
  
  const DocumentException(this.message);
  
  @override
  String toString() => 'DocumentException: $message';
}