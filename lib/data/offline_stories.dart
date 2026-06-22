import '../models/story_data.dart';
import '../models/quiz_model.dart';

final List<StoryData> offlineStories = [
  StoryData(
    id: 'story_space',
    title: 'Pip goes to Space',
    theme: 'Space Adventure',
    text: 'Pip the Robot always looked up at the stars. One day, he built a shiny silver rocket ship in his backyard. "3... 2... 1... Blastoff!" he shouted. The rocket zoomed past the fluffy white clouds and into the deep, dark sky. Pip saw twinkling stars and a glowing green planet. He landed softly and stepped out. The ground was bouncy like a trampoline! Pip bounced around, collecting shiny space rocks. After a fun day, he flew back home, ready for his next adventure.',
    quiz: QuizModel(
      question: 'What colour was the planet Pip landed on?',
      options: ['Red', 'Green', 'Blue', 'Yellow'],
      answer: 'Green',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  StoryData(
    id: 'story_ocean',
    title: 'Pip\'s Ocean Dive',
    theme: 'Underwater Explorer',
    text: 'Pip the Robot wanted to see the bottom of the ocean. He put on his special waterproof suit and dove into the blue water. Splash! He swam past a friendly pink octopus and a school of tiny silver fish. Suddenly, he found a hidden treasure chest resting on the sandy floor. Pip opened it, but instead of gold, it was full of ancient seashells! He picked the prettiest spiral shell to take home and waved goodbye to the fish.',
    quiz: QuizModel(
      question: 'What did Pip find in the treasure chest?',
      options: ['Gold coins', 'Ancient seashells', 'A magic wand', 'A pirate hat'],
      answer: 'Ancient seashells',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  StoryData(
    id: 'story_forest',
    title: 'Pip and the Magic Forest',
    theme: 'Magic Woods',
    text: 'Pip the Robot walked into the Whispering Woods. The trees had glowing blue leaves, and the flowers hummed a quiet tune. As Pip explored, he lost his favorite copper gear! He looked everywhere, but couldn\'t find it. A small, furry creature with big eyes offered to help. Together, they searched until they found the gear resting on a giant mushroom. Pip thanked his new friend with a happy beep and walked home, glad to have his gear back.',
    quiz: QuizModel(
      question: 'Where did Pip and his friend find the lost gear?',
      options: ['Under a rock', 'In a tree', 'On a giant mushroom', 'In the river'],
      answer: 'On a giant mushroom',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
