import 'package:cloud_firestore/cloud_firestore.dart';

class TaskRepository {
  final CollectionReference tasksRef =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(String title) async {
    await tasksRef.add({
      'title': title,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTask(String id) async {
    await tasksRef.doc(id).delete();
  }

  Stream<List<Map<String, dynamic>>> getTasksStream() {
    return tasksRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList());
  }
}
