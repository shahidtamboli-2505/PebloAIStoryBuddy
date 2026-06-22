/// QuizModel — Data model for quiz questions.
///
/// Parses quiz data from JSON and supports any number of options.
/// Designed to be reusable and scalable for future quiz formats.
library;

class QuizModel {
  /// The quiz question text.
  final String question;

  /// List of answer options (supports any number).
  final List<String> options;

  /// The correct answer string (must match one of the options).
  final String answer;

  const QuizModel({
    required this.question,
    required this.options,
    required this.answer,
  });

  /// Factory constructor to create a [QuizModel] from a JSON map.
  ///
  /// Expects keys: `question` (String), `options` (List<String>), `answer` (String).
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answer: json['answer'] as String,
    );
  }

  /// Converts the model back to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
    };
  }

  /// Checks whether the given [selectedAnswer] is correct.
  bool isCorrect(String selectedAnswer) => selectedAnswer == answer;

  @override
  String toString() =>
      'QuizModel(question: $question, options: $options, answer: $answer)';
}
