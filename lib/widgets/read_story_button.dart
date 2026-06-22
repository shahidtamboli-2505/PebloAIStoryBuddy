/// ReadStoryButton — The primary CTA for starting narration.
///
/// Features a gradient background, subtle glow, press animation,
/// and state-aware label changes.
library;

import 'package:flutter/material.dart';
import '../providers/story_provider.dart';

/// A large, child-friendly button that starts the story narration.
///
/// Automatically disables itself during [StoryState.speaking] and
/// [StoryState.loading] to prevent duplicate taps.
/// Shows different labels and icons based on the current state.
class ReadStoryButton extends StatefulWidget {
  /// Called when the button is tapped (only fires in actionable states).
  final VoidCallback onPressed;

  /// Current narration state.
  final StoryState storyState;

  const ReadStoryButton({
    super.key,
    required this.onPressed,
    required this.storyState,
  });

  @override
  State<ReadStoryButton> createState() => _ReadStoryButtonState();
}

class _ReadStoryButtonState extends State<ReadStoryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isDisabled =>
      widget.storyState == StoryState.speaking ||
      widget.storyState == StoryState.loading;

  String get _buttonLabel {
    switch (widget.storyState) {
      case StoryState.loading:
        return 'Preparing...';
      case StoryState.speaking:
        return 'Listening... 🎧';
      case StoryState.error:
        return 'Try Again 🔄';
      case StoryState.audioComplete:
      case StoryState.quizVisible:
      case StoryState.success:
        return 'Story Complete ✨';
      case StoryState.idle:
        return 'Read Me a Story! 📖';
    }
  }

  IconData get _buttonIcon {
    switch (widget.storyState) {
      case StoryState.loading:
        return Icons.hourglass_top_rounded;
      case StoryState.speaking:
        return Icons.volume_up_rounded;
      case StoryState.error:
        return Icons.refresh_rounded;
      default:
        return Icons.play_circle_filled_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showPulse = widget.storyState == StoryState.idle;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: showPulse ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isDisabled ? 0.7 : 1.0,
        child: GestureDetector(
          onTap: _isDisabled ? null : widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isDisabled
                    ? [Colors.grey.shade400, Colors.grey.shade500]
                    : widget.storyState == StoryState.error
                        ? [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)]
                        : [const Color(0xFFFF9100), const Color(0xFFFF6D00)],
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                if (!_isDisabled)
                  BoxShadow(
                    color: (widget.storyState == StoryState.error
                            ? const Color(0xFFFF6B6B)
                            : const Color(0xFFFF9100))
                        .withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.storyState == StoryState.loading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(_buttonIcon, color: Colors.white, size: 26),
                const SizedBox(width: 12),
                Text(
                  _buttonLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8,
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
