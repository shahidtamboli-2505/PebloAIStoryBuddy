# Peblo AI Story Buddy

## Project Overview

Peblo AI Story Buddy is a kid-friendly mobile app built with Flutter that reads stories aloud and quizzes children on what they heard. The main character is Pip, a cute little robot buddy who guides kids through the experience.

This was built as part of my internship assessment. The idea was to show that I can build a polished, working Flutter app with proper architecture — not just a basic prototype.

The app has one screen but a lot going on under the hood: text-to-speech narration, state machine logic, dynamic quiz rendering, animations, and proper error handling.

## Why I Chose Flutter and Riverpod

Flutter was the obvious choice since the assessment required it, but I genuinely enjoy working with it. The widget composition model makes it easy to build custom UI without fighting the framework.

For state management, I went with **Riverpod** over Provider or BLoC because:
- It doesn't need BuildContext to read state, which made the TTS callback integration much cleaner
- StateNotifier gives a clear, predictable way to manage state transitions
- The `ref.listen` pattern is perfect for triggering side effects (like playing confetti) without rebuilding the UI unnecessarily
- It's the direction the Flutter community is heading and I wanted to get comfortable with it

I considered BLoC but felt it was overkill for a single-screen app. Riverpod gave me the right balance of structure and simplicity.

## Features Implemented

- **Kid-friendly UI** — Bright gradients, rounded corners, large touch targets, and a custom-drawn robot buddy avatar
- **AI Buddy (Pip)** — A robot character drawn entirely with Flutter widgets and CustomPainter. Changes expressions based on what's happening (happy eyes on success, sad mouth on error, loading spinners, etc.)
- **Story Narration** — Uses flutter_tts to read the story aloud with a child-friendly speech rate and pitch
- **Dynamic Quiz Rendering** — Quiz is generated from a JSON model, not hardcoded UI. Supports any number of options
- **Wrong Answer Feedback** — Shake animation + red highlight + encouraging "try again" message
- **Success Animation** — Confetti explosion + green success card + happy buddy state + stars
- **Error Handling** — Graceful error states with retry button and friendly error messages
- **Loading States** — Smooth transitions between idle, loading, speaking, and quiz states
- **Speech Bubble** — Animated speech bubble above the buddy that changes text based on current state

## State Management Approach

I used a state enum with Riverpod's `StateNotifier` to manage the narration lifecycle:

```dart
enum StoryState {
  idle,        // Nothing happening yet
  loading,     // TTS engine initializing
  speaking,    // Story being narrated
  audioComplete, // Narration just finished
  quizVisible, // Quiz sliding in
  success,     // Correct answer!
  error,       // Something broke
}
```

The `StoryNotifier` handles all transitions and the UI just reacts to the current state. This made it really easy to reason about what the app should look like at any point.

The quiz has its own separate `QuizNotifier` that tracks the selected answer, correctness, and wrong attempt count (which drives the shake animation).

## Audio Lifecycle Flow

```
Button Press
  → StoryState.loading (TTS init)
    → StoryState.speaking (narration playing)
      → StoryState.audioComplete (narration finished)
        → StoryState.quizVisible (quiz slides in after 600ms delay)
          → StoryState.success (correct answer + confetti!)
```

If anything goes wrong at any step, it falls to `StoryState.error` with a retry option.

## Data-Driven Quiz Architecture

The quiz is **not hardcoded** into the UI. Here's how it works:

1. Quiz data lives as a JSON map (simulating an API response):
```json
{
  "question": "What colour was Pip the Robot's lost gear?",
  "options": ["Red", "Green", "Blue", "Yellow"],
  "answer": "Blue"
}
```

2. `QuizModel.fromJson()` parses it into a strongly-typed Dart object

3. The `QuizSection` widget renders options dynamically using `.map()` on `quiz.options`

4. Option badges (A, B, C, D...) are generated using `String.fromCharCode(65 + index)`

This means if I change the JSON to have 2 options or 8 options, the UI adapts automatically without touching any widget code. In a production version, this JSON would come from a backend API.

## Error Handling Strategy

Errors are handled at multiple levels:

- **TTS Initialization** — Wrapped in try/catch, falls to error state if the engine fails
- **Speech Errors** — flutter_tts error callback is wired to set error state
- **State Guard** — The `startNarration()` method checks if already speaking/loading before proceeding (prevents duplicate calls)
- **Mounted Checks** — All async callbacks check `mounted` before setting state to avoid disposed-notifier errors
- **User Recovery** — Error state shows a friendly message and the button changes to "Try Again 🔄"

## Performance Optimizations

