/// SuccessCard — Celebration card shown after correct quiz answer.
///
/// Features a gradient background, trophy icon, encouraging message,
/// and a "Play Again" button to restart the experience.
library;

import 'package:flutter/material.dart';

/// A cheerful success card displayed when the quiz is answered correctly.
///
/// Designed with vibrant green gradients, bold typography, and a
/// restart button to encourage repeated engagement.
class SuccessCard extends StatelessWidget {
  /// Called when the user taps "Play Again".
  final VoidCallback onPlayAgain;

  const SuccessCard({super.key, required this.onPlayAgain});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00E676),
            Color(0xFF69F0AE),
            Color(0xFF00C853),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            // ── Trophy icon ──
            const Text('🏆', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),

            // ── Congratulations text ──
            const Text(
              'Amazing Job!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2E7D32),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You helped Pip find his blue gear! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '⭐ ⭐ ⭐',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 20),

            // ── Play Again button ──
            GestureDetector(
              onTap: onPlayAgain,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF651FFF)],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.replay_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Play Again!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
