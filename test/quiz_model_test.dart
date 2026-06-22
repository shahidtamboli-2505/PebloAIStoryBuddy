import 'package:flutter_test/flutter_test.dart';
import 'package:peblo_ai_story_buddy/models/quiz_model.dart';

void main() {
  group('QuizModel', () {
    test('parses from JSON correctly', () {
      final json = {
        'question': "What colour was Pip the Robot's lost gear?",
        'options': ['Red', 'Green', 'Blue', 'Yellow'],
        'answer': 'Blue',
      };

      final quiz = QuizModel.fromJson(json);

      expect(quiz.question, "What colour was Pip the Robot's lost gear?");
      expect(quiz.options.length, 4);
      expect(quiz.answer, 'Blue');
    });

    test('isCorrect returns true for correct answer', () {
      final quiz = QuizModel.fromJson({
        'question': 'Test?',
        'options': ['A', 'B'],
        'answer': 'A',
      });

      expect(quiz.isCorrect('A'), true);
      expect(quiz.isCorrect('B'), false);
    });

    test('supports any number of options', () {
      final twoOptions = QuizModel.fromJson({
        'question': 'Q?',
        'options': ['X', 'Y'],
        'answer': 'X',
      });
      expect(twoOptions.options.length, 2);

      final sixOptions = QuizModel.fromJson({
        'question': 'Q?',
        'options': ['A', 'B', 'C', 'D', 'E', 'F'],
        'answer': 'C',
      });
      expect(sixOptions.options.length, 6);
    });

    test('toJson round-trips correctly', () {
      final original = QuizModel.fromJson({
        'question': 'Test?',
        'options': ['A', 'B', 'C'],
        'answer': 'B',
      });

      final json = original.toJson();
      final roundTripped = QuizModel.fromJson(json);

      expect(roundTripped.question, original.question);
      expect(roundTripped.options, original.options);
      expect(roundTripped.answer, original.answer);
    });
  });
}
