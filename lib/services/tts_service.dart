/// TTSService — Text-to-Speech service wrapper.
///
/// Encapsulates the flutter_tts package with proper initialization,
/// error handling, and lifecycle management.
library;

import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

/// Wrapper around [FlutterTts] providing a clean API for narration.
///
/// Handles initialization, speech rate tuning for child-friendly pace,
/// completion callbacks, and error handling.
class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// Initializes the TTS engine with child-friendly settings.
  ///
  /// Sets a slower speech rate and slightly higher pitch for
  /// a friendly storytelling voice. Must be called before [speak].
  Future<void> init() async {
    try {
      await _flutterTts.setLanguage('en-US');
      // Slower rate for kids to follow along easily
      await _flutterTts.setSpeechRate(0.42);
      await _flutterTts.setVolume(1.0);
      // Slightly higher pitch for a friendly, warm tone
      await _flutterTts.setPitch(1.15);
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  /// Speaks the given [text] aloud.
  ///
  /// Throws if the TTS engine has not been initialized.
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      throw StateError('TTSService not initialized. Call init() first.');
    }
    await _flutterTts.speak(text);
  }

  /// Stops any ongoing speech.
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Registers a callback invoked when narration finishes.
  void setCompletionHandler(void Function() onComplete) {
    _flutterTts.setCompletionHandler(onComplete);
  }

  /// Registers a callback invoked when narration starts.
  void setStartHandler(void Function() onStart) {
    _flutterTts.setStartHandler(onStart);
  }

  /// Registers a callback invoked on TTS errors.
  void setErrorHandler(void Function(dynamic) onError) {
    _flutterTts.setErrorHandler((msg) {
      onError(msg);
    });
  }

  /// Whether the TTS engine has been successfully initialized.
  bool get isInitialized => _isInitialized;

  /// Releases TTS resources.
  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
