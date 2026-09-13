import 'dart:math';
import '../models/question.dart';
import '../models/progress.dart';
import 'srs_algorithm.dart';

class ContentManager {
  static final ContentManager _instance = ContentManager._internal();
  factory ContentManager() => _instance;
  ContentManager._internal();

  final Map<String, Progress> _progressMap = {};

  final List<Question> _dummyQuestions = [
    Question(
      id: "py_001",
      question: "¿Qué hace el decorador @staticmethod en Python?",
      options: [
        "Modifica el estado de la instancia.",
        "Permite llamar al método sin instanciar la clase.",
        "Requiere pasar 'self' obligatoriamente."
      ],
      correctIndex: 1,
      hint: "No depende de la instancia.",
    ),
    Question(
      id: "py_002",
      question: "¿Cuál es la diferencia entre lista y tupla?",
      options: [
        "Las listas son inmutables.",
        "Las tuplas usan corchetes [].",
        "Las tuplas son inmutables."
      ],
      correctIndex: 2,
      hint: "No puedes cambiar una tupla.",
    )
  ];

  Question? getDueQuestion() {
    // For demo purposes, just return a random question
    return _dummyQuestions[Random().nextInt(_dummyQuestions.length)];
  }

  void recordAnswer(String questionId, bool correct) {
    if (!_progressMap.containsKey(questionId)) {
      _progressMap[questionId] = Progress(
        questionId: questionId,
        repetitions: 0,
        easeFactor: 2.5,
        intervalDays: 0,
        nextReview: DateTime.now(),
      );
    }
    
    SrsAlgorithm.updateProgress(_progressMap[questionId]!, correct);
    print("Progreso guardado: $questionId -> Nuevo intervalo: ${_progressMap[questionId]!.intervalDays} días");
  }
}
