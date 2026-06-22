/// Peblo AI Story Buddy & Quiz — Application entry point.
///
/// Wraps the app in [ProviderScope] for Riverpod state management
/// and configures the Material theme with a kid-friendly color scheme.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/story_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for consistent kid-friendly layout
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    // ProviderScope is the root for all Riverpod providers
    const ProviderScope(
      child: PebloApp(),
    ),
  );
}

/// Root application widget.
///
/// Uses a custom Material 3 theme with a vibrant purple primary palette
/// optimized for child-friendly aesthetics.
class PebloApp extends StatelessWidget {
  const PebloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peblo AI Story Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.light,
        ),
        // Uses system font by default. Uncomment fontFamily below if
        // BubblegumSans is added to assets/fonts/
        // fontFamily: 'BubblegumSans',
        scaffoldBackgroundColor: const Color(0xFFEDE7F6),
        // Smooth default page transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const StoryScreen(),
    );
  }
}
