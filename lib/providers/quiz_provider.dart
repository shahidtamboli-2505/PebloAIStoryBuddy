/// QuizProvider — Riverpod state management for the quiz section.
///
/// Loads quiz data from JSON, tracks user selections, and provides
/// feedback for correct / incorrect answers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_model.dart';

// ---------------------------------------------------------------------------
// Quiz JSON data (could come from an API in production)
// ---------------------------------------------------------------------------

/// Raw quiz data — in a real app this would be fetched from a backend.
const Map<String, dynamic> kQuizJson = {
  'question': "What colour was Pip the Robot's lost gear?",
  'options': ['Red', 'Green', 'Blue', 'Yellow'],
  'answer': 'Blue',
};

// ---------------------------------------------------------------------------
// Quiz state
// ---------------------------------------------------------------------------

/// Immutable state object for the quiz section.
class QuizState {
  /// The parsed quiz model.
  final QuizModel quiz;

  /// The option the user tapped (null if nothing selected yet).
  final String? selectedAnswer;

  /// Whether the selected answer is correct.
  final bool isCorrect;

  /// Whether the user has submitted an answer.
  final bool hasAnswered;

  /// Number of wrong attempts (drives shake animation).
  final int wrongAttempts;

  const QuizState({
    required this.quiz,
    this.selectedAnswer,
    this.isCorrect = false,
    this.hasAnswered = false,
    this.wrongAttempts = 0,
  });

  /// Creates a modified copy of this state.
  QuizState copyWith({
    QuizModel? quiz,
    String? selectedAnswer,
    bool? isCorrect,
    bool? hasAnswered,
    int? wrongAttempts,
  }) {
    return QuizState(
      quiz: quiz ?? this.quiz,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      hasAnswered: hasAnswered ?? this.hasAnswered,
      wrongAttempts: wrongAttempts ?? this.wrongAttempts,
    );
  }
}

// ---------------------------------------------------------------------------
// Quiz notifier
// ---------------------------------------------------------------------------

/// Manages quiz interactions: answer selection, validation, and reset.
class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier()
      : super(
          QuizState(quiz: QuizModel.fromJson(kQuizJson)),
        );

  /// Called when the user taps an option.
  ///
  /// Sets [hasAnswered] and [isCorrect] accordingly.
  /// Increments [wrongAttempts] on incorrect answers to drive animations.
  void selectAnswer(String answer) {
    final correct = state.quiz.isCorrect(answer);
    state = state.copyWith(
      selectedAnswer: answer,
      isCorrect: correct,
      hasAnswered: true,
      wrongAttempts: correct ? state.wrongAttempts : state.wrongAttempts + 1,
    );
  }

  /// Clears the current selection so the user can try again.
  void clearSelection() {
    state = QuizState(
      quiz: state.quiz,
      wrongAttempts: state.wrongAttempts,
    );
  }

  /// Resets the entire quiz to its initial state.
  void reset() {
    state = QuizState(quiz: QuizModel.fromJson(kQuizJson));
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Top-level provider for quiz state.
final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier();
});
