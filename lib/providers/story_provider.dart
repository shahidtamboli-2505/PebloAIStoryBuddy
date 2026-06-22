import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum StoryState {
  initial,
  loadingTts,
  playingTts,
  ttsError,
  ttsCompleted,
  quizVisible,
  success,
}

class StoryNotifier extends StateNotifier<StoryState> {
  final FlutterTts _flutterTts = FlutterTts();
  String? _currentStoryText;

  StoryNotifier() : super(StoryState.initial) {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2); // Make it sound cute/kid-friendly

    _flutterTts.setStartHandler(() {
      if (mounted) state = StoryState.playingTts;
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        state = StoryState.ttsCompleted;
        // Automatically show quiz after TTS ends
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) showQuiz();
        });
      }
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        state = StoryState.ttsError;
        // Fallback to quiz visible so user doesn't get stuck if TTS fails
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) showQuiz();
        });
      }
    });
  }

  Future<void> playNarration(String text) async {
    state = StoryState.loadingTts;
    _currentStoryText = text;
    
    // Give UI a tiny moment to show loading state before blocking thread
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      if (mounted) {
        state = StoryState.ttsError;
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) showQuiz();
        });
      }
    }
  }

  Future<void> stopNarration() async {
    await _flutterTts.stop();
    if (mounted && state == StoryState.playingTts) {
      state = StoryState.initial;
    }
  }

  void showQuiz() {
    state = StoryState.quizVisible;
  }

  void setSuccess() {
    state = StoryState.success;
  }
  
  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}

final storyProvider = StateNotifierProvider.autoDispose<StoryNotifier, StoryState>((ref) {
  return StoryNotifier();
});
