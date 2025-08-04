import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class DocumentService {
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB limit
  static const List<String> allowedExtensions = ['pdf', 'doc', 'docx', 'txt'];
  
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
        if (!allowedExtensions.contains(extension)) {
          throw DocumentException('Only PDF, DOC, DOCX, and TXT files are allowed');
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

class DocumentException implements Exception {
  final String message;
  
  const DocumentException(this.message);
  
  @override
  String toString() => 'DocumentException: $message';
}