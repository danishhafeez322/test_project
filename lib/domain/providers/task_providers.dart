import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_database_provider.dart';

final tasksStreamProvider = StreamProvider.autoDispose((ref) {
  final db = ref.watch(localDatabaseProvider);
  return db.watchAllTasks(); // A method in your Drift database to watch tasks
});
