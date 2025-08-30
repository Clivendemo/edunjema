import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('[AuthService] Attempting to sign in with email: $email');
      return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print('[AuthService] FirebaseAuthException during signIn: Code: ${e.code}, Message: ${e.message}');
      
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'api-key-not-valid.-please-pass-a-valid-api-key.':
          errorMessage = 'Firebase configuration error. Please check your API key.';
          break;
        default:
          errorMessage = e.message ?? 'An unknown error occurred during sign-in.';
      }
      
      throw errorMessage;
    } catch (e, st) {
      print('[AuthService] Unexpected error during signIn. Type: ${e.runtimeType}, Message: $e');
      print('Stack Trace: $st');
      throw 'An unexpected error occurred during sign-in: ${e.toString()}';
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      print('[AuthService] Attempting to create user with email: $email');
      
      // Validate inputs before making the Firebase call
      if (email.isEmpty || !email.contains('@')) {
        throw 'Please provide a valid email address.';
      }
      if (password.isEmpty || password.length < 6) {
        throw 'Password must be at least 6 characters long.';
      }
      
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      print('[AuthService] User created successfully: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('[AuthService] FirebaseAuthException during createUser: Code: ${e.code}, Message: ${e.message}');
      
      // Provide more user-friendly error messages based on error codes
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'api-key-not-valid.-please-pass-a-valid-api-key.':
          errorMessage = 'Firebase configuration error. Please run "flutterfire configure" to fix your setup.';
          break;
        default:
          errorMessage = e.message ?? 'An unknown error occurred during registration.';
      }
      
      throw errorMessage;
    } catch (e, st) {
      print('[AuthService] Unexpected error during createUser. Type: ${e.runtimeType}, Message: $e');
      print('Stack Trace: $st');
      
      // If it's already a string (like our validation errors), just rethrow it
      if (e is String) {
        throw e;
      }
      
      throw 'An unexpected error occurred during registration: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    try {
      print('[AuthService] Attempting to sign out...');
      await _firebaseAuth.signOut();
      print('[AuthService] Sign out successful.');
    } catch (e, st) {
      print('[AuthService] Error during signOut. Type: ${e.runtimeType}, Message: $e');
      print('Stack Trace: $st');
      rethrow;
    }
  }
}
