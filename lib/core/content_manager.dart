import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question.dart';
import '../models/progress.dart';
import 'srs_algorithm.dart';

class ContentManager {
  static final ContentManager _instance = ContentManager._internal();
  factory ContentManager() => _instance;

  final Map<String, Progress> _progressMap = {};
  final Map<String, List<Question>> _questionsByLanguage = {};
  final Map<String, Question> _questionsById = {};
  final Map<String, String> _questionLanguageMap = {};

  static const Map<String, String> defaultPackAssets = {
    'python': 'assets/packs/python_basico.json',
    'java': 'assets/packs/java_basico.json',
  };

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  ContentManager._internal() {
    _initializeDefaultQuestions();
    try {
      loadAllPacks();
    } catch (e) {
      debugPrint("No se pudieron cargar los assets en _internal: $e");
    }
  }

  void _initializeDefaultQuestions() {
    final initialPython = [
      Question(
        id: "py_001",
        question: "¿Qué hace el decorador @staticmethod en Python?",
        options: [
          "Modifica el estado de la instancia.",
          "Permite llamar al método sin instanciar la clase y no recibe 'self' ni 'cls'.",
          "Requiere pasar 'self' obligatoriamente como primer argumento.",
          "Convierte la función en un método de clase que recibe 'cls'."
        ],
        correctIndex: 1,
        hint: "No depende ni de la instancia ni de la clase en sí.",
      ),
      Question(
        id: "py_002",
        question: "¿Cuál es la principal diferencia entre una lista y una tupla en Python?",
        options: [
          "Las listas son inmutables y las tuplas son mutables.",
          "Las listas usan paréntesis () y las tuplas corchetes [].",
          "Las listas son mutables y las tuplas son inmutables.",
          "Las tuplas solo pueden contener datos de tipo numérico."
        ],
        correctIndex: 2,
        hint: "Una vez creada, no puedes modificar los elementos de una tupla.",
      ),
    ];

    _registerQuestions('python', initialPython);
  }

  void _registerQuestions(String language, List<Question> questions) {
    final langKey = language.toLowerCase().trim();
    _questionsByLanguage[langKey] = questions;
    for (final q in questions) {
      _questionsById[q.id] = q;
      _questionLanguageMap[q.id] = langKey;
    }
  }

  /// Loads all registered pack assets dynamically using rootBundle
  Future<void> loadAllPacks() async {
    for (final entry in defaultPackAssets.entries) {
      await loadPackFromAsset(entry.key, entry.value);
    }
    _isLoaded = true;
  }

  /// Loads a specific language pack from default registered assets
  Future<List<Question>> loadPack(String language) async {
    final langKey = language.toLowerCase().trim();
    final assetPath = defaultPackAssets[langKey];
    if (assetPath != null) {
      return await loadPackFromAsset(langKey, assetPath);
    }
    return [];
  }

  /// Loads and parses JSON from the specified asset path into Question objects
  Future<List<Question>> loadPackFromAsset(String language, String assetPath) async {
    try {
      final jsonStr = await rootBundle.loadString(assetPath);
      final List<Question> questions = parseQuestionsJson(jsonStr);
      if (questions.isNotEmpty) {
        _registerQuestions(language, questions);
      }
      return questions;
    } catch (e) {
      debugPrint("Error al cargar asset pack $language ($assetPath): $e");
      return _questionsByLanguage[language.toLowerCase().trim()] ?? [];
    }
  }

  /// Parses raw JSON string into a list of Question objects
  List<Question> parseQuestionsJson(String jsonStr) {
    final dynamic decoded = jsonDecode(jsonStr);
    if (decoded is List) {
      return decoded
          .map((item) => Question.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  /// Get all questions across all loaded packs
  List<Question> getAllQuestions() {
    return _questionsById.values.toList();
  }

  /// Query questions by language (e.g. 'python', 'java')
  List<Question> getQuestionsByLanguage(String language) {
    final langKey = language.toLowerCase().trim();
    return List.unmodifiable(_questionsByLanguage[langKey] ?? []);
  }

  /// Returns available registered languages
  List<String> getAvailableLanguages() {
    return _questionsByLanguage.keys.toList();
  }

  /// Check whether a question is due according to SRS progress
  bool isQuestionDue(String questionId) {
    final progress = _progressMap[questionId];
    if (progress == null) {
      // Unanswered questions are considered due for learning
      return true;
    }
    return progress.nextReview.isBefore(DateTime.now()) ||
        progress.nextReview.isAtSameMomentAs(DateTime.now());
  }

  /// Returns all questions that are due, optionally filtered by language
  List<Question> getDueQuestions([String? language]) {
    final candidateQuestions = (language != null && language.isNotEmpty)
        ? getQuestionsByLanguage(language)
        : getAllQuestions();

    return candidateQuestions.where((q) => isQuestionDue(q.id)).toList();
  }

  /// Returns a single question due for review, prioritizing overdue reviews then new questions.
  /// If [language] is provided, restricts selection to that language.
  /// If [fallbackToAny] is true, returns a random question when none are strictly due.
  Question? getDueQuestion([String? language, bool fallbackToAny = false]) {
    final candidateQuestions = (language != null && language.isNotEmpty)
        ? getQuestionsByLanguage(language)
        : getAllQuestions();

    if (candidateQuestions.isEmpty) return null;

    final now = DateTime.now();
    final List<Question> overdueQuestions = [];
    final List<Question> newQuestions = [];

    for (final q in candidateQuestions) {
      final progress = _progressMap[q.id];
      if (progress == null) {
        newQuestions.add(q);
      } else if (progress.nextReview.isBefore(now) || progress.nextReview.isAtSameMomentAs(now)) {
        overdueQuestions.add(q);
      }
    }

    final random = Random();
    if (overdueQuestions.isNotEmpty) {
      return overdueQuestions[random.nextInt(overdueQuestions.length)];
    } else if (newQuestions.isNotEmpty) {
      return newQuestions[random.nextInt(newQuestions.length)];
    } else if (fallbackToAny) {
      return candidateQuestions[random.nextInt(candidateQuestions.length)];
    }

    return null;
  }

  /// Records the user's answer and updates SRS progress
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
    debugPrint(
      "Progreso guardado: $questionId -> Nuevo intervalo: ${_progressMap[questionId]!.intervalDays} días",
    );
  }

  /// Get progress for a specific question
  Progress? getProgress(String questionId) {
    return _progressMap[questionId];
  }

  /// Restores progress from storage
  void restoreProgress(Map<String, Progress> progress) {
    _progressMap.clear();
    _progressMap.addAll(progress);
  }

  /// Exposes read-only view of progress map
  Map<String, Progress> get progressMap => Map.unmodifiable(_progressMap);
}
