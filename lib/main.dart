import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_project/presentation/navigation/go_router_config.dart';

import 'domain/providers/sync_service_provider.dart';
import 'domain/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final container = ProviderContainer();
  final syncService = container.read(syncServiceProvider);
  syncService.startRealTimeSync();
  runApp(ProviderScope(
    overrides: [
      syncServiceProvider.overrideWithValue(await initializeSyncService()),
    ],
    child: const MyApp(),
  ));
}

Future<SyncService> initializeSyncService() async {
  final container = ProviderContainer();
  final syncService = container.read(syncServiceProvider);
  await syncService.initialize();
  container.dispose();
  return syncService;
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Test Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
    );
  }
}
