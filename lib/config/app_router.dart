import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edunjema3/screens/auth_screen.dart';
import 'package:edunjema3/screens/home_screen.dart';
import 'package:edunjema3/screens/registration_screen.dart';
import 'package:edunjema3/screens/lesson_plan_generator_screen.dart';
import 'package:edunjema3/screens/notes_generator_screen.dart';
import 'package:edunjema3/screens/settings_screen.dart';
import 'package:edunjema3/screens/faq_help_screen.dart';
import 'package:edunjema3/screens/saved_plans_screen.dart';
//import 'package:edunjema3/config/config.dart';
import 'dart:async';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/lesson-plan-generator',
      builder: (context, state) => const LessonPlanGeneratorScreen(),
    ),
    GoRoute(
      path: '/notes-generator',
      builder: (context, state) => const NotesGeneratorScreen(),
    ),
    GoRoute(
      path: '/saved-plans',
      builder: (context, state) => const SavedPlansScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/faq-help',
      builder: (context, state) => const FaqHelpScreen(),
    ),
  ],
  redirect: (context, state) {
    final isAuthenticated = FirebaseAuth.instance.currentUser != null;
    final isLoggingIn = state.matchedLocation == '/';
    final isRegistering = state.matchedLocation == '/register';

    // If not authenticated and not on login/register screen, redirect to login
    if (!isAuthenticated && !isLoggingIn && !isRegistering) {
      return '/';
    }
    // If authenticated and trying to access login or register, redirect to home
    if (isAuthenticated && (isLoggingIn || isRegistering)) {
      return '/home';
    }
    // No redirect needed
    return null;
  },
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
);

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
