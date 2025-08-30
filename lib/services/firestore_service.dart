import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Save user profile details (e.g., name)
  Future<void> saveUserProfile({required String userId, required String name}) async {
    try {
      await _db.collection('users').doc(userId).set(
        {
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // Merge to avoid overwriting other user data
      );
      print('[FirestoreService] User profile saved for $userId: Name=$name');
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  // Get user profile details
  Future<Map<String, dynamic>?> getUserProfile({String? userId}) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        print('[FirestoreService] No authenticated user found');
        return null;
      }
      
      print('[FirestoreService] Fetching profile for user: $uid');
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        print('[FirestoreService] Profile found: ${doc.data()}');
        return doc.data()!;
      }
      print('[FirestoreService] No profile document found for user: $uid');
      return null;
    } catch (e) {
      print('[FirestoreService] Error fetching user profile: $e');
      // Return null instead of throwing to allow app to continue with defaults
      return null;
    }
  }

  // Placeholder for future syllabus content fetching
  Future<Map<String, dynamic>> getSyllabusContent() async {
    try {
      print('[FirestoreService] Fetching syllabus content...');
      final doc = await _db.collection('syllabus').doc('content').get();
      if (doc.exists && doc.data() != null) {
        print('[FirestoreService] Syllabus content found');
        return doc.data()!;
      }
      print('[FirestoreService] No syllabus content found in Firestore');
      return {}; // Return empty to trigger fallback to mock data
    } catch (e) {
      print('[FirestoreService] Error fetching syllabus content: $e');
      return {}; // Return empty to trigger fallback to mock data
    }
  }

  // Save user settings with better error handling
  Future<void> saveUserSettings(Map<String, String> settings) async {
    if (currentUserId == null) {
      print('[FirestoreService] Cannot save settings: No authenticated user');
      throw Exception('User not authenticated');
    }
    
    try {
      print('[FirestoreService] Saving settings for user: $currentUserId');
      await _db.collection('users').doc(currentUserId).set(
        {
          'settings': settings,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      print('[FirestoreService] Settings saved successfully');
    } catch (e) {
      print('[FirestoreService] Error saving user settings: $e');
      rethrow;
    }
  }

  // Get user settings with better error handling
  Future<Map<String, String>> getUserSettings() async {
    if (currentUserId == null) {
      print('[FirestoreService] No authenticated user for settings');
      return _getDefaultSettings();
    }
    
    try {
      print('[FirestoreService] Fetching settings for user: $currentUserId');
      final doc = await _db.collection('users').doc(currentUserId).get();
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('settings')) {
        final settings = Map<String, String>.from(doc.data()!['settings']);
        print('[FirestoreService] Settings found: $settings');
        return settings;
      }
      print('[FirestoreService] No settings found, returning defaults');
      return _getDefaultSettings();
    } catch (e) {
      print('[FirestoreService] Error fetching user settings: $e');
      // Return default settings instead of throwing
      return _getDefaultSettings();
    }
  }

  // Helper method for default settings
  Map<String, String> _getDefaultSettings() {
    return {
      'syllabus': 'CBC',
      'grade': 'Grade 1',
      'subject': 'Mathematics',
    };
  }

  // Save lesson plan
  Future<void> saveLessonPlan({
    required String title,
    required String content,
    required Map<String, String> metadata,
  }) async {
    if (currentUserId == null) return;
    try {
      await _db.collection('lesson_plans').add({
        'userId': currentUserId,
        'title': title,
        'content': content,
        'metadata': metadata,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('[FirestoreService] Lesson plan saved for $currentUserId');
    } catch (e) {
      print('Error saving lesson plan: $e');
      rethrow;
    }
  }

  // Save notes
  Future<void> saveNotes({
    required String title,
    required String content,
    required Map<String, String> metadata,
  }) async {
    if (currentUserId == null) return;
    try {
      await _db.collection('notes').add({
        'userId': currentUserId,
        'title': title,
        'content': content,
        'metadata': metadata,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('[FirestoreService] Notes saved for $currentUserId');
    } catch (e) {
      print('Error saving notes: $e');
      rethrow;
    }
  }
}
