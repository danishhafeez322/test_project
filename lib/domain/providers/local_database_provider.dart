import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_project/data/local/drift/local_database.dart';

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase(); // Instantiates the Drift database
});
