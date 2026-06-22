import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/story_data.dart';
import '../providers/story_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/quiz_section.dart';
import '../widgets/success_card.dart';

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

    ref.listen<StoryState>(storyProvider, (previous, next) {
      if (next == StoryState.quizVisible) {
        _quizSlideController.forward(from: 0);
      }
      if (next == StoryState.success) {
        _confettiController.play();
      }
      if (next == StoryState.initial) {
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
            ref.read(storyProvider.notifier).stopNarration();
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
                  _AppTitle(title: widget.storyData.title),
                  const SizedBox(height: 20),
                  _BuddyAvatar(storyState: storyState),
                  const SizedBox(height: 8),
                  _SpeechBubble(storyState: storyState),
                  const SizedBox(height: 24),
                  
                  // Story Text Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.storyData.text,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF37474F),
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // Read Button / Loading State
                  if (storyState == StoryState.initial || storyState == StoryState.ttsError)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C4DFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 8,
                          shadowColor: const Color(0xFF7C4DFF).withValues(alpha: 0.5),
                        ),
                        icon: const Icon(Icons.volume_up_rounded, size: 28),
                        label: Text(
                          storyState == StoryState.ttsError ? 'Try Reading Again' : 'Read Me a Story!',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          ref.read(storyProvider.notifier).playNarration(widget.storyData.text);
                        },
                      ),
                    ),

                  if (storyState == StoryState.loadingTts)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                    ),
                  
                  if (storyState == StoryState.playingTts)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF7C4DFF),
                          side: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        icon: const Icon(Icons.stop_circle_rounded, size: 28),
                        label: const Text('Stop Reading', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          ref.read(storyProvider.notifier).stopNarration();
                        },
                      ),
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
                          ref.read(storyProvider.notifier).stopNarration();
                          Navigator.of(context).pop();
                        },
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
              numberOfParticles: 35,
              maxBlastForce: 40,
              minBlastForce: 20,
              gravity: 0.15,
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
      case StoryState.playingTts:
        return [const Color(0xFFFFF8E1), const Color(0xFFFFE0B2), const Color(0xFFFFF3E0)];
      case StoryState.success:
        return [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9), const Color(0xFFE8F5E9)];
      case StoryState.ttsError:
        return [const Color(0xFFFCE4EC), const Color(0xFFFFCDD2), const Color(0xFFFCE4EC)];
      default:
        return [const Color(0xFFEDE7F6), const Color(0xFFE8EAF6), const Color(0xFFF3E5F5)];
    }
  }
}

class _AppTitle extends StatelessWidget {
  final String title;
  const _AppTitle({required this.title});

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
              '✨ Peblo Story ✨',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BuddyAvatar extends StatelessWidget {
  final StoryState storyState;

  const _BuddyAvatar({required this.storyState});

  @override
  Widget build(BuildContext context) {
    String emoji = '🤖';
    if (storyState == StoryState.success) emoji = '🤩';
    if (storyState == StoryState.ttsError) emoji = '😵';
    if (storyState == StoryState.playingTts) emoji = '🗣️';

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
        child: Text(
          emoji,
          key: ValueKey(emoji),
          style: const TextStyle(fontSize: 50),
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final StoryState storyState;
  const _SpeechBubble({required this.storyState});

  String get _text {
    switch (storyState) {
      case StoryState.initial: return 'Hi! Ready for a story? 🌟';
      case StoryState.loadingTts: return 'Warming up my voice... 🎤';
      case StoryState.playingTts: return 'Listen closely! 🎧';
      case StoryState.ttsCompleted: return 'Story done! Loading quiz...';
      case StoryState.quizVisible: return 'Can you answer this? 🤔';
      case StoryState.success: return 'You\'re a genius! 🎉';
      case StoryState.ttsError: return 'Oops, my voice box broke! 😅';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(storyState),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          _text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546E7A),
          ),
        ),
      ),
    );
  }
}
