import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../animations/shake_animation.dart';
import '../providers/quiz_provider.dart';
import '../providers/story_provider.dart';

/// The interactive quiz widget that appears after the story.
class QuizSection extends ConsumerWidget {
  const QuizSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);

    // If quiz state is null (not loaded yet), show a loader or empty container
    if (quizState == null) {
      return const SizedBox.shrink();
    }

    return ShakeAnimationWidget(
      shake: quizState.wrongAttempts,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stars_rounded, color: Color(0xFFFFB300), size: 28),
                SizedBox(width: 8),
                Text(
                  'Quiz Time!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4527A0),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              quizState.quiz.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF37474F),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                ...quizState.quiz.options.map(
                  (option) => _QuizOption(
                    option: option,
                    quizState: quizState,
                    onTap: () {
                      if (!quizState.hasAnswered) {
                        ref.read(quizProvider.notifier).selectAnswer(option);

                        if (quizState.quiz.isCorrect(option)) {
                          Future.delayed(const Duration(milliseconds: 800), () {
                            ref.read(storyProvider.notifier).setSuccess();
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            if (quizState.hasAnswered && !quizState.isCorrect)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(quizProvider.notifier).clearSelection();
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF7C4DFF)),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      color: Color(0xFF7C4DFF),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuizOption extends StatelessWidget {
  final String option;
  final QuizState quizState;
  final VoidCallback onTap;

  const _QuizOption({
    required this.option,
    required this.quizState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = quizState.selectedAnswer == option;
    final isCorrect = quizState.quiz.isCorrect(option);
    
    // Determine colors based on state
    Color borderColor = Colors.grey.shade300;
    Color backgroundColor = Colors.white;
    Color textColor = Colors.grey.shade700;
    IconData? icon;
    Color? iconColor;

    if (quizState.hasAnswered && isSelected) {
      if (isCorrect) {
        borderColor = const Color(0xFF69F0AE);
        backgroundColor = const Color(0xFFF1F8E9);
        textColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle_rounded;
        iconColor = const Color(0xFF00C853);
      } else {
        borderColor = const Color(0xFFFF5252);
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        icon = Icons.cancel_rounded;
        iconColor = const Color(0xFFD50000);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
