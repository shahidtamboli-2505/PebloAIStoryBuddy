/// StoryCard — Displays the story text in a decorative card.
///
/// Features a gradient border, book icon, and smooth fade-in animation.
/// Uses const constructors where possible for performance.
library;

import 'package:flutter/material.dart';
import '../providers/story_provider.dart';

/// A beautifully styled card that presents the story text.
///
/// Animates opacity based on the current [storyState] to draw
/// attention when the story is being narrated.
class StoryCard extends StatelessWidget {
  /// The story text to display.
  final String storyText;

  /// Current narration state (used for visual feedback).
  final StoryState storyState;

  const StoryCard({
    super.key,
    required this.storyText,
    required this.storyState,
  });

  @override
  Widget build(BuildContext context) {
    final isSpeaking = storyState == StoryState.speaking;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSpeaking
              ? [
                  const Color(0xFFFFD740),
                  const Color(0xFFFF9100),
                  const Color(0xFFFF6D00),
                ]
              : [
                  const Color(0xFF9575FF),
                  const Color(0xFF7C4DFF),
                  const Color(0xFF651FFF),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isSpeaking
                    ? const Color(0xFFFF9100)
                    : const Color(0xFF7C4DFF))
                .withValues(alpha: 0.35),
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
            // ── Header row ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  color: isSpeaking
                      ? const Color(0xFFFF9100)
                      : const Color(0xFF7C4DFF),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isSpeaking ? '📖  Narrating...' : '📖  Pip\'s Story',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSpeaking
                        ? const Color(0xFFFF9100)
                        : const Color(0xFF7C4DFF),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Story text ──
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 400),
              style: TextStyle(
                fontSize: 17,
                height: 1.65,
                color: isSpeaking
                    ? const Color(0xFF37474F)
                    : const Color(0xFF546E7A),
                fontWeight:
                    isSpeaking ? FontWeight.w500 : FontWeight.w400,
              ),
              child: Text(
                storyText,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
