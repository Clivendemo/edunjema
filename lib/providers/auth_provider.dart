import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edunjema3/services/auth_service.dart';
//import 'package:edunjema3/services/auth_service.dart';

// State for authentication
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier for authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _authService.authStateChanges.listen((user) {
      print('[AuthNotifier] Auth state changed. User: ${user?.email ?? 'null'}');
      state = state.copyWith(user: user, isLoading: false, error: null);
    });
  }

  Future<void> signIn(String email, String password) async {
    print('[AuthNotifier] Attempting signIn for $email');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      print('[AuthNotifier] Sign in successful for $email');
    } catch (e, st) { // MODIFIED: Capture stack trace
      print('[AuthNotifier] Sign in failed for $email. Exception Type: ${e.runtimeType}, Message: $e'); // MODIFIED: More detailed print
      print('Stack Trace: $st'); // NEW: Print stack trace
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String email, String password) async {
    print('[AuthNotifier] Attempting register for $email');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.createUserWithEmailAndPassword(email, password);
      print('[AuthNotifier] Registration successful for $email');
    } catch (e, st) { // MODIFIED: Capture stack trace
      print('[AuthNotifier] Registration failed for $email. Exception Type: ${e.runtimeType}, Message: $e'); // MODIFIED: More detailed print
      print('Stack Trace: $st'); // NEW: Print stack trace
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    print('[AuthNotifier] Attempting sign out...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signOut();
      print('[AuthNotifier] Sign out successful.');
    } catch (e, st) { // MODIFIED: Capture stack trace
      print('[AuthNotifier] Sign out failed. Exception Type: ${e.runtimeType}, Message: $e'); // MODIFIED: More detailed print
      print('Stack Trace: $st'); // NEW: Print stack trace
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    print('[AuthNotifier] Clearing error.');
    state = state.copyWith(error: null);
  }
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
