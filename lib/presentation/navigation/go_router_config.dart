import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_project/presentation/screens/login.dart';
import 'package:test_project/presentation/screens/main_screen.dart';
import 'package:test_project/presentation/screens/register.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authChanges = FirebaseAuth.instance.authStateChanges();

  return GoRouter(
    initialLocation:
        FirebaseAuth.instance.currentUser == null ? '/login' : '/main',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            const RegisterScreen(), // Add RegisterScreen
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => MainScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final loggingInOrRegistering =
          state.uri.path == '/login' || state.uri.path == '/register';

      if (!isLoggedIn && !loggingInOrRegistering) {
        return '/login'; // Redirect to login if not logged in and not on login or register page
      }
      if (isLoggedIn && loggingInOrRegistering) {
        return '/main'; // Redirect to main if logged in and trying to access login or register page
      }
      return null; // Stay on the current route
    },
    refreshListenable: GoRouterRefreshStream(authChanges),
  );
});

/// A class to integrate a [Stream] with GoRouter's refresh functionality.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners(); // Notify GoRouter to refresh.
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
