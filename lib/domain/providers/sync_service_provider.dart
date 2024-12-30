import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_project/domain/providers/task_repository_provider.dart';
import 'package:test_project/domain/services/sync_service.dart';

import 'local_database_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(localDatabaseProvider);
  final taskRepo = ref.watch(taskRepositoryProvider);
  return SyncService(taskRepo, db);
});
