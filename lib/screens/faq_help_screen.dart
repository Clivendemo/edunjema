import 'package:flutter/material.dart';

class FaqHelpScreen extends StatelessWidget {
  const FaqHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'question': 'How do I generate a lesson plan?',
        'answer': 'Go to the Lesson Plan Generator from the home screen, fill in the required details like subject, grade, topic, and other preferences, then tap "Generate Lesson Plan".'
      },
      {
        'question': 'How do I generate notes for a topic?',
        'answer': 'Navigate to the Notes Generator, select your syllabus, grade, subject, and specific topic/subtopic, then tap "Generate Notes" to create comprehensive study materials.'
      },
      {
        'question': 'Can I save my generated content?',
        'answer': 'Yes! All generated lesson plans and notes are automatically saved to your account and can be accessed from the "Saved Plans" section.'
      },
      {
        'question': 'How do I change my teaching preferences?',
        'answer': 'Go to Settings from the home screen where you can update your preferred syllabus (CBC or 8-4-4), grade level, and subject.'
      },
      {
        'question': 'What syllabuses are supported?',
        'answer': 'The app currently supports both CBC (Competency Based Curriculum) and 8-4-4 syllabuses for Kenyan education system.'
      },
      {
        'question': 'Is my data secure?',
        'answer': 'Yes, all your data is securely stored and encrypted. We follow best practices for data protection and privacy.'
      },
      {
        'question': 'Can I use the app offline?',
        'answer': 'The app requires an internet connection to generate new content, but you can view previously generated and saved content offline.'
      },
      {
        'question': 'How do I reset my password?',
        'answer': 'On the login screen, tap "Forgot Password" and follow the instructions sent to your email address.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ & Help'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final faq = faqs[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    title: Text(
                      faq['question']!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          faq['answer']!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need More Help?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'If you can\'t find the answer to your question above, feel free to contact our support team.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement email support
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Email support coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.email),
                            label: const Text('Email Support'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implement chat support
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Chat support coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text('Live Chat'),
                          ),
                        ),
                      ],
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
                      'Quick Tips',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildTipItem(
                      context,
                      Icons.lightbulb_outline,
                      'Set your preferences in Settings for faster content generation',
                    ),
                    _buildTipItem(
                      context,
                      Icons.bookmark_outline,
                      'Save important lesson plans and notes for quick access',
                    ),
                    _buildTipItem(
                      context,
                      Icons.refresh,
                      'Regenerate content if you\'re not satisfied with the first result',
                    ),
                    _buildTipItem(
                      context,
                      Icons.share,
                      'Share generated content with colleagues for collaboration',
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

  Widget _buildTipItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
