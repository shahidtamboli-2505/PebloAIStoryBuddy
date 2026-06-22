/// StoryProvider — Riverpod state management for story narration.
///
/// Manages the complete lifecycle of the narration flow:
/// Idle → Loading → Speaking → AudioComplete → QuizVisible
///
/// Also handles Error state with retry capability.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tts_service.dart';

// ---------------------------------------------------------------------------
// Story state enum
// ---------------------------------------------------------------------------

/// Represents every possible state in the narration lifecycle.
enum StoryState {
  /// Initial state — nothing has happened yet.
  idle,

  /// TTS engine is being prepared.
  loading,

  /// Story is being narrated aloud.
  speaking,

  /// Narration just finished; transitional state.
  audioComplete,

  /// Quiz section is now visible to the user.
  quizVisible,

  /// User answered the quiz correctly 🎉
  success,

  /// Something went wrong (TTS init, speech error, etc.)
  error,
}

// ---------------------------------------------------------------------------
// Story text constant
// ---------------------------------------------------------------------------

/// The story narrated to the child.
const String kStoryText =
    'Once upon a time, a clever little robot named Pip lost his shiny blue '
    'gear in the Whispering Woods. He searched high and low, asking the '
    'friendly fireflies and wise old owls for help. After a great adventure, '
    'Pip finally found his gear sparkling under a mushroom, guarded by a '
    'tiny sleeping snail. Pip thanked everyone and rolled home happily, '
    'his gears spinning bright!';

// ---------------------------------------------------------------------------
// TTS service provider (singleton)
// ---------------------------------------------------------------------------

/// Provides a single [TTSService] instance across the app.
final ttsServiceProvider = Provider<TTSService>((ref) {
  final service = TTSService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ---------------------------------------------------------------------------
// Story state notifier
// ---------------------------------------------------------------------------

/// Manages narration state transitions and TTS interaction.
class StoryNotifier extends StateNotifier<StoryState> {
  StoryNotifier(this._ttsService) : super(StoryState.idle);

  final TTSService _ttsService;

  /// Starts the narration flow.
  ///
  /// 1. Sets state to [StoryState.loading]
  /// 2. Initializes TTS if needed
  /// 3. Registers completion / error handlers
  /// 4. Speaks the story text
  /// 5. On completion → [StoryState.audioComplete] → [StoryState.quizVisible]
  Future<void> startNarration() async {
    if (state == StoryState.speaking || state == StoryState.loading) return;

    state = StoryState.loading;

    try {
      // Init TTS engine (idempotent if already initialized)
      if (!_ttsService.isInitialized) {
        await _ttsService.init();
      }

      // Wire up completion callback → trigger quiz reveal
      _ttsService.setCompletionHandler(() {
        if (mounted) {
          state = StoryState.audioComplete;
          // Small delay so the user sees the transition, then reveal quiz
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              state = StoryState.quizVisible;
            }
          });
        }
      });

      // Wire up error callback
      _ttsService.setErrorHandler((error) {
        if (mounted) {
          state = StoryState.error;
        }
      });

      // Start speaking
      state = StoryState.speaking;
      await _ttsService.speak(kStoryText);
    } catch (e) {
      if (mounted) {
        state = StoryState.error;
      }
    }
  }

  /// Transitions to success after correct quiz answer.
  void setSuccess() {
    state = StoryState.success;
  }

  /// Resets to idle for a retry.
  void reset() {
    _ttsService.stop();
    state = StoryState.idle;
  }

  /// Retries narration after an error.
  Future<void> retry() async {
    state = StoryState.idle;
    await startNarration();
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Top-level provider for the story narration state machine.
final storyProvider = StateNotifierProvider<StoryNotifier, StoryState>((ref) {
  final ttsService = ref.watch(ttsServiceProvider);
  return StoryNotifier(ttsService);
});
