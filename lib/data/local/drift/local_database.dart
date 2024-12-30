import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test_project/data/local/drift/tasks.dart';

part 'local_database.g.dart';

@DriftDatabase(tables: [Tasks])
class LocalDatabase extends _$LocalDatabase {
  // Singleton instance
  static LocalDatabase? _instance;

  // Private constructor
  LocalDatabase._internal() : super(_openConnection());

  // Public factory constructor to access the singleton instance
  factory LocalDatabase() {
    _instance ??= LocalDatabase._internal();
    return _instance!;
  }
  @override
  int get schemaVersion => 1;

  // Add a new task
  Future<int> addTask(TasksCompanion task) =>
      into(tasks).insertOnConflictUpdate(task);

  // Watch all active (non-deleted) tasks
  Stream<List<Task>> watchActiveTasks() {
    return (select(tasks)..where((t) => t.deleted.equals(false))).watch();
  }

  // Watch all tasks (including deleted ones, if necessary)
  Stream<List<Task>> watchAllTasks() {
    return (select(tasks)..where((t) => t.deleted.equals(false))).watch();
  }

  // Fetch all locally deleted tasks for sync
  Future<List<Task>> fetchDeletedTasks() async {
    return (select(tasks)..where((t) => t.deleted.equals(true))).get();
  }

  // Mark a task as deleted
  Future<void> deleteTask(String taskId) async {
    await (update(tasks)..where((t) => t.id.equals(taskId)))
        .write(const TasksCompanion(deleted: Value(true)));
  }

  // Permanently delete a task from the database
  Future<void> permanentlyDeleteTask(String taskId) async {
    await (delete(tasks)..where((t) => t.id.equals(taskId))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/app.db');
    return NativeDatabase(file);
  });
}
