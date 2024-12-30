// import 'package:drift/drift.dart';
// import 'package:test_project/data/local/drift/local_database.dart';
// import 'package:test_project/data/local/repositories/task_repository.dart';
//
// class SyncService {
//   final TaskRepository taskRepo;
//   final LocalDatabase db;
//
//   SyncService(this.taskRepo, this.db);
//
//   void startSync() {
//     taskRepo.getTasksStream().listen((tasks) async {
//       for (var task in tasks) {
//         await db.into(db.tasks).insertOnConflictUpdate(
//               TasksCompanion(
//                 id: Value(task['id']),
//                 title: Value(task['title']),
//                 timestamp: Value(task['timestamp']),
//               ),
//             );
//       }
//     });
//   }
// }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:drift/drift.dart';
// import 'package:test_project/data/local/drift/local_database.dart';
// import 'package:test_project/data/local/repositories/task_repository.dart';
//
// class SyncService {
//   final TaskRepository taskRepo;
//   final LocalDatabase db;
//
//   SyncService(this.taskRepo, this.db);
//
//   void startSync() {
//     // Sync Firestore to Drift
//     taskRepo.getTasksStream().listen((tasks) async {
//       print('Syncing ${tasks.length} tasks from Firestore to Drift.');
//       for (var task in tasks) {
//         try {
//           await db.into(db.tasks).insertOnConflictUpdate(
//                 TasksCompanion(
//                   id: Value(task['id']),
//                   title: Value(task['title']),
//                   timestamp: Value(task['timestamp']),
//                 ),
//               );
//         } catch (e) {
//           print('Error syncing task from Firestore to Drift: $e');
//         }
//       }
//     });
//
//     // Sync Drift to Firestore
//     syncLocalToFirestore();
//   }
//
//   Future<void> syncLocalToFirestore() async {
//     final localTasks = await db.select(db.tasks).get();
//     print('Syncing ${localTasks.length} tasks from Drift to Firestore.');
//     for (var task in localTasks) {
//       try {
//         await FirebaseFirestore.instance
//             .collection('tasks')
//             .doc(task.id.toString())
//             .set({
//           'title': task.title,
//           'timestamp': task.timestamp,
//         });
//       } catch (e) {
//         print('Error syncing task from Drift to Firestore: $e');
//       }
//     }
//   }
// }
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:test_project/data/local/drift/local_database.dart';
import 'package:test_project/data/local/repositories/task_repository.dart';

class SyncService with ChangeNotifier {
  final TaskRepository taskRepo;
  final LocalDatabase db;

  SyncService(this.taskRepo, this.db);
  Future<void> initialize() async {
    await initialSync();
    startRealTimeSync();
  }

  Future<void> initialSync() async {
    final tasks = await taskRepo.fetchAllTasks();
    for (var task in tasks) {
      await db.into(db.tasks).insertOnConflictUpdate(
            TasksCompanion(
              id: Value(task['id']),
              title: Value(task['title']),
              timestamp: Value(task['timestamp']),
            ),
          );
    }
  }

  void startRealTimeSync() {
    taskRepo.getTasksStream().listen((tasks) async {
      // Step 1: Sync existing tasks
      final existingTaskIds = <String>{};
      for (var task in tasks) {
        existingTaskIds.add(task['id']);
        print('Task from firebase: ${task['id']}');
        await db.into(db.tasks).insertOnConflictUpdate(
              TasksCompanion(
                id: Value(task['id']),
                title: Value(task['title']),
                timestamp: Value(task['timestamp']),
              ),
            );
      }

      // Step 2: Handle deletions
      final localTasks = await db.select(db.tasks).get();
      for (var localTask in localTasks) {
        log('Local task: ${localTask.id}');
        if (!existingTaskIds.contains(localTask.id)) {
          log('Deleting task: ${localTask.id}');
          await db.deleteTask(localTask.id);
        }
      }
    });
  }
}
