/// library_provider.dart — State management for the saved stories library.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_data.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class LibraryNotifier extends StateNotifier<List<StoryData>> {
  final StorageService _storageService;

  LibraryNotifier(this._storageService) : super([]) {
    loadStories();
  }

  Future<void> loadStories() async {
    final stories = await _storageService.getSavedStories();
    state = stories;
  }

  Future<void> saveStory(StoryData story) async {
    // Prevent duplicate saves
    if (state.any((s) => s.id == story.id)) return;
    
    await _storageService.saveStory(story);
    await loadStories();
  }

  Future<void> deleteStory(String id) async {
    await _storageService.deleteStory(id);
    await loadStories();
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, List<StoryData>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return LibraryNotifier(storageService);
});
