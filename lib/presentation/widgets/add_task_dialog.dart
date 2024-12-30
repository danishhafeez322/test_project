// import 'package:flutter/material.dart';
// import 'package:test_project/domain/providers/local_database_provider.dart';
//
// class AddTaskDialog extends StatefulWidget {
//   const AddTaskDialog({super.key});
//
//   @override
//   _AddTaskDialogState createState() => _AddTaskDialogState();
// }
//
// class _AddTaskDialogState extends State<AddTaskDialog> {
//   final TextEditingController _controller = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Add Task'),
//       content: TextField(
//         controller: _controller,
//         decoration: const InputDecoration(hintText: 'Task title'),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             final title = _controller.text.trim();
//             if (title.isNotEmpty) {
//               final db = context.read(localDatabaseProvider);
//               await db.addTask(title); // Add task to the database
//               Navigator.pop(context);
//             }
//           },
//           child: const Text('Add'),
//         ),
//       ],
//     );
//   }
// }
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_project/data/local/drift/local_database.dart';
import 'package:test_project/domain/providers/local_database_provider.dart';
import 'package:test_project/domain/providers/task_repository_provider.dart';
import 'package:uuid/uuid.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  const AddTaskDialog({super.key});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Task title'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final title = _controller.text.trim();
            if (title.isNotEmpty) {
              final db = ref.watch(localDatabaseProvider);
              final taskRepo = ref.watch(taskRepositoryProvider);
              final id = const Uuid().v4(); // Unique ID for the task
              final timestamp = DateTime.now();
              await taskRepo.addTask(id, title, timestamp);
              // await db.addTask(
              //   TasksCompanion(
              //     id: Value(id),
              //     title: Value(title),
              //     timestamp: Value(timestamp),
              //   ),
              // );
              await db.into(db.tasks).insertOnConflictUpdate(
                    TasksCompanion(
                      id: Value(id),
                      title: Value(title),
                      timestamp: Value(timestamp),
                    ),
                  );
              // final db = ref
              //     .read(localDatabaseProvider); // Access the database provider
              // await db.addTask(
              //   TasksCompanion(
              //     title: Value(title),
              //     timestamp: Value(DateTime.now()), // Example timestamp
              //   ),
              // ); // Add task to the database
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
