class Progress {
  final String questionId;
  int repetitions;
  double easeFactor;
  int intervalDays;
  DateTime nextReview;

  Progress({
    required this.questionId,
    required this.repetitions,
    required this.easeFactor,
    required this.intervalDays,
    required this.nextReview,
  });

  factory Progress.fromJson(String id, Map<String, dynamic> json) {
    return Progress(
      questionId: id,
      repetitions: json['repetitions'] ?? 0,
      easeFactor: (json['ease_factor'] ?? 2.5).toDouble(),
      intervalDays: json['interval'] ?? 0,
      nextReview: DateTime.parse(json['next_review'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'repetitions': repetitions,
      'ease_factor': easeFactor,
      'interval': intervalDays,
      'next_review': nextReview.toIso8601String(),
    };
  }
}
