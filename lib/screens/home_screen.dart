import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/library_provider.dart';
import '../services/ai_service.dart';
import '../models/story_data.dart';
import 'story_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _topicController = TextEditingController();
  final AiService _aiService = AiService();
  bool _isGenerating = false;

  void _generateStory() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final story = await _aiService.generateStory(topic);
      
      // Save it immediately to the library
      await ref.read(libraryProvider.notifier).saveStory(story);

      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => StoryScreen(storyData: story),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating story: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _topicController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedStories = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      appBar: AppBar(
        title: const Text('✨ Peblo Story Library', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI Generation Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create a New Story',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _topicController,
                          decoration: InputDecoration(
                            hintText: 'e.g., A dog who goes to space',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (_) => _generateStory(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isGenerating
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(),
                            )
                          : IconButton(
                              icon: const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.deepPurple.shade50,
                                padding: const EdgeInsets.all(12),
                              ),
                              onPressed: _generateStory,
                            ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Your Saved Stories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 12),
            
            // Library Section
            Expanded(
              child: savedStories.isEmpty
                  ? Center(
                      child: Text(
                        'No stories yet.\nGenerate one above!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: savedStories.length,
                      itemBuilder: (context, index) {
                        final story = savedStories[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.book, color: Colors.deepPurple),
                            ),
                            title: Text(story.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Theme: ${story.theme}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                ref.read(libraryProvider.notifier).deleteStory(story.id);
                              },
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => StoryScreen(storyData: story),
                              ));
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
