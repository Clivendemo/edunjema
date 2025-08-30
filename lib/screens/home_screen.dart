import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:edunjema3/services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // NEW: Import for Riverpod
import '../providers/auth_provider.dart'; // NEW: Import authProvider

class HomeScreen extends ConsumerStatefulWidget { // MODIFIED: Changed to ConsumerStatefulWidget
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState(); // MODIFIED
}

class _HomeScreenState extends ConsumerState<HomeScreen> { // MODIFIED
  final FirestoreService _firestoreService = FirestoreService();
  String _userName = 'Teacher';
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      print('[HomeScreen] Loading user profile...');
      final profile = await _firestoreService.getUserProfile();
      if (profile != null && profile.containsKey('name')) {
        setState(() {
          _userName = profile['name'] ?? 'Teacher';
        });
        print('[HomeScreen] Profile loaded: $_userName');
      } else {
        print('[HomeScreen] No profile found, using default name');
        setState(() {
          _userName = 'Teacher';
        });
      }
    } catch (e) {
      print('[HomeScreen] Error loading user profile: $e');
      setState(() {
        _userName = 'Teacher';
      });
    } finally {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      // MODIFIED: Use ref.read to access authServiceProvider
      await ref.read(authServiceProvider).signOut();
      // GoRouter's redirect will handle navigation back to AuthScreen
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {'name': 'Lesson Plan Generator', 'icon': Icons.school, 'route': '/lesson-plan-generator'},
      {'name': 'Notes Generator', 'icon': Icons.edit_note, 'route': '/notes-generator'},
      {'name': 'Saved Plans', 'icon': Icons.save, 'route': '/saved-plans'},
      {'name': 'Settings', 'icon': Icons.settings, 'route': '/settings'},
      {'name': 'FAQs / Help', 'icon': Icons.help_outline, 'route': '/faq-help'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher AI Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: _isLoadingProfile
                  ? const CircularProgressIndicator()
                  : Text(
                      'Welcome, $_userName!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.2,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      context.go(feature['route']);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            feature['icon'],
                            size: 48,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            feature['name'],
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
