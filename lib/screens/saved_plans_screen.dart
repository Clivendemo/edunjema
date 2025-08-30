import 'package:flutter/material.dart';

class SavedPlansScreen extends StatefulWidget {
  const SavedPlansScreen({super.key});

  @override
  State<SavedPlansScreen> createState() => _SavedPlansScreenState();
}

class _SavedPlansScreenState extends State<SavedPlansScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for demonstration
  final List<Map<String, dynamic>> _mockLessonPlans = [
    {
      'title': 'Introduction to Numbers',
      'subject': 'Mathematics',
      'grade': 'Grade 1',
      'date': '2024-01-15',
      'content': 'A comprehensive lesson plan on basic number recognition...',
    },
    {
      'title': 'Parts of Speech',
      'subject': 'English',
      'grade': 'Grade 2',
      'date': '2024-01-14',
      'content': 'Understanding nouns, verbs, and adjectives...',
    },
    {
      'title': 'Plant Growth',
      'subject': 'Science',
      'grade': 'Grade 3',
      'date': '2024-01-13',
      'content': 'How plants grow and what they need to survive...',
    },
  ];

  final List<Map<String, dynamic>> _mockNotes = [
    {
      'title': 'Fractions Basics',
      'subject': 'Mathematics',
      'grade': 'Grade 4',
      'date': '2024-01-15',
      'content': 'Understanding halves, quarters, and simple fractions...',
    },
    {
      'title': 'Kenya\'s Geography',
      'subject': 'Social Studies',
      'grade': 'Grade 5',
      'date': '2024-01-14',
      'content': 'Physical features, climate, and regions of Kenya...',
    },
    {
      'title': 'Simple Machines',
      'subject': 'Science',
      'grade': 'Grade 6',
      'date': '2024-01-13',
      'content': 'Levers, pulleys, and inclined planes in daily life...',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Plans'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Lesson Plans', icon: Icon(Icons.school)),
            Tab(text: 'Notes', icon: Icon(Icons.note)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContentList(_mockLessonPlans, 'lesson plans'),
          _buildContentList(_mockNotes, 'notes'),
        ],
      ),
    );
  }

  Widget _buildContentList(List<Map<String, dynamic>> items, String type) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'lesson plans' ? Icons.school_outlined : Icons.note_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No saved $type yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate some content to see it here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              item['title'],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${item['subject']} • ${item['grade']}'),
                const SizedBox(height: 4),
                Text(
                  'Created: ${item['date']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _viewContent(context, item);
                    break;
                  case 'share':
                    _shareContent(item);
                    break;
                  case 'delete':
                    _deleteContent(item);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('View'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            onTap: () => _viewContent(context, item),
          ),
        );
      },
    );
  }

  void _viewContent(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['title']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${item['subject']} • ${item['grade']}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 16),
              Text(item['content']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _shareContent(item);
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _shareContent(Map<String, dynamic> item) {
    // TODO: Implement actual sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${item['title']}" - Feature coming soon!'),
      ),
    );
  }

  void _deleteContent(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Content'),
        content: Text('Are you sure you want to delete "${item['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement actual deletion
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${item['title']}"'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
