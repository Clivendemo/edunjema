import 'package:edunjema3/providers/syllabus_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../providers/auth_provider.dart';

// Define the state for user settings (AsyncValue to handle loading/error)
typedef UserSettingsState = AsyncValue<Map<String, String>>;

// Notifier for user settings
class UserSettingsNotifier extends AsyncNotifier<Map<String, String>> {
  late final FirestoreService _firestoreService; // MODIFIED: Removed _currentUser field

  @override
  Future<Map<String, String>> build() async {
    _firestoreService = ref.watch(firestoreServiceProvider);

    // NEW: Watch the auth state directly. This will cause this AsyncNotifier to rebuild
    // whenever the user logs in or out, ensuring the latest user state is used.
    final user = ref.watch(authNotifierProvider.select((state) => state.user));

    if (user == null) {
      // If no user is logged in, return default settings
      return {
        'syllabus': 'CBC',
        'grade': 'Grade 1',
        'subject': 'Mathematics',
      };
    }
    // Load settings from Firestore for the logged-in user
    final settings = await _firestoreService.getUserSettings();
    if (settings.isEmpty) {
      // If no settings found in Firestore, return defaults
      return {
        'syllabus': 'CBC',
        'grade': 'Grade 1',
        'subject': 'Mathematics',
      };
    }
    return settings;
  }

  // Method to update and save settings
  Future<void> updateSettings({
    String? syllabus,
    String? grade,
    String? subject,
  }) async {
    // NEW: Get the current user from the watched state using ref.read
    final user = ref.read(authNotifierProvider.select((state) => state.user));

    if (user == null) {
      // Cannot save settings if no user is logged in
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading(); // Set state to loading
    try {
      final currentSettings = state.value ?? {}; // Get current settings or empty map
      final newSettings = {
        ...currentSettings,
        if (syllabus != null) 'syllabus': syllabus,
        if (grade != null) 'grade': grade,
        if (subject != null) 'subject': subject,
      };
      await _firestoreService.saveUserSettings(newSettings);
      state = AsyncValue.data(newSettings); // Update state with new data
    } catch (e, st) {
      state = AsyncError(e, st); // Set state to error
    }
  }
}

// AsyncNotifierProvider for user settings
final userSettingsProvider = AsyncNotifierProvider<UserSettingsNotifier, Map<String, String>>(() {
  return UserSettingsNotifier();
});
