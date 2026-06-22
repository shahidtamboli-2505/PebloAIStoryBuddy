/// story_data.dart — Model for a full story with its quiz.
library;

import 'dart:convert';
import 'quiz_model.dart';

/// Represents a generated story and its associated quiz.
class StoryData {
  final String id;
  final String title;
  final String text;
  final String theme;
  final QuizModel quiz;
  final DateTime createdAt;

  StoryData({
    required this.id,
    required this.title,
    required this.text,
    required this.theme,
    required this.quiz,
    required this.createdAt,
  });

  /// Factory to parse from AI-generated JSON or SharedPreferences JSON
  factory StoryData.fromJson(Map<String, dynamic> json) {
    return StoryData(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'A New Adventure',
      text: json['text'] as String,
      theme: json['theme'] as String? ?? 'General',
      quiz: QuizModel.fromJson(json['quiz'] as Map<String, dynamic>),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'theme': theme,
      'quiz': quiz.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
