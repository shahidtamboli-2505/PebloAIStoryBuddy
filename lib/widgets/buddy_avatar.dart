/// BuddyAvatar — Cute AI robot buddy illustration.
///
/// Built entirely with Flutter widgets (no external assets needed).
/// Changes expression based on the current story state to provide
/// visual feedback to the child.
library;

import 'package:flutter/material.dart';
import '../providers/story_provider.dart';

/// A cute robot buddy avatar that reacts to the narration state.
///
/// Uses layered containers and gradients to create a friendly
/// robot face with antenna, eyes, and a mouth that changes
/// expression based on [storyState].
class BuddyAvatar extends StatefulWidget {
  /// Current state of the story flow.
  final StoryState storyState;

  const BuddyAvatar({super.key, required this.storyState});

  @override
  State<BuddyAvatar> createState() => _BuddyAvatarState();
}

class _BuddyAvatarState extends State<BuddyAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSpeaking = widget.storyState == StoryState.speaking;
    final isSuccess = widget.storyState == StoryState.success;
    final isError = widget.storyState == StoryState.error;
    final isLoading = widget.storyState == StoryState.loading;

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: child,
        );
      },
      child: SizedBox(
        width: 140,
        height: 170,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Antenna ──
            Positioned(
              top: 0,
              child: Column(
                children: [
                  // Antenna ball
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSuccess
                          ? const Color(0xFF00E676)
                          : isSpeaking
                              ? const Color(0xFFFFD740)
                              : isError
                                  ? const Color(0xFFFF5252)
                                  : const Color(0xFF7C4DFF),
                      boxShadow: [
                        BoxShadow(
                          color: (isSuccess
                                  ? const Color(0xFF00E676)
                                  : isSpeaking
                                      ? const Color(0xFFFFD740)
                                      : const Color(0xFF7C4DFF))
                              .withValues(alpha: 0.6),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Antenna stem
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),

            // ── Robot Head ──
            Positioned(
              top: 30,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSuccess
                        ? [const Color(0xFF69F0AE), const Color(0xFF00E676)]
                        : isError
                            ? [const Color(0xFFFF8A80), const Color(0xFFFF5252)]
                            : [const Color(0xFF9575FF), const Color(0xFF7C4DFF)],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // ── Eyes ──
                    Positioned(
                      top: 28,
                      left: 22,
                      child: _Eye(
                        isSpeaking: isSpeaking,
                        isSuccess: isSuccess,
                        isLoading: isLoading,
                      ),
                    ),
                    Positioned(
                      top: 28,
                      right: 22,
                      child: _Eye(
                        isSpeaking: isSpeaking,
                        isSuccess: isSuccess,
                        isLoading: isLoading,
                      ),
                    ),

                    // ── Cheeks ──
                    Positioned(
                      top: 52,
                      left: 10,
                      child: Container(
                        width: 18,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 52,
                      right: 10,
                      child: Container(
                        width: 18,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // ── Mouth ──
                    Positioned(
                      bottom: 22,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _Mouth(
                          isSpeaking: isSpeaking,
                          isSuccess: isSuccess,
                          isError: isError,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Ears ──
            Positioned(
              top: 60,
              left: 0,
              child: Container(
                width: 12,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6A3DE8),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            Positioned(
              top: 60,
              right: 0,
              child: Container(
                width: 12,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6A3DE8),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

/// A single eye that blinks when speaking and turns into a happy arc on success.
class _Eye extends StatelessWidget {
  final bool isSpeaking;
  final bool isSuccess;
  final bool isLoading;

  const _Eye({
    required this.isSpeaking,
    required this.isSuccess,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isSuccess) {
      // Happy squinted eyes ^^
      return SizedBox(
        width: 26,
        height: 26,
        child: CustomPaint(painter: _HappyEyePainter()),
      );
    }

    if (isLoading) {
      // Loading dots
      return const SizedBox(
        width: 26,
        height: 26,
        child: Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 26,
      height: isSpeaking ? 20 : 26,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSpeaking ? 10 : 13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 12,
          height: isSpeaking ? 8 : 12,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for happy ^^ eyes.
class _HappyEyePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.1,
        size.width * 0.85,
        size.height * 0.55,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mouth widget that changes shape based on the buddy's state.
class _Mouth extends StatelessWidget {
  final bool isSpeaking;
  final bool isSuccess;
  final bool isError;

  const _Mouth({
    required this.isSpeaking,
    required this.isSuccess,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    if (isSpeaking) {
      // Animated speaking mouth (open circle)
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 22,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
        ),
      );
    }

    if (isError) {
      // Sad mouth
      return SizedBox(
        width: 36,
        height: 16,
        child: CustomPaint(painter: _SadMouthPainter()),
      );
    }

    // Happy smile (default & success)
    return SizedBox(
      width: isSuccess ? 44 : 36,
      height: 16,
      child: CustomPaint(painter: _SmilePainter(isWide: isSuccess)),
    );
  }
}

/// Draws a curved smile.
class _SmilePainter extends CustomPainter {
  final bool isWide;
  const _SmilePainter({this.isWide = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * (isWide ? 1.4 : 1.1),
        size.width * 0.9,
        size.height * 0.2,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SmilePainter oldDelegate) =>
      isWide != oldDelegate.isWide;
}

/// Draws an inverted curve for a sad face.
class _SadMouthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * -0.3,
        size.width * 0.85,
        size.height * 0.8,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
