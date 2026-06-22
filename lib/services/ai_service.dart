/// ai_service.dart — Handles generating stories with Google Gemini API
library;

import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/story_data.dart';

class AiService {
  // TODO: Replace with your actual Gemini API key or inject it securely
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  Future<StoryData> generateStory(String topic) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      throw Exception('API Key not set. Please add your Gemini API key in ai_service.dart.');
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );

    final prompt = '''
Write a short, engaging, kid-friendly story (about 100-150 words) about: $topic.
The story should feature Pip the Robot.
After the story, create a 1-question multiple choice quiz about the story.

You MUST respond ONLY with a raw JSON object matching exactly this structure:
{
  "title": "Title of the story",
  "text": "The full story text goes here...",
  "theme": "$topic",
  "quiz": {
    "question": "What is the question?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "answer": "Option B"
  }
}
Do not include any markdown formatting (like ```json), just the raw JSON object.
''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    
    final rawText = response.text ?? '';
    // Strip markdown blocks if the AI accidentally adds them
    final cleanJsonStr = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
    
    try {
      final jsonMap = jsonDecode(cleanJsonStr) as Map<String, dynamic>;
      return StoryData.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }
}
