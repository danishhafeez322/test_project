import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_project/data/local/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});
