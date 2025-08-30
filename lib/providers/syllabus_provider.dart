import 'package:edunjema3/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:edunjema3/firebase_options.dart';

// NEW: Provider for FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

// NEW: AsyncNotifierProvider for syllabus content
// This will hold the entire syllabus structure fetched from Firestore
final syllabusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getSyllabusContent();
});
