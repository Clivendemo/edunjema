import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/openai_service.dart'; // NEW: Import OpenAIService


// NEW: Provider for OpenAIService
final openAIServiceProvider = Provider<OpenAIService>((ref) => OpenAIService());
