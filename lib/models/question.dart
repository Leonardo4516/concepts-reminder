class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String hint;
  final String difficulty;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.hint,
    this.difficulty = 'medium',
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correct_index'],
      hint: json['hint'] ?? 'No hint available.',
      difficulty: (json['difficulty'] as String?)?.toLowerCase().trim() ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_index': correctIndex,
      'hint': hint,
      'difficulty': difficulty,
    };
  }
}
