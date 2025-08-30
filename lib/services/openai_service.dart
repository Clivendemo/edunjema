
import 'dart:convert'; // NEW: Import for JSON encoding/decoding
import 'package:http/http.dart' as http; // NEW: Import the http package

class OpenAIService {
 
  final String _vercelApiBaseUrl = 'https://myapp-mu-six.vercel.app/api/generate-content'; // NEW: Update with your actual Vercel API URL

  Future<String> generateLessonPlan({
    required String syllabus,
    required String grade,
    required String subject,
    required String strandTopic,
    required String substrandSubtopic,
    required int numberOfStudents,
    required int lessonTimeMinutes,
  }) async {
    try {
      print('[OpenAIService] Calling Vercel API for lesson plan...');
      final response = await http.post(
        Uri.parse(_vercelApiBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': 'lesson_plan',
          'syllabus': syllabus,
          'grade': grade,
          'subject': subject,
          'strandTopic': strandTopic,
          'substrandSubtopic': substrandSubtopic,
          'numberOfStudents': numberOfStudents,
          'lessonTimeMinutes': lessonTimeMinutes,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['content'] != null) {
          print('[OpenAIService] Lesson plan generated successfully.');
          return data['content'];
        } else {
          throw Exception('Vercel API did not return content.');
        }
      } else {
        print('[OpenAIService] Vercel API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to generate lesson plan: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[OpenAIService] Error connecting to AI service: $e');
      throw Exception('Error connecting to AI service: $e');
    }
  }

  Future<String> generateNotes({
    required String syllabus,
    required String grade,
    required String subject,
    required String strandTopic,
    required String substrandSubtopic,
  }) async {
    try {
      print('[OpenAIService] Calling Vercel API for notes...');
      final response = await http.post(
        Uri.parse(_vercelApiBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': 'notes',
          'syllabus': syllabus,
          'grade': grade,
          'subject': subject,
          'strandTopic': strandTopic,
          'substrandSubtopic': substrandSubtopic,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['content'] != null) {
          print('[OpenAIService] Notes generated successfully.');
          return data['content'];
        } else {
          throw Exception('Vercel API did not return content.');
        }
        
      } else {
        print('[OpenAIService] Vercel API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to generate notes: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[OpenAIService] Error connecting to AI service: $e');
      throw Exception('Error connecting to AI service: $e');
    }
  }
}

