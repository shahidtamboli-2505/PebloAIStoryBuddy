/// StoryScreen — The main (and only) screen of Peblo AI Story Buddy.
///
/// Composes all widgets into a single scrollable view:
/// BuddyAvatar → StoryCard → ReadStoryButton → QuizSection/SuccessCard
///
/// Manages confetti animation overlay and quiz slide-in animation.
library;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/story_data.dart';
import '../providers/story_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/buddy_avatar.dart';
import '../widgets/story_card.dart';
import '../widgets/read_story_button.dart';
import '../widgets/quiz_section.dart';
import '../widgets/success_card.dart';

/// The primary screen of the app — a single-page experience.
class StoryScreen extends ConsumerStatefulWidget {
  final StoryData storyData;

  const StoryScreen({super.key, required this.storyData});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen>
    with TickerProviderStateMixin {
  late final ConfettiController _confettiController;
  late final AnimationController _quizSlideController;
  late final Animation<Offset> _quizSlideAnimation;
  late final Animation<double> _quizFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Set the quiz data into the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider.notifier).setQuiz(widget.storyData.quiz);
    });

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _quizSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _quizSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _quizSlideController,
      curve: Curves.easeOutBack,
    ));
    _quizFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _quizSlideController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _quizSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyProvider);
    final quizState = ref.watch(quizProvider);

    // React to state transitions
    ref.listen<StoryState>(storyProvider, (previous, next) {
      if (next == StoryState.quizVisible) {
        _quizSlideController.forward(from: 0);
      }
      if (next == StoryState.success) {
        _confettiController.play();
      }
      if (next == StoryState.idle) {
        _quizSlideController.reset();
        _confettiController.stop();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black54),
          onPressed: () {
            ref.read(storyProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          _Background(storyState: storyState),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _AppTitle(storyState: storyState, title: widget.storyData.title),
                  const SizedBox(height: 20),
                  BuddyAvatar(storyState: storyState),
                  const SizedBox(height: 8),
                  _SpeechBubble(storyState: storyState),
                  const SizedBox(height: 24),
                  StoryCard(
                    storyText: widget.storyData.text,
                    storyState: storyState,
                  ),
                  const SizedBox(height: 24),
                  if (storyState != StoryState.quizVisible &&
                      storyState != StoryState.success)
                    ReadStoryButton(
                      storyState: storyState,
                      onPressed: () {
                        if (storyState == StoryState.error) {
                          ref.read(storyProvider.notifier).retry(widget.storyData.text);
                        } else {
                          ref.read(storyProvider.notifier).startNarration(widget.storyData.text);
                        }
                      },
                    ),
                  if (storyState == StoryState.quizVisible && quizState != null)
                    SlideTransition(
                      position: _quizSlideAnimation,
                      child: FadeTransition(
                        opacity: _quizFadeAnimation,
                        child: const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: QuizSection(),
                        ),
                      ),
                    ),
                  if (storyState == StoryState.success)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SuccessCard(
                        onPlayAgain: () {
                          ref.read(storyProvider.notifier).reset();
                          ref.read(quizProvider.notifier).reset();
                        },
                      ),
                    ),
                  if (storyState == StoryState.error)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          const Text(
                            '😢 Oops! Something went wrong.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEF5350),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The story reader had a hiccup.\nTap the button to try again!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 25,
              maxBlastForce: 30,
              minBlastForce: 10,
              gravity: 0.2,
              colors: const [
                Color(0xFF7C4DFF),
                Color(0xFFFF9100),
                Color(0xFF00E676),
                Color(0xFF2979FF),
                Color(0xFFFF6B6B),
                Color(0xFFFFD740),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helper widgets
// ---------------------------------------------------------------------------

class _Background extends StatelessWidget {
  final StoryState storyState;
  const _Background({required this.storyState});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _gradientColors,
        ),
      ),
    );
  }

  List<Color> get _gradientColors {
    switch (storyState) {
      case StoryState.speaking:
        return [
          const Color(0xFFFFF8E1),
          const Color(0xFFFFE0B2),
          const Color(0xFFFFF3E0),
        ];
      case StoryState.success:
        return [
          const Color(0xFFE8F5E9),
          const Color(0xFFC8E6C9),
          const Color(0xFFE8F5E9),
        ];
      case StoryState.error:
        return [
          const Color(0xFFFCE4EC),
          const Color(0xFFFFCDD2),
          const Color(0xFFFCE4EC),
        ];
      default:
        return [
          const Color(0xFFEDE7F6),
          const Color(0xFFE8EAF6),
          const Color(0xFFF3E5F5),
        ];
    }
  }
}

class _AppTitle extends StatelessWidget {
  final StoryState storyState;
  final String title;
  const _AppTitle({required this.storyState, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
            ).createShader(bounds),
            child: const Text(
              '✨ Peblo AI ✨',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final StoryState storyState;
  const _SpeechBubble({required this.storyState});

  String get _text {
    switch (storyState) {
      case StoryState.idle:
        return 'Hi there! Ready for a story? 🌟';
      case StoryState.loading:
        return 'Let me warm up my voice... 🎤';
      case StoryState.speaking:
        return 'Listen closely! 🎧';
      case StoryState.audioComplete:
        return 'Story done! Quiz time... 🧠';
      case StoryState.quizVisible:
        return 'Can you answer this? 🤔';
      case StoryState.success:
        return 'You\'re a genius! 🎉';
      case StoryState.error:
        return 'Oh no, let\'s try again! 😅';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(storyState),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          _text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546E7A),
          ),
        ),
      ),
    );
  }
}
