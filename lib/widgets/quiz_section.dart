/// QuizSection — Dynamically rendered quiz from model data.
///
/// Renders the question and any number of options from [QuizModel].
/// Provides visual feedback for correct/incorrect answers with
/// shake animation on wrong picks and color changes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';
import '../providers/story_provider.dart';
import '../animations/shake_animation.dart';

/// Quiz section that slides in after narration completes.
///
/// Generates option buttons dynamically from [QuizModel.options],
/// so it works with any number of choices without code changes.
class QuizSection extends ConsumerWidget {
  const QuizSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final storyNotifier = ref.read(storyProvider.notifier);

    return ShakeAnimationWidget(
      shake: quizState.wrongAttempts,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00E5FF),
              Color(0xFF2979FF),
              Color(0xFF7C4DFF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2979FF).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              // ── Quiz header ──
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_rounded,
                    color: Color(0xFF2979FF),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '🧠  Quiz Time!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2979FF),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Question text ──
              Text(
                quizState.quiz.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF37474F),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // ── Dynamically generated option buttons ──
              ...quizState.quiz.options.map(
                (option) => _OptionButton(
                  option: option,
                  quizState: quizState,
                  onTap: () {
                    ref.read(quizProvider.notifier).selectAnswer(option);

                    // If correct → update story state to success
                    if (quizState.quiz.isCorrect(option)) {
                      storyNotifier.setSuccess();
                    } else {
                      // Clear after a brief moment so user can try again
                      Future.delayed(const Duration(milliseconds: 1200), () {
                        ref.read(quizProvider.notifier).clearSelection();
                      });
                    }
                  },
                ),
              ),

              // ── Wrong answer hint ──
              if (quizState.hasAnswered && !quizState.isCorrect)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Oops! Try again 💪',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private option button
// ---------------------------------------------------------------------------

/// A single quiz option rendered as a tappable card.
///
/// Shows colored feedback when selected:
/// - Green border + check icon for correct
/// - Red border + cross icon for incorrect
class _OptionButton extends StatelessWidget {
  final String option;
  final QuizState quizState;
  final VoidCallback onTap;

  const _OptionButton({
    required this.option,
    required this.quizState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = quizState.selectedAnswer == option;
    final isCorrectOption = quizState.quiz.isCorrect(option);
    final showResult = quizState.hasAnswered && isSelected;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: quizState.hasAnswered && quizState.isCorrect ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: showResult
                  ? (isCorrectOption
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE))
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: showResult
                    ? (isCorrectOption
                        ? const Color(0xFF66BB6A)
                        : const Color(0xFFEF5350))
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                if (showResult)
                  BoxShadow(
                    color: (isCorrectOption
                            ? const Color(0xFF66BB6A)
                            : const Color(0xFFEF5350))
                        .withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Option letter badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: showResult
                        ? (isCorrectOption
                            ? const Color(0xFF66BB6A)
                            : const Color(0xFFEF5350))
                        : const Color(0xFFE0E0E0),
                  ),
                  child: Center(
                    child: showResult
                        ? Icon(
                            isCorrectOption ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 18,
                          )
                        : Text(
                            String.fromCharCode(65 +
                                quizState.quiz.options.indexOf(option)),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF757575),
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                // Option text
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          showResult ? FontWeight.w700 : FontWeight.w500,
                      color: showResult
                          ? (isCorrectOption
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828))
                          : const Color(0xFF424242),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
