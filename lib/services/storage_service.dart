/// storage_service.dart — Handles saving and loading stories.
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story_data.dart';

class StorageService {
  static const String _storiesKey = 'peblo_saved_stories';

  /// Save a story to local storage
  Future<void> saveStory(StoryData story) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentStories = prefs.getStringList(_storiesKey) ?? [];
    
    // Convert to JSON and save
    currentStories.add(jsonEncode(story.toJson()));
    await prefs.setStringList(_storiesKey, currentStories);
  }

  /// Load all saved stories
  Future<List<StoryData>> getSavedStories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> storedStrings = prefs.getStringList(_storiesKey) ?? [];
    
    return storedStrings.map((str) {
      final json = jsonDecode(str) as Map<String, dynamic>;
      return StoryData.fromJson(json);
    }).toList().reversed.toList(); // Return newest first
  }

  /// Delete a story by ID
  Future<void> deleteStory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentStories = prefs.getStringList(_storiesKey) ?? [];
    
    final updatedList = currentStories.where((str) {
      final json = jsonDecode(str) as Map<String, dynamic>;
      return json['id'] != id;
    }).toList();
    
    await prefs.setStringList(_storiesKey, updatedList);
  }
}
