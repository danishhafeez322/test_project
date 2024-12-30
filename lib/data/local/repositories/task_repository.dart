// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class TaskRepository {
//   final CollectionReference tasksRef =
//       FirebaseFirestore.instance.collection('tasks');
//
//   Future<void> addTask(String title) async {
//     await tasksRef.add({
//       'title': title,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
//
//   Future<void> deleteTask(String id) async {
//     await tasksRef.doc(id).delete();
//   }
//
//   Stream<List<Map<String, dynamic>>> getTasksStream() {
//     return tasksRef.snapshots().map((snapshot) => snapshot.docs
//         .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
//         .toList());
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskRepository {
  final CollectionReference tasksRef =
      FirebaseFirestore.instance.collection('tasks');

  /// Add a new task to Firestore
  Future<void> addTask(String id, String title, DateTime timestamp) async {
    try {
      await tasksRef.doc(id).set({
        'title': title,
        'timestamp': timestamp,
      });
    } catch (e) {
      print('Error adding task to Firestore: $e');
      rethrow;
    }
  }

  /// Delete a task from Firestore
  Future<void> deleteTask(String id) async {
    try {
      await tasksRef.doc(id).delete();
    } catch (e) {
      print('Error deleting task from Firestore: $e');
      rethrow;
    }
  }

  /// Get a stream of tasks from Firestore
  Stream<List<Map<String, dynamic>>> getTasksStream() {
    return tasksRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'],
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
        };
      }).toList();
    });
  }

  /// Get all tasks once (for initial sync or manual fetch)
  Future<List<Map<String, dynamic>>> fetchAllTasks() async {
    try {
      final querySnapshot = await tasksRef.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'],
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
        };
      }).toList();
    } catch (e) {
      print('Error fetching tasks from Firestore: $e');
      return [];
    }
  }
}
