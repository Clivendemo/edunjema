import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedSyllabus;
  String? _selectedGrade;
  String? _selectedSubject;

  bool _isLoadingSettings = true;
  String? _settingsError;
  Map<String, dynamic> _syllabusContent = {};
  Map<String, String> _userSettings = {};

  final FirestoreService _firestoreService = FirestoreService();

  // Mock syllabus data for demonstration
  final Map<String, dynamic> _mockSyllabusContent = {
    'CBC': {
      'Grade 1': {
        'Mathematics': {},
        'English': {},
        'Kiswahili': {},
        'Environmental Activities': {},
      },
      'Grade 2': {
        'Mathematics': {},
        'English': {},
        'Kiswahili': {},
        'Environmental Activities': {},
      },
      'Grade 3': {
        'Mathematics': {},
        'English': {},
        'Kiswahili': {},
        'Environmental Activities': {},
        'Social Studies': {},
        'Science and Technology': {},
      },
    },
    '8-4-4': {
      'Form 1': {
        'Mathematics': {},
        'English': {},
        'Kiswahili': {},
        'Biology': {},
        'Chemistry': {},
        'Physics': {},
        'History': {},
        'Geography': {},
      },
      'Form 2': {
        'Mathematics': {},
        'English': {},
        'Kiswahili': {},
        'Biology': {},
        'Chemistry': {},
        'Physics': {},
        'History': {},
        'Geography': {},
      },
    },
  };

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingSettings = true;
      _settingsError = null;
    });
    try {
      // Try to load from Firestore, fallback to mock data
      _syllabusContent = await _firestoreService.getSyllabusContent();
      if (_syllabusContent.isEmpty) {
        _syllabusContent = _mockSyllabusContent;
      }
      
      _userSettings = await _firestoreService.getUserSettings();

      setState(() {
        _selectedSyllabus = _userSettings['syllabus'] ?? 'CBC';
        _selectedGrade = _userSettings['grade'] ?? 'Grade 1';
        _selectedSubject = _userSettings['subject'] ?? 'Mathematics';
      });
    } catch (e) {
      print('Error loading initial settings data: $e');
      // Use mock data as fallback
      _syllabusContent = _mockSyllabusContent;
      setState(() {
        _selectedSyllabus = 'CBC';
        _selectedGrade = 'Grade 1';
        _selectedSubject = 'Mathematics';
        _settingsError = null; // Don't show error, just use defaults
      });
    } finally {
      setState(() {
        _isLoadingSettings = false;
      });
    }
  }

  void _saveSettings() async {
    setState(() {
      _isLoadingSettings = true;
      _settingsError = null;
    });
    try {
      final newSettings = {
        'syllabus': _selectedSyllabus ?? '',
        'grade': _selectedGrade ?? '',
        'subject': _selectedSubject ?? '',
      };
      await _firestoreService.saveUserSettings(newSettings);
      setState(() {
        _userSettings = newSettings;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
      }
    } catch (e) {
      print('Error saving settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
        setState(() {
          _settingsError = 'Failed to save settings: $e';
        });
      }
    } finally {
      setState(() {
        _isLoadingSettings = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: _isLoadingSettings
          ? const Center(child: CircularProgressIndicator())
          : _settingsError != null
              ? Center(child: Text('Error: $_settingsError'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personalize your experience',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Teaching Preferences',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedSyllabus,
                                decoration: const InputDecoration(
                                  labelText: 'Syllabus',
                                  prefixIcon: Icon(Icons.menu_book),
                                ),
                                items: _syllabusContent.keys.map<DropdownMenuItem<String>>((item) {
                                  return DropdownMenuItem<String>(
                                    value: item.toString(),
                                    child: Text(item.toString()),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedSyllabus = newValue;
                                    _selectedGrade = null;
                                    _selectedSubject = null;
                                  });
                                },
                                validator: (value) => value == null ? 'Please select a syllabus' : null,
                              ),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                value: _selectedGrade,
                                decoration: const InputDecoration(
                                  labelText: 'Grade/Form',
                                  prefixIcon: Icon(Icons.grade),
                                ),
                                items: _selectedSyllabus != null
                                    ? (_syllabusContent[_selectedSyllabus!] as Map<String, dynamic>?)
                                        ?.keys
                                        .map<DropdownMenuItem<String>>((item) {
                                          return DropdownMenuItem<String>(
                                            value: item.toString(),
                                            child: Text(item.toString()),
                                          );
                                        }).toList() ?? []
                                    : [],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedGrade = newValue;
                                    _selectedSubject = null;
                                  });
                                },
                                validator: (value) => value == null ? 'Please select a grade/form' : null,
                              ),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                value: _selectedSubject,
                                decoration: const InputDecoration(
                                  labelText: 'Subject',
                                  prefixIcon: Icon(Icons.subject),
                                ),
                                items: (_selectedSyllabus != null && _selectedGrade != null)
                                    ? (_syllabusContent[_selectedSyllabus!]?[_selectedGrade!] as Map<String, dynamic>?)
                                        ?.keys
                                        .map<DropdownMenuItem<String>>((item) {
                                          return DropdownMenuItem<String>(
                                            value: item.toString(),
                                            child: Text(item.toString()),
                                          );
                                        }).toList() ?? []
                                    : [],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedSubject = newValue;
                                  });
                                },
                                validator: (value) => value == null ? 'Please select a subject' : null,
                              ),
                              const SizedBox(height: 32),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _isLoadingSettings ? null : _saveSettings,
                                  child: _isLoadingSettings
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text('Save Settings'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'App Information',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              const ListTile(
                                leading: Icon(Icons.info_outline),
                                title: Text('Version'),
                                subtitle: Text('1.0.0'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              const ListTile(
                                leading: Icon(Icons.developer_mode),
                                title: Text('Developer'),
                                subtitle: Text('Clive Ndemo'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
