class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String hint;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.hint,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correct_index'],
      hint: json['hint'] ?? 'No hint available.',
    );
  }
}
