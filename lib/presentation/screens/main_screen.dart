import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_project/domain/providers/local_database_provider.dart';
import 'package:test_project/domain/providers/sync_service_provider.dart';
import 'package:test_project/domain/providers/task_providers.dart';
import 'package:test_project/domain/providers/task_repository_provider.dart';
import 'package:test_project/presentation/widgets/add_task_dialog.dart';
import 'package:test_project/presentation/widgets/task_item.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskProvider = ref.watch(tasksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              final syncService = ref.read(syncServiceProvider);
              syncService.startRealTimeSync();
              // final refreshValue =
              //     ref.refresh(tasksStreamProvider); // Refresh task list
              // print("Refresh value: $refreshValue");
            },
          ),
        ],
      ),
      body: taskProvider.when(
        data: (tasks) {
          debugPrint('Tasks loaded: $tasks'); // Add this to check the tasks
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No tasks available.'),
            );
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskItem(
                task: task,
                onDelete: () async {
                  final db = ref.read(localDatabaseProvider);
                  final taskRepo = ref.read(taskRepositoryProvider);

                  // Mark task as deleted locally
                  await db.deleteTask(task.id);

                  // Sync with Firestore
                  await taskRepo.deleteTask(task.id.toString());
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          debugPrint('Error loading tasks: $err');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load tasks.'),
                ElevatedButton(
                  onPressed: () {
                    final syncService = ref.read(syncServiceProvider);
                    syncService.startRealTimeSync();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddTaskDialog(),
          ).then((_) {
            // Trigger real-time sync after adding a task
            final syncService = ref.read(syncServiceProvider);
            syncService.startRealTimeSync();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task added successfully!')),
            );
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
