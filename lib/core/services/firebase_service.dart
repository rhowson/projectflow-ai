import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/project_model.dart';
import '../models/project_context_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _projectsCollection = 'projects';
  static const String _projectContextCollection = 'project_contexts';

  /// Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  /// Save a project to Firestore
  Future<void> saveProject(Project project) async {
    try {
      // Use the model's built-in JSON serialization with DateTimeConverter
      // The DateTimeConverter will automatically handle DateTime to ISO string conversion
      final projectData = project.toJson();

      await _firestore
          .collection(_projectsCollection)
          .doc(project.id)
          .set(projectData);
      
      print('Project saved successfully to Firestore: ${project.id}');
    } catch (e) {
      print('Error saving project to Firestore: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to save project: $e',
      );
    }
  }

  /// Load a specific project from Firestore
  Future<Project?> loadProject(String projectId) async {
    try {
      final doc = await _firestore
          .collection(_projectsCollection)
          .doc(projectId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return _parseProjectFromFirestore(doc.data()!);
    } catch (e) {
      print('Error loading project from Firestore: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to load project: $e',
      );
    }
  }

  /// Load all projects from Firestore
  Future<List<Project>> loadAllProjects() async {
    try {
      print('Starting Firestore query...');
      
      // Add timeout to prevent hanging
      final querySnapshot = await _firestore
          .collection(_projectsCollection)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Firestore query timed out after 10 seconds');
            },
          );

      print('Firestore query completed. Processing ${querySnapshot.docs.length} documents...');
      
      final projects = <Project>[];
      for (final doc in querySnapshot.docs) {
        try {
          final project = _parseProjectFromFirestore(doc.data());
          projects.add(project);
        } catch (e) {
          print('Error parsing project ${doc.id}: $e');
          // Continue with other projects even if one fails
        }
      }

      print('Loaded ${projects.length} projects from Firestore');
      return projects;
    } catch (e) {
      print('Error loading projects from Firestore: $e');
      if (e.toString().contains('permission-denied')) {
        print('Permission denied - check Firestore security rules');
      } else if (e.toString().contains('unavailable')) {
        print('Firestore service unavailable - check network connection');
      }
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to load projects: $e',
      );
    }
  }

  /// Update an existing project in Firestore
  Future<void> updateProject(Project project) async {
    try {
      await saveProject(project); // Reuse save logic since Firestore upserts
      print('Project updated successfully in Firestore: ${project.id}');
    } catch (e) {
      print('Error updating project in Firestore: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to update project: $e',
      );
    }
  }

  /// Delete a project from Firestore
  Future<void> deleteProject(String projectId) async {
    try {
      await _firestore
          .collection(_projectsCollection)
          .doc(projectId)
          .delete();
      
      print('Project deleted successfully from Firestore: $projectId');
    } catch (e) {
      print('Error deleting project from Firestore: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to delete project: $e',
      );
    }
  }

  /// Listen to project changes in real-time
  Stream<List<Project>> watchAllProjects() {
    return _firestore
        .collection(_projectsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final projects = <Project>[];
      for (final doc in snapshot.docs) {
        try {
          final project = _parseProjectFromFirestore(doc.data());
          projects.add(project);
        } catch (e) {
          print('Error parsing project ${doc.id} in stream: $e');
          // Continue with other projects
        }
      }
      return projects;
    });
  }

  /// Listen to a specific project changes in real-time
  Stream<Project?> watchProject(String projectId) {
    return _firestore
        .collection(_projectsCollection)
        .doc(projectId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      try {
        return _parseProjectFromFirestore(doc.data()!);
      } catch (e) {
        print('Error parsing project $projectId in stream: $e');
        return null;
      }
    });
  }

  /// Parse project data from Firestore document
  Project _parseProjectFromFirestore(Map<String, dynamic> data) {
    try {
      // The DateTimeConverter in the model will automatically handle 
      // Timestamp conversion when fromJson is called
      return Project.fromJson(data);
    } catch (e) {
      print('Error parsing project from Firestore: $e');
      print('Project data: $data');
      rethrow;
    }
  }


  /// Check if Firestore is available
  Future<bool> isAvailable() async {
    try {
      print('Testing Firestore connection...');
      
      // Try a simple query to test connection
      await _firestore
          .collection(_projectsCollection)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      
      print('Firestore connection successful');
      return true;
    } catch (e) {
      print('Firestore is not available: $e');
      if (e.toString().contains('permission-denied')) {
        print('FIRESTORE ERROR: Permission denied. Check security rules.');
      } else if (e.toString().contains('unauthenticated')) {
        print('FIRESTORE ERROR: User not authenticated.');
      }
      return false;
    }
  }

  /// Get collection statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      final projectsSnapshot = await _firestore
          .collection(_projectsCollection)
          .get();

      int totalTasks = 0;
      int completedTasks = 0;
      int totalPhases = 0;
      int completedPhases = 0;

      for (final doc in projectsSnapshot.docs) {
        try {
          final data = doc.data();
          if (data['phases'] != null) {
            final List<dynamic> phases = data['phases'];
            totalPhases += phases.length;
            
            for (final phase in phases) {
              if (phase['status'] == 'completed') {
                completedPhases++;
              }
              
              if (phase['tasks'] != null) {
                final List<dynamic> tasks = phase['tasks'];
                totalTasks += tasks.length;
                
                for (final task in tasks) {
                  if (task['status'] == 'completed') {
                    completedTasks++;
                  }
                }
              }
            }
          }
        } catch (e) {
          print('Error processing project stats for ${doc.id}: $e');
        }
      }

      return {
        'totalProjects': projectsSnapshot.docs.length,
        'totalPhases': totalPhases,
        'completedPhases': completedPhases,
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }

  /// Create sample data for testing
  Future<void> createSampleData() async {
    try {
      print('Creating sample project data...');
      
      // Sample project 1
      final sampleProject1 = Project(
        id: 'sample_project_1',
        title: 'E-commerce Website',
        description: 'Build a modern e-commerce platform with React and Node.js',
        status: ProjectStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        ownerId: 'demo-user-id',
        teamMemberIds: ['user_1', 'user_2'],
        phases: [
          ProjectPhase(
            id: 'phase_1',
            name: 'Planning & Design',
            description: 'Define requirements and create UI/UX designs',
            status: PhaseStatus.completed,
            startDate: DateTime.now().subtract(const Duration(days: 7)),
            endDate: DateTime.now().subtract(const Duration(days: 3)),
            tasks: [
              Task(
                id: 'task_1',
                title: 'Create wireframes',
                description: 'Design basic layout and user flow wireframes',
                status: TaskStatus.completed,
                priority: Priority.high,
                createdAt: DateTime.now().subtract(const Duration(days: 6)),
                attachmentIds: [],
                dependencyIds: [],
                estimatedHours: 8.0,
                actualHours: 6.5,
                comments: [],
              ),
              Task(
                id: 'task_2',
                title: 'Design system setup',
                description: 'Create color palette, typography, and component library',
                status: TaskStatus.completed,
                priority: Priority.medium,
                createdAt: DateTime.now().subtract(const Duration(days: 5)),
                attachmentIds: [],
                dependencyIds: ['task_1'],
                estimatedHours: 12.0,
                actualHours: 10.0,
                comments: [],
              ),
            ],
          ),
          ProjectPhase(
            id: 'phase_2',
            name: 'Frontend Development',
            description: 'Build the user interface using React',
            status: PhaseStatus.inProgress,
            startDate: DateTime.now().subtract(const Duration(days: 3)),
            endDate: null,
            tasks: [
              Task(
                id: 'task_3',
                title: 'Set up React project',
                description: 'Initialize React app with routing and state management',
                status: TaskStatus.completed,
                priority: Priority.high,
                createdAt: DateTime.now().subtract(const Duration(days: 3)),
                attachmentIds: [],
                dependencyIds: [],
                estimatedHours: 4.0,
                actualHours: 3.5,
                comments: [],
              ),
              Task(
                id: 'task_4',
                title: 'Build product catalog',
                description: 'Create product listing and detail pages',
                status: TaskStatus.inProgress,
                priority: Priority.high,
                createdAt: DateTime.now().subtract(const Duration(days: 2)),
                attachmentIds: [],
                dependencyIds: ['task_3'],
                estimatedHours: 16.0,
                actualHours: 8.0,
                comments: [],
              ),
              Task(
                id: 'task_5',
                title: 'Shopping cart functionality',
                description: 'Implement add to cart, remove items, and checkout flow',
                status: TaskStatus.todo,
                priority: Priority.medium,
                createdAt: DateTime.now().subtract(const Duration(days: 1)),
                attachmentIds: [],
                dependencyIds: ['task_4'],
                estimatedHours: 20.0,
                actualHours: 0.0,
                comments: [],
              ),
            ],
          ),
        ],
        metadata: ProjectMetadata(
          type: ProjectType.web,
          priority: Priority.high,
          estimatedHours: 120.0,
          customFields: {
            'client': 'Tech Startup Inc.',
            'budget': 15000,
            'technologies': ['React', 'Node.js', 'MongoDB'],
          },
        ),
      );

      // Sample project 2
      final sampleProject2 = Project(
        id: 'sample_project_2',
        title: 'Mobile Task Manager',
        description: 'Cross-platform mobile app for task and project management',
        status: ProjectStatus.planning,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        dueDate: DateTime.now().add(const Duration(days: 45)),
        ownerId: 'demo-user-id',
        teamMemberIds: ['user_3'],
        phases: [
          ProjectPhase(
            id: 'phase_3',
            name: 'Research & Planning',
            description: 'Market research and technical planning',
            status: PhaseStatus.inProgress,
            startDate: DateTime.now().subtract(const Duration(days: 2)),
            endDate: null,
            tasks: [
              Task(
                id: 'task_6',
                title: 'Market research',
                description: 'Analyze competitors and user needs',
                status: TaskStatus.inProgress,
                priority: Priority.medium,
                createdAt: DateTime.now().subtract(const Duration(days: 2)),
                attachmentIds: [],
                dependencyIds: [],
                estimatedHours: 16.0,
                actualHours: 8.0,
                comments: [],
              ),
              Task(
                id: 'task_7',
                title: 'Technical architecture',
                description: 'Define app architecture and technology stack',
                status: TaskStatus.todo,
                priority: Priority.high,
                createdAt: DateTime.now().subtract(const Duration(days: 1)),
                attachmentIds: [],
                dependencyIds: ['task_6'],
                estimatedHours: 12.0,
                actualHours: 0.0,
                comments: [],
              ),
            ],
          ),
        ],
        metadata: ProjectMetadata(
          type: ProjectType.mobile,
          priority: Priority.medium,
          estimatedHours: 200.0,
          customFields: {
            'platform': 'Cross-platform',
            'target_users': 'Small teams and individuals',
            'technologies': ['Flutter', 'Firebase'],
          },
        ),
      );

      // Save sample projects
      await saveProject(sampleProject1);
      await saveProject(sampleProject2);
      
      print('Sample data created successfully!');
    } catch (e) {
      print('Error creating sample data: $e');
      rethrow;
    }
  }

  /// Save project context to Firestore
  Future<void> saveProjectContext(ProjectContext projectContext) async {
    try {
      // Use the model's built-in JSON serialization with DateTimeConverter
      // The DateTimeConverter will automatically handle DateTime to ISO string conversion
      final contextData = projectContext.toJson();

      await _firestore
          .collection(_projectContextCollection)
          .doc(projectContext.projectId)
          .set(contextData);
      
      print('Project context saved successfully to Firestore: ${projectContext.projectId}');
    } catch (e) {
      print('Error saving project context to Firestore: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to save project context: $e',
      );
    }
  }

  /// Load project context from Firestore
  Future<ProjectContext?> loadProjectContext(String projectId) async {
    try {
      final doc = await _firestore
          .collection(_projectContextCollection)
          .doc(projectId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return _parseProjectContextFromFirestore(doc.data()!);
    } catch (e) {
      print('Error loading project context from Firestore: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to load project context: $e',
      );
    }
  }

  /// Update project context in Firestore
  Future<void> updateProjectContext(ProjectContext projectContext) async {
    await saveProjectContext(projectContext); // Same as save for simplicity
  }

  /// Delete project context from Firestore
  Future<void> deleteProjectContext(String projectId) async {
    try {
      await _firestore
          .collection(_projectContextCollection)
          .doc(projectId)
          .delete();
      
      print('Project context deleted successfully: $projectId');
    } catch (e) {
      print('Error deleting project context: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to delete project context: $e',
      );
    }
  }

  /// Parse project context from Firestore document
  ProjectContext _parseProjectContextFromFirestore(Map<String, dynamic> data) {
    try {
      // The DateTimeConverter in the models will automatically handle 
      // Timestamp conversion when fromJson is called
      return ProjectContext.fromJson(data);
    } catch (e) {
      print('Error parsing project context from Firestore: $e');
      print('Project context data: $data');
      rethrow;
    }
  }

  /// Clear all data from Firestore (for development/testing purposes)
  Future<void> clearAllData() async {
    try {
      print('Starting Firestore cleanup...');
      
      // Delete all projects
      final projectsSnapshot = await _firestore
          .collection(_projectsCollection)
          .get();
      
      print('Found ${projectsSnapshot.docs.length} projects to delete');
      
      final batch = _firestore.batch();
      for (final doc in projectsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete all project contexts
      final contextsSnapshot = await _firestore
          .collection(_projectContextCollection)
          .get();
      
      print('Found ${contextsSnapshot.docs.length} project contexts to delete');
      
      for (final doc in contextsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Commit the batch delete
      await batch.commit();
      
      print('Successfully cleared all data from Firestore');
      print('- Deleted ${projectsSnapshot.docs.length} projects');
      print('- Deleted ${contextsSnapshot.docs.length} project contexts');
      
    } catch (e) {
      print('Error clearing Firestore data: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to clear Firestore data: $e',
      );
    }
  }

}