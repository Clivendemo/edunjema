import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/openai_service.dart'; // NEW: Import OpenAIService
// Removed: import 'package:edunjema3/utils/logger.dart';

class LessonPlanGeneratorScreen extends StatefulWidget {
  const LessonPlanGeneratorScreen({super.key});

  @override
  State<LessonPlanGeneratorScreen> createState() => _LessonPlanGeneratorScreenState();
}

class _LessonPlanGeneratorScreenState extends State<LessonPlanGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _substrandSubtopicController = TextEditingController();
  final TextEditingController _numberOfStudentsController = TextEditingController();
  final TextEditingController _lessonTimeController = TextEditingController();

  String? _selectedSyllabus = 'CBC';
  String? _selectedGrade = 'Grade 1';
  String? _selectedSubject = 'Mathematics';
  String? _selectedStrandTopic;

  String? _generatedLessonPlan;
  bool _isGenerating = false;
  bool _isLoadingInitialData = true;
  String? _initialDataError;

  Map<String, dynamic> _syllabusContent = {};
  Map<String, String> _userSettings = {};

  final FirestoreService _firestoreService = FirestoreService();
  final OpenAIService _openAIService = OpenAIService(); // NEW: Re-added OpenAIService

  // Mock syllabus data for demonstration (still useful if Firestore is empty)
  final Map<String, dynamic> _mockSyllabusContent = {
    'CBC': {
  'Grade 1': {
    'Mathematics': {
      'Numbers': ['Counting', 'Number Recognition', 'Basic Operations'],
      'Geometry': ['Shapes', 'Patterns', 'Spatial Awareness'],
      'Measurement': ['Length', 'Weight', 'Time'],
    },
    'English': {
      'Reading': ['Letter Recognition', 'Phonics', 'Simple Words'],
      'Writing': ['Letter Formation', 'Simple Sentences'],
      'Speaking': ['Vocabulary', 'Pronunciation'],
    },
    'Kiswahili': {
      'Kusoma': ['Herufi', 'Silabi', 'Maneno Rahisi'],
      'Kuandika': ['Kuunda Sentensi', 'Insha Fupi'],
    },
    'Environmental Activities': {
      'Our Environment': ['Plants', 'Animals', 'Weather'],
      'Hygiene and Nutrition': ['Personal Hygiene', 'Healthy Eating'],
    },
    'Religious Education': {
      'Christian Religious Education': ['Creation', 'Love', 'Prayer'],
      'Islamic Religious Education': ['Allah is Creator', 'Respect', 'Kindness'],
      'Hindu Religious Education': ['God is One', 'Festivals', 'Good Conduct']
    },
    'Art and Craft': {
      'Drawing': ['Shapes', 'Objects'],
      'Painting': ['Finger Painting', 'Colour Mixing'],
      'Modelling': ['Clay Play', 'Paper Folding'],
    },
    'Music': {
      'Singing': ['Songs with Actions', 'Call and Response Songs'],
      'Instruments': ['Shakers', 'Drums'],
      'Rhythm': ['Clapping Patterns', 'Movement to Beat'],
    },
    'Physical Education': {
      'Games': ['Tag Games', 'Relay Games'],
      'Athletics': ['Running', 'Jumping'],
      'Gymnastics': ['Balancing', 'Body Movement'],
    },
  },
  'Grade 2': {
    'Mathematics': {
      'Numbers': ['Addition', 'Subtraction', 'Place Value', 'Multiplication', 'Division'],
      'Geometry': ['2D Shapes', '3D Objects', 'Symmetry'],
      'Measurement': ['Money', 'Time', 'Capacity', 'Mass'],
    },
    'English': {
      'Reading': ['Reading Comprehension', 'Story Telling'],
      'Writing': ['Paragraph Writing', 'Creative Writing'],
      'Speaking': ['Vocabulary Building', 'Conversations'],
    },
    'Kiswahili': {
      'Sarufi': ['Nomino', 'Vitendo', 'Vivumishi'],
      'Ufahamu': ['Hadithi Fupi', 'Mashairi'],
      'Kuandika': ['Sentensi Rahisi', 'Insha'],
    },
    'Environmental Activities': {
      'Our Environment': ['Ecosystems', 'Pollution', 'Conservation'],
      'Hygiene and Nutrition': ['Balanced Diet', 'Diseases', 'First Aid'],
    },
    'Religious Education': {
      'Christian Religious Education': ['Bible Stories', 'Helping Others'],
      'Islamic Religious Education': ['Good Deeds', 'Prayers'],
      'Hindu Religious Education': ['Respect for Life', 'Sharing'],
    },
    'Art and Craft': {
      'Collage': ['Paper Tearing', 'Sticking'],
      'Printing': ['Leaf Printing', 'Block Printing'],
      'Weaving': ['Paper Weaving', 'Thread Patterns'],
    },
    'Music': {
      'Traditional Songs': ['Cultural Songs'],
      'Modern Songs': ['Simple English Songs'],
      'Dance': ['Traditional Dances', 'Freestyle'],
    },
    'Physical Education': {
      'Team Sports': ['Ball Games'],
      'Individual Sports': ['Running', 'Jumping'],
      'Fitness': ['Stretching', 'Warm-ups'],
    },
  },
  'Grade 3': {
    'Mathematics': {
      'Numbers': ['Fractions', 'Decimals', 'Patterns'],
      'Geometry': ['Area', 'Perimeter', 'Volume'],
      'Data Handling': ['Graphs', 'Charts'],
    },
    'English': {
      'Grammar': ['Tenses', 'Conjunctions', 'Prepositions'],
      'Literature': ['Fables', 'Folktales'],
      'Writing': ['Letters', 'Compositions'],
    },
    'Kiswahili': {
      'Sarufi': ['Vitenzi', 'Viambishi'],
      'Insha': ['Barua', 'Hadithi'],
      'Kusoma': ['Mashairi', 'Methali'],
    },
    'Science and Technology': {
      'Living Things': ['Plants', 'Animals', 'Human Body'],
      'Matter and Energy': ['States of Matter', 'Light', 'Sound'],
    },
    'Social Studies': {
      'Our Community': ['Family', 'Culture', 'Leadership'],
      'Resources': ['Natural Resources', 'Conservation'],
    },
    'Religious Education': {
      'Christian Religious Education': ['Jesus’ Life', 'Ten Commandments'],
      'Islamic Religious Education': ['Pillars of Islam', 'Good Morals'],
      'Hindu Religious Education': ['Epics', 'Worship'],
    },
    'Art and Craft': {
      'Sculpture': ['Clay Models'],
      'Pottery': ['Basic Shaping'],
      'Textile Art': ['Decorative Art'],
    },
    'Music': {
      'Music Theory': ['Notes', 'Pitch'],
      'Choir': ['Group Singing'],
      'Instrumental Music': ['Simple Instruments'],
    },
    'Physical Education': {
      'Athletics': ['Races', 'Jumps'],
      'Ball Games': ['Football Basics'],
      'Gymnastics': ['Flexibility', 'Coordination'],
    },
  },
  'Grade 4': {
    'Mathematics': {
      'Numbers': ['Place Value', 'Whole Numbers', 'Factors & Multiples'],
      'Geometry': ['Angles', 'Lines and Shapes'],
      'Measurement': ['Time', 'Length', 'Mass', 'Capacity'],
      'Data Handling': ['Tables', 'Bar Graphs'],
    },
    'English': {
      'Reading': ['Comprehension', 'Silent Reading'],
      'Writing': ['Story Writing', 'Dialogue'],
      'Grammar': ['Articles', 'Tenses', 'Punctuation'],
    },
    'Kiswahili': {
      'Kusoma': ['Ufahamu', 'Hadithi'],
      'Sarufi': ['Nomino', 'Viunganishi'],
      'Insha': ['Insha ya Maelezo', 'Insha ya Maoni'],
    },
    'Science and Technology': {
      'Human Body': ['Systems and Functions'],
      'Energy': ['Heat', 'Light'],
      'Materials': ['Properties and Changes'],
    },
    'Social Studies and Religious Education': {
      'Civics': ['Rights and Responsibilities'],
      'Geography': ['Environment and Resources'],
    },
    'Home Science': {
      'Nutrition': ['Balanced Diet'],
      'Health': ['Hygiene and Sanitation'],
    },
    'Agriculture': {
      'Crop Production': ['Planting Techniques'],
    },
    'Art and Craft': {
      'Drawing': ['Natural Objects'],
    },
    'Music': {
      'Singing': ['Folk Songs'],
    },
    'Physical and Health Education': {
      'Fitness': ['Body Movements'],
    },
    'Business Studies': {
      'Introduction to Business': ['Needs and Wants'],
    },
    'Computer Studies': {
      'Computer Basics': ['Parts of a Computer'],
    },
  },
  'Grade 5': {
    'Mathematics': {},
    'English': {},
    'Kiswahili': {},
    'Science and Technology': {},
    'Social Studies and Religious Education': {},
    'Home Science': {},
    'Agriculture': {},
    'Art and Craft': {},
    'Music': {},
    'Physical and Health Education': {},
    'Business Studies': {},
    'Computer Studies': {},
  },
  'Grade 6': {
    'Mathematics': {},
    'English': {},
    'Kiswahili': {},
    'Science and Technology': {},
    'Social Studies and Religious Education': {},
    'Home Science': {},
    'Agriculture': {},
    'Art and Craft': {},
    'Music': {},
    'Physical and Health Education': {},
    'Business Studies': {},
    'Computer Studies': {},
  },
  'Grade 7': {
    'Mathematics': {},
    'English': {},
    'Kiswahili': {},
    'Integrated Science': {},
    'Social Studies': {},
    'Religious Education': {},
    'Pre-Technical Studies': {},
    'Visual Arts': {},
    'Performing Arts': {},
    'Home Science': {},
    'Computer Science': {},
    'Business Studies': {},
    'Agriculture and Nutrition': {},
    'Sports and Physical Education': {},
  },
  'Grade 8': {
    'Mathematics': {},
    'English': {},
    'Kiswahili': {},
    'Integrated Science': {},
    'Social Studies': {},
    'Religious Education': {},
    'Pre-Technical Studies': {},
    'Visual Arts': {},
    'Performing Arts': {},
    'Home Science': {},
    'Computer Science': {},
    'Business Studies': {},
    'Agriculture and Nutrition': {},
    'Sports and Physical Education': {},
  },
  'Grade 9': {
    'Mathematics': {},
    'English': {},
    'Kiswahili': {},
    'Integrated Science': {},
    'Social Studies': {},
    'Religious Education': {},
    'Pre-Technical Studies': {},
    'Visual Arts': {},
    'Performing Arts': {},
    'Home Science': {},
    'Computer Science': {},
    'Business Studies': {},
    'Agriculture and Nutrition': {},
    'Sports and Physical Education': {},
  },
  'Grade 10': {
    'Mathematics': {},
    'English': {},
    'Kiswahili': {},
    'Biology': {},
    'Chemistry': {},
    'Physics': {},
    'History': {},
    'Geography': {},
    'Business Studies': {},
    'Agriculture': {},
    'Computer Studies': {},
    'Art and Design': {},
    'Music': {},
    'French': {},
    'German': {},
    'Arabic': {},
    'Home Science': {},
    'Religious Education': {},
  }
},
    '8-4-4': {
      'Form 2': {
        'Mathematics': {
          'Commercial Arithmetic': ['Profit and Loss', 'Simple and Compound Interest'],
          'Circles': ['Chords', 'Tangents', 'Arcs'],
          'Matrices': ['Types of Matrices', 'Operations'],
        },
        'English': {
          'Grammar': ['Active and Passive Voice', 'Reported Speech'],
          'Literature': ['Plays', 'Novels'],
          'Composition': ['Argumentative Essays', 'Narrative Essays'],
        },
        'Kiswahili': {
          'Fasihi Simulizi': ['Hadithi', 'Methali', 'Vitendawili'],
          'Sarufi': ['Ngeli', 'Nyakati', 'Viambishi'],
          'Insha': ['Insha za Kawaida', 'Insha za Hoja'],
        },
        'Biology': {
          'Transport in Plants and Animals': ['Circulatory System', 'Transpiration'],
          'Gaseous Exchange': ['Respiration in Animals', 'Photosynthesis in Plants'],
        },
        'Chemistry': {
          'Structure and Bonding': ['Ionic', 'Covalent', 'Metallic'],
          'Carbon and its Compounds': ['Alkanes', 'Alkenes', 'Alkynes'],
        },
        'Physics': {
          'Magnetism': ['Magnetic Fields', 'Electromagnetism'],
          'Current Electricity': ['Ohm\'s Law', 'Circuits'],
        },
        'History': {
          'Early Man': ['Evolution', 'Stone Age'],
          'Trade': ['Local', 'Regional', 'International'],
        },
        'Geography': {
          'Internal Land Forming Processes': ['Folding', 'Faulting', 'Volcanicity'],
          'External Land Forming Processes': ['Weathering', 'Erosion', 'Deposition'],
        },
        'Religious Education (CRE/IRE/HRE)': {},
        'Business Studies': {}, 'Agriculture': {}, 'Computer Studies': {},
        'Art and Design': {}, 'Music': {}, 'French': {}, 'German': {}, 'Arabic': {},
        'Home Science': {}, 'Woodwork': {}, 'Metalwork': {}, 'Building Construction': {},
        'Power Mechanics': {}, 'Electricity': {}, 'Drawing and Design': {},
        'Aviation Technology': {},
      },
      'Form 3': {
        'Mathematics': {}, 'English': {}, 'Kiswahili': {},
        'Biology': {}, 'Chemistry': {}, 'Physics': {},
        'History': {}, 'Geography': {}, 'Religious Education (CRE/IRE/HRE)': {},
        'Business Studies': {}, 'Agriculture': {}, 'Computer Studies': {},
        'Art and Design': {}, 'Music': {}, 'French': {}, 'German': {}, 'Arabic': {},
        'Home Science': {}, 'Woodwork': {}, 'Metalwork': {}, 'Building Construction': {},
        'Power Mechanics': {}, 'Electricity': {}, 'Drawing and Design': {},
        'Aviation Technology': {},
      },
      'Form 4': {
        'Mathematics': {}, 'English': {}, 'Kiswahili': {},
        'Biology': {}, 'Chemistry': {}, 'Physics': {},
        'History': {}, 'Geography': {}, 'Religious Education (CRE/IRE/HRE)': {},
        'Business Studies': {}, 'Agriculture': {}, 'Computer Studies': {},
        'Art and Design': {}, 'Music': {}, 'French': {}, 'German': {}, 'Arabic': {},
        'Home Science': {}, 'Woodwork': {}, 'Metalwork': {}, 'Building Construction': {},
        'Power Mechanics': {}, 'Electricity': {}, 'Drawing and Design': {},
        'Aviation Technology': {},
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
      _isLoadingInitialData = true;
      _initialDataError = null;
    });
    
    try {
      // Try to load from Firestore, fallback to mock data
      _syllabusContent = await _firestoreService.getSyllabusContent();
      if (_syllabusContent.isEmpty) {
        _syllabusContent = _mockSyllabusContent;
      }
      
      _userSettings = await _firestoreService.getUserSettings();
      if (_userSettings.isNotEmpty) {
        setState(() {
          _selectedSyllabus = _userSettings['syllabus'] ?? 'CBC';
          _selectedGrade = _userSettings['grade'] ?? 'Grade 1';
          _selectedSubject = _userSettings['subject'] ?? 'Mathematics';
        });
      }
    } catch (e) {
      print('Error loading initial lesson plan data: $e');
      // Use mock data as fallback
      _syllabusContent = _mockSyllabusContent;
      setState(() {
        _initialDataError = null; // Don't show error, just use mock data
      });
    } finally {
      setState(() {
        _isLoadingInitialData = false;
      });
    }
  }

  @override
  void dispose() {
    _substrandSubtopicController.dispose();
    _numberOfStudentsController.dispose();
    _lessonTimeController.dispose();
    super.dispose();
  }

  void _generateLessonPlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedLessonPlan = null;
    });

    try {
      // NEW: Call the actual OpenAI service
      final generatedContent = await _openAIService.generateLessonPlan(
        syllabus: _selectedSyllabus!,
        grade: _selectedGrade!,
        subject: _selectedSubject!,
        strandTopic: _selectedStrandTopic!,
        substrandSubtopic: _substrandSubtopicController.text.trim(),
        numberOfStudents: int.parse(_numberOfStudentsController.text.trim()),
        lessonTimeMinutes: int.parse(_lessonTimeController.text.trim()),
      );

      setState(() {
        _generatedLessonPlan = generatedContent;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson plan generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating lesson plan: $e')),
        );
        setState(() {
          _generatedLessonPlan = 'Error: $e';
        });
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Plan Generator'),
        centerTitle: true,
      ),
      body: _isLoadingInitialData
          ? const Center(child: CircularProgressIndicator())
          : _initialDataError != null
              ? Center(child: Text('Error: $_initialDataError'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generate a new lesson plan',
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
                                  'Lesson Details',
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
                                      _selectedStrandTopic = null;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

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
                                      _selectedStrandTopic = null;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

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
                                      _selectedStrandTopic = null;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

                                DropdownButtonFormField<String>(
                                  value: _selectedStrandTopic,
                                  decoration: InputDecoration(
                                    labelText: _selectedSyllabus == 'CBC' ? 'Strand' : 'Topic',
                                    prefixIcon: const Icon(Icons.category),
                                  ),
                                  items: (_selectedSyllabus != null && _selectedGrade != null && _selectedSubject != null)
                                      ? (_syllabusContent[_selectedSyllabus!]?[_selectedGrade!]?[_selectedSubject!] as Map<String, dynamic>?)
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
                                      _selectedStrandTopic = newValue;
                                    });
                                  },
                                  validator: (value) => value == null ? 'Please select a ${_selectedSyllabus == 'CBC' ? 'strand' : 'topic'}' : null,
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _substrandSubtopicController,
                                  decoration: InputDecoration(
                                    labelText: _selectedSyllabus == 'CBC' ? 'Substrand' : 'Subtopic',
                                    hintText: _selectedSyllabus == 'CBC' ? 'e.g., Whole Numbers' : 'e.g., Parts of Speech',
                                    prefixIcon: const Icon(Icons.subtitles),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a ${_selectedSyllabus == 'CBC' ? 'substrand' : 'subtopic'}.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _numberOfStudentsController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Number of Students',
                                    hintText: 'e.g., 30',
                                    prefixIcon: Icon(Icons.people),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the number of students.';
                                    }
                                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                      return 'Please enter a valid number.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _lessonTimeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Time of Lesson (minutes)',
                                    hintText: 'e.g., 40',
                                    prefixIcon: Icon(Icons.timer),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the lesson duration.';
                                    }
                                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                      return 'Please enter a valid duration in minutes.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                Center(
                                  child: _isGenerating
                                      ? const CircularProgressIndicator()
                                      : ElevatedButton(
                                          onPressed: _generateLessonPlan,
                                          child: const Text('Generate Lesson Plan'),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_generatedLessonPlan != null) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Generated Lesson Plan',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SelectableText(
                                _generatedLessonPlan!,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}