- **const widgets** — Used `const` constructors wherever possible to skip unnecessary rebuilds. The linter is configured to enforce this
- **Minimized rebuilds** — Riverpod's granular watching means only widgets that depend on changed state rebuild. `ref.listen` handles side effects without rebuilds
- **AnimatedBuilder with child** — All animations use the `child` parameter to avoid rebuilding the child widget tree on every frame
- **Lightweight assets** — The buddy avatar is drawn with widgets/CustomPainter instead of heavy image assets. Zero asset files needed
- **Smooth animations** — Targeted 60fps with simple Transform-based animations (translate, scale) that hit the GPU compositor
- **Mid-range Android optimization** — Portrait-only lock reduces layout recalculations. Confetti particle count is capped at 25. No heavy shadows on animated elements

## Caching Strategy

Currently the app uses flutter_tts which synthesizes speech on-device, so there's no network caching needed.

For a future version with remote audio (like pre-recorded narrations or AI-generated voices):
- Audio files could be cached locally using `path_provider` to get the app's cache directory
- A simple cache-first strategy: check local cache → if not found, download from CDN → save to cache → play
- Cache could be managed with LRU eviction to keep storage usage reasonable
- `flutter_cache_manager` package would handle most of this out of the box

## AI Assistance Disclosure

I used AI tools such as Claude and ChatGPT during development to speed up implementation, understand package usage, explore Riverpod patterns, and review architecture ideas.

I reviewed all generated code, tested the application manually, integrated components, fixed issues, and made implementation decisions myself.

**One AI suggestion I changed:**
Initially the generated solution kept quiz data directly inside UI widgets. I refactored it into a separate model-based approach so the renderer remains reusable and scalable. The `QuizModel` class with `fromJson()` factory constructor was my decision — the original suggestion just had inline maps inside the widget.

**One issue I faced:**
I initially had trouble triggering the quiz exactly after narration completion. After debugging flutter_tts completion callbacks and state transitions, I connected narration completion to Riverpod state updates, which resolved the issue. The key insight was that flutter_tts's `setCompletionHandler` fires on a platform thread, so I needed to make sure the state update was happening correctly through the StateNotifier rather than trying to update UI directly.

## Future Improvements

- **Multiple stories** — Story selector screen with different themes and characters
- **Backend APIs** — Fetch stories and quizzes from a REST API instead of local JSON
- **Multiple quiz levels** — Easy/medium/hard questions for each story, progress tracking
- **AI-generated stories** — Integrate with GPT API to generate unique stories on demand
- **Voice customization** — Let kids pick the narration voice (speed, pitch, different voices)
- **Offline support** — Cache stories and audio for use without internet
- **Accessibility** — Screen reader support, high contrast mode, dyslexia-friendly fonts
- **Analytics** — Track which stories kids enjoy most and quiz accuracy rates

## Folder Structure Explanation

```
lib/
├── main.dart              # App entry point, theme config, ProviderScope
├── models/
│   └── quiz_model.dart    # QuizModel — JSON-parseable quiz data class
├── providers/
│   ├── story_provider.dart # StoryNotifier — narration state machine
│   └── quiz_provider.dart  # QuizNotifier — quiz interaction state
├── services/
│   └── tts_service.dart   # TTSService — flutter_tts wrapper with error handling
├── screens/
│   └── story_screen.dart  # Main screen — composes all widgets, confetti overlay
├── widgets/
│   ├── buddy_avatar.dart  # Pip the robot — custom-drawn with state reactions
│   ├── story_card.dart    # Story text card with gradient border
│   ├── read_story_button.dart # CTA button with pulse animation
│   ├── quiz_section.dart  # Dynamic quiz renderer from QuizModel
│   └── success_card.dart  # Celebration card with play-again option
└── animations/
    └── shake_animation.dart # Reusable shake animation for wrong answers
```

**Why this structure:**
- `models/` keeps data separate from UI logic
- `providers/` centralizes state management in one place
- `services/` wraps external packages so they can be swapped or mocked
- `widgets/` are reusable, focused components
- `animations/` separates animation logic from business logic
- `screens/` composes everything together

## How To Run

1. Make sure you have Flutter SDK installed (3.x or later):
```bash
flutter --version
```

2. Clone or download this project

3. Get dependencies:
```bash
cd peblo_ai_story_buddy
flutter pub get
```

4. Connect a device or start an emulator

5. Run the app:
```bash
flutter run
```

**Note:** Text-to-speech requires a real device or an emulator with TTS support. On some emulators, you might need to install Google TTS from the Play Store.

If the font doesn't load (BubblegumSans), the app will fall back to the system default font — everything still works fine.

---

Built with Flutter 💙 by a final-year AI & Data Science student who probably spent too much time getting the robot's eyes just right.
