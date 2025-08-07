import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/project_creation/providers/project_provider.dart';

class DatabaseStatusWidget extends ConsumerStatefulWidget {
  const DatabaseStatusWidget({super.key});

  @override
  ConsumerState<DatabaseStatusWidget> createState() => _DatabaseStatusWidgetState();
}

class _DatabaseStatusWidgetState extends ConsumerState<DatabaseStatusWidget> {
  bool _isChecking = false;
  String _statusMessage = 'Tap to check database status';
  Color _statusColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Database Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            color: _statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_isChecking)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isChecking ? null : _checkDatabaseConnection,
                    icon: const Icon(Icons.wifi_find, size: 18),
                    label: const Text('Check Connection'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isChecking ? null : _testDatabaseOperations,
                    icon: const Icon(Icons.science, size: 18),
                    label: const Text('Test Operations'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isChecking ? null : _getStatistics,
                    icon: const Icon(Icons.analytics, size: 18),
                    label: const Text('View Statistics'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isChecking ? null : _createSampleData,
                    icon: const Icon(Icons.data_object, size: 18),
                    label: const Text('Create Sample Data'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkDatabaseConnection() async {
    setState(() {
      _isChecking = true;
      _statusMessage = 'Checking database connection...';
      _statusColor = Colors.orange;
    });

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final isAvailable = await firebaseService.isAvailable();
      
      if (isAvailable) {
        setState(() {
          _statusMessage = 'Database connection successful ✓';
          _statusColor = Colors.green;
        });
      } else {
        setState(() {
          _statusMessage = 'Database connection failed ✗';
          _statusColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking connection: $e';
        _statusColor = Colors.red;
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _testDatabaseOperations() async {
    setState(() {
      _isChecking = true;
      _statusMessage = 'Testing database operations...';
      _statusColor = Colors.orange;
    });

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      
      // Try loading projects
      await firebaseService.loadAllProjects();
      
      setState(() {
        _statusMessage = 'Database operations test passed ✓';
        _statusColor = Colors.green;
      });
      
      // Also refresh the projects in the app
      ref.invalidate(projectNotifierProvider);
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Database operations test failed: $e';
        _statusColor = Colors.red;
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _getStatistics() async {
    setState(() {
      _isChecking = true;
      _statusMessage = 'Loading database statistics...';
      _statusColor = Colors.orange;
    });

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final stats = await firebaseService.getStatistics();
      
      if (stats.isNotEmpty) {
        final totalProjects = stats['totalProjects'] ?? 0;
        final totalTasks = stats['totalTasks'] ?? 0;
        final completedTasks = stats['completedTasks'] ?? 0;
        
        setState(() {
          _statusMessage = 'Projects: $totalProjects | Tasks: $completedTasks/$totalTasks completed';
          _statusColor = Colors.blue;
        });
      } else {
        setState(() {
          _statusMessage = 'No statistics available';
          _statusColor = Colors.grey;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading statistics: $e';
        _statusColor = Colors.red;
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _createSampleData() async {
    setState(() {
      _isChecking = true;
      _statusMessage = 'Creating sample data...';
      _statusColor = Colors.orange;
    });

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.createSampleData();
      
      setState(() {
        _statusMessage = 'Sample data created successfully ✓';
        _statusColor = Colors.green;
      });
      
      // Refresh the projects in the app
      ref.invalidate(projectNotifierProvider);
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Error creating sample data: $e';
        _statusColor = Colors.red;
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }
}