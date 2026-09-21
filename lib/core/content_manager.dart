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
  final Map<String, List<Question>> _questionsByPack = {};
  final Map<String, Question> _questionsById = {};
  final Map<String, String> _questionPackMap = {};

  /// Default registered asset paths for all knowledge packs
  static const Map<String, String> defaultPackAssets = {
    'python': 'assets/packs/python_basico.json',
    'java': 'assets/packs/java_basico.json',
    'javascript': 'assets/packs/javascript_basico.json',
    'typescript': 'assets/packs/typescript_basico.json',
    'go': 'assets/packs/go_basico.json',
    'rust': 'assets/packs/rust_basico.json',
    'dart': 'assets/packs/dart_basico.json',
    'poo_conceptos': 'assets/packs/poo_conceptos.json',
    'principios_solid': 'assets/packs/principios_solid.json',
    'patrones_diseno': 'assets/packs/patrones_diseno.json',
    'arquitectura_hexagonal': 'assets/packs/arquitectura_hexagonal.json',
    'metodologia_scrum': 'assets/packs/metodologia_scrum.json',
    'bases_de_datos': 'assets/packs/bases_de_datos.json',
    'postgresql': 'assets/packs/postgresql_avanzado.json',
    'mysql': 'assets/packs/mysql_avanzado.json',
    'mongodb': 'assets/packs/mongodb_avanzado.json',
    'redis': 'assets/packs/redis_avanzado.json',
    'sqlite': 'assets/packs/sqlite_avanzado.json',
    'redes_y_apis': 'assets/packs/redes_y_apis.json',
    'ciberseguridad_web': 'assets/packs/ciberseguridad_web.json',
    'devops_cloud': 'assets/packs/devops_cloud.json',
    'estructuras_algoritmos': 'assets/packs/estructuras_algoritmos.json',
    'ia_generativa_llms': 'assets/packs/ia_generativa_llms.json',
    'ia_machine_learning': 'assets/packs/ia_machine_learning.json',
  };

  /// Category definitions and their associated pack identifiers
  static const Map<String, List<String>> categoryPacks = {
    'Lenguajes': ['python', 'java', 'javascript', 'typescript', 'go', 'rust', 'dart'],
    'POO & Fundamentos': ['poo_conceptos'],
    'Metodologías & Agile': ['principios_solid', 'metodologia_scrum'],
    'Arquitectura & Patrones': ['patrones_diseno', 'arquitectura_hexagonal'],
    'Bases de Datos': ['bases_de_datos', 'postgresql', 'mysql', 'mongodb', 'redis', 'sqlite'],
    'Redes & APIs': ['redes_y_apis'],
    'Ciberseguridad Web': ['ciberseguridad_web'],
    'DevOps & Cloud': ['devops_cloud'],
    'Estructuras & Algoritmos': ['estructuras_algoritmos'],
    'Inteligencia Artificial': ['ia_generativa_llms', 'ia_machine_learning'],
  };

  /// Human-readable display titles for each pack
  static const Map<String, String> packDisplayNames = {
    'python': 'Python',
    'java': 'Java',
    'javascript': 'JavaScript',
    'typescript': 'TypeScript',
    'go': 'Go',
    'rust': 'Rust',
    'dart': 'Dart',
    'poo_conceptos': 'POO Conceptos',
    'principios_solid': 'Principios SOLID',
    'patrones_diseno': 'Patrones de Diseño',
    'arquitectura_hexagonal': 'Arquitectura Hexagonal & Clean',
    'metodologia_scrum': 'Metodología SCRUM & Agile',
    'bases_de_datos': 'Bases de Datos (Fundamentos)',
    'postgresql': 'PostgreSQL',
    'mysql': 'MySQL & MariaDB',
    'mongodb': 'MongoDB & NoSQL',
    'redis': 'Redis & In-Memory',
    'sqlite': 'SQLite & Embebidas',
    'redes_y_apis': 'Redes & Protocolos HTTP',
    'ciberseguridad_web': 'Ciberseguridad Web (OWASP)',
    'devops_cloud': 'DevOps, Docker & Cloud',
    'estructuras_algoritmos': 'Estructuras & Algoritmos (DSA)',
    'ia_generativa_llms': 'IA Generativa & LLMs',
    'ia_machine_learning': 'Machine Learning & Deep Learning',
  };

  /// Reverse lookup from pack key to category
  static const Map<String, String> packCategoryMap = {
    'python': 'Lenguajes',
    'java': 'Lenguajes',
    'javascript': 'Lenguajes',
    'typescript': 'Lenguajes',
    'go': 'Lenguajes',
    'rust': 'Lenguajes',
    'dart': 'Lenguajes',
    'poo_conceptos': 'POO & Fundamentos',
    'principios_solid': 'Metodologías & Agile',
    'metodologia_scrum': 'Metodologías & Agile',
    'patrones_diseno': 'Arquitectura & Patrones',
    'arquitectura_hexagonal': 'Arquitectura & Patrones',
    'bases_de_datos': 'Bases de Datos',
    'postgresql': 'Bases de Datos',
    'mysql': 'Bases de Datos',
    'mongodb': 'Bases de Datos',
    'redis': 'Bases de Datos',
    'sqlite': 'Bases de Datos',
    'redes_y_apis': 'Redes & APIs',
    'ciberseguridad_web': 'Ciberseguridad Web',
    'devops_cloud': 'DevOps & Cloud',
    'estructuras_algoritmos': 'Estructuras & Algoritmos',
    'ia_generativa_llms': 'Inteligencia Artificial',
    'ia_machine_learning': 'Inteligencia Artificial',
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

  void _registerQuestions(String packKey, List<Question> questions) {
    final key = packKey.toLowerCase().trim();
    _questionsByPack[key] = questions;
    for (final q in questions) {
      _questionsById[q.id] = q;
      _questionPackMap[q.id] = key;
    }
  }

  /// Loads all registered pack assets dynamically using rootBundle
  Future<void> loadAllPacks() async {
    for (final entry in defaultPackAssets.entries) {
      await loadPackFromAsset(entry.key, entry.value);
    }
    _isLoaded = true;
  }

  /// Loads a specific pack from default registered assets
  Future<List<Question>> loadPack(String packKey) async {
    final key = packKey.toLowerCase().trim();
    final assetPath = defaultPackAssets[key];
    if (assetPath != null) {
      return await loadPackFromAsset(key, assetPath);
    }
    return [];
  }

  /// Loads and parses JSON from the specified asset path into Question objects
  Future<List<Question>> loadPackFromAsset(String packKey, String assetPath) async {
    final key = packKey.toLowerCase().trim();
    try {
      final jsonStr = await rootBundle.loadString(assetPath);
      final List<Question> questions = parseQuestionsJson(jsonStr);
      if (questions.isNotEmpty) {
        _registerQuestions(key, questions);
      }
      return questions;
    } catch (e) {
      debugPrint("Error al cargar asset pack $key ($assetPath): $e");
      return _questionsByPack[key] ?? [];
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

  static const Map<String, String> _topicAliases = {
    'poo': 'poo_conceptos',
    'abstracción': 'poo_conceptos',
    'abstraccion': 'poo_conceptos',
    'polimorfismo': 'poo_conceptos',
    'solid': 'principios_solid',
    'clean code': 'principios_solid',
    'dry/kiss': 'principios_solid',
    'patrones de diseño': 'patrones_diseno',
    'patrones de diseno': 'patrones_diseno',
    'singleton': 'patrones_diseno',
    'factory': 'patrones_diseno',
    'observer': 'patrones_diseno',
    'ia': 'ia_generativa_llms',
    'inteligencia artificial': 'ia_generativa_llms',
    'llm': 'ia_generativa_llms',
    'llms': 'ia_generativa_llms',
    'rag': 'ia_generativa_llms',
    'machine learning': 'ia_machine_learning',
    'deep learning': 'ia_machine_learning',
    'ml': 'ia_machine_learning',
    'postgres': 'postgresql',
    'postgresql': 'postgresql',
    'mysql': 'mysql',
    'mariadb': 'mysql',
    'mongo': 'mongodb',
    'mongodb': 'mongodb',
    'redis': 'redis',
    'sqlite': 'sqlite',
    'sql': 'bases_de_datos',
    'bases de datos': 'bases_de_datos',
  };

  /// Predefined subtopic metadata with friendly display names
  static const Map<String, Map<String, String>> packSubtopicDefinitions = {
    'java': {
      'fundamentos': 'Fundamentos Básicos',
      'poo': 'POO en Java',
      'colecciones': 'Colecciones & Generics',
      'concurrencia': 'Concurrencia & Threads',
      'javafx': 'JavaFX & GUI',
    },
    'python': {
      'fundamentos': 'Sintaxis & Tipos',
      'poo': 'POO & Clases',
      'avanzado': 'Generadores & Decoradores',
      'asyncio': 'Asyncio & Concurrencia',
    },
    'postgresql': {
      'indices_planes': 'Índices & Planes de Ejecución',
      'mvcc_vacuum': 'MVCC, VACUUM & Bloat',
      'wal_replicacion': 'WAL & Replicación',
      'extensiones_jsonb': 'JSONB & Extensiones',
    },
    'mysql': {
      'motores_innodb': 'Motores InnoDB & MyISAM',
      'buffer_pool': 'Buffer Pool & Memoria',
      'replicacion_binlog': 'Replicación & Logs Binarios',
      'optimizacion_queries': 'Índices & Optimización EXPLAIN',
    },
    'mongodb': {
      'crud_documentos': 'CRUD, BSON & Documentos',
      'aggregation_pipeline': 'Aggregation Pipeline',
      'wiredtiger_internals': 'WiredTiger & Checkpoints',
      'sharding_replicas': 'Sharding & Replica Sets',
    },
    'redis': {
      'estructuras_datos': 'Strings, Hashes, Lists & Sets',
      'persistencia_rdb_aof': 'Persistencia RDB & AOF',
      'streams_pubsub_lua': 'Streams, Pub/Sub & Lua',
      'cluster_sentinel': 'Redis Cluster & Sentinel',
    },
    'sqlite': {
      'arquitectura_btree': 'B-Tree & Páginas en Disco',
      'modo_wal': 'Modo WAL & Concurrencia',
      'pragmas_concurrencia': 'Pragmas & Rendimiento',
    },
    'bases_de_datos': {
      'fundamentos_acid': 'Modelo Relacional & ACID',
      'normalizacion': 'Normalización & Formas Normales',
      'transacciones_locks': 'Aislamiento & Bloqueos',
    },
    'ia_generativa_llms': {
      'llms_transformers': 'LLMs & Transformers',
      'rag_embeddings': 'RAG & Embeddings Vectoriales',
      'prompting_finetuning': 'Prompting & Fine-Tuning',
    },
    'ia_machine_learning': {
      'aprendizaje_supervisado': 'Supervisado & No Supervisado',
      'deep_learning': 'Redes Neuronales & Backpropagation',
      'metricas_evaluacion': 'Métricas & Evaluación',
    },
    'poo_conceptos': {
      'polimorfismo_herencia': 'Polimorfismo & Herencia',
      'encapsulamiento_abstraccion': 'Encapsulamiento & Abstracción',
      'cohesion_acoplamiento': 'Acoplamiento & Cohesión',
    },
    'principios_solid': {
      'solid_principles': 'Principios S.O.L.I.D.',
      'clean_code': 'Clean Code, DRY & KISS',
    },
    'patrones_diseno': {
      'patrones_creacionales': 'Patrones Creacionales',
      'patrones_estructurales': 'Patrones Estructurales & Comportamiento',
    },
    'javascript': {
      'event_loop': 'Event Loop & Asincronía',
      'closures_scope': 'Closures & Scope Léxico',
      'prototipos_async': 'Prototipos & Clases',
    },
    'go': {
      'goroutines_canales': 'Goroutines & Canales',
      'interfaces_tipos': 'Interfaces & Tipos',
      'memoria_punteros': 'Punteros & Rutinas',
    },
  };

  /// Returns available subtopics for a given pack as a Map of key -> displayName
  Map<String, String> getSubtopicsForPack(String packKey) {
    String key = packKey.toLowerCase().trim();
    if (_topicAliases.containsKey(key)) {
      key = _topicAliases[key]!;
    }
    if (packSubtopicDefinitions.containsKey(key)) {
      return Map.from(packSubtopicDefinitions[key]!);
    }
    final questions = _questionsByPack[key] ?? [];
    final Map<String, String> result = {};
    for (final q in questions) {
      if (!result.containsKey(q.subtopic)) {
        final sub = q.subtopic;
        final formatted = sub.replaceAll('_', ' ');
        final title = formatted.isNotEmpty
            ? '${formatted[0].toUpperCase()}${formatted.substring(1)}'
            : sub;
        result[sub] = title;
      }
    }
    if (result.isEmpty) {
      result['general'] = 'General';
    }
    return result;
  }

  /// Returns the list of difficulties allowed for a given target difficulty:
  /// - 'basic'    => ['basic'] (only easy questions)
  /// - 'medium'   => ['basic', 'medium'] (medium and easy questions)
  /// - 'advanced' => ['basic', 'medium', 'advanced'] (hard, medium, and easy questions)
  static List<String> getAllowedDifficulties(String difficulty) {
    final diff = difficulty.toLowerCase().trim();
    switch (diff) {
      case 'basic':
        return const ['basic'];
      case 'medium':
        return const ['basic', 'medium'];
      case 'advanced':
      default:
        return const ['basic', 'medium', 'advanced'];
    }
  }

  /// Filters a list of questions based on a user's selected difficulty level.
  /// If [difficulty] is null, all questions are returned.
  List<Question> filterByDifficulty(List<Question> questions, String? difficulty) {
    if (difficulty == null || difficulty.isEmpty) return questions;
    final allowed = getAllowedDifficulties(difficulty);
    final filtered = questions.where((q) => allowed.contains(q.difficulty)).toList();
    return filtered.isNotEmpty ? filtered : questions;
  }

  /// Filters questions by allowed subtopics. If [allowedSubtopics] is null or empty, returns all.
  List<Question> filterBySubtopics(List<Question> questions, List<String>? allowedSubtopics) {
    if (allowedSubtopics == null || allowedSubtopics.isEmpty) return questions;
    final lowerAllowed = allowedSubtopics.map((s) => s.toLowerCase().trim()).toSet();
    final filtered = questions
        .where((q) => lowerAllowed.contains(q.subtopic.toLowerCase().trim()))
        .toList();
    return filtered.isNotEmpty ? filtered : questions;
  }

  /// Query questions by pack key (e.g. 'python', 'poo_conceptos', 'postgresql'),
  /// optionally filtered by [difficulty] and [allowedSubtopics].
  List<Question> getQuestionsByPack(String packKey, [String? difficulty, List<String>? allowedSubtopics]) {
    String key = packKey.toLowerCase().trim();
    if (_topicAliases.containsKey(key)) {
      key = _topicAliases[key]!;
    }
    final raw = List<Question>.unmodifiable(_questionsByPack[key] ?? []);
    final byDiff = filterByDifficulty(raw, difficulty);
    return filterBySubtopics(byDiff, allowedSubtopics);
  }

  /// Backwards-compatible alias for getQuestionsByPack
  List<Question> getQuestionsByLanguage(String language, [String? difficulty, List<String>? allowedSubtopics]) {
    return getQuestionsByPack(language, difficulty, allowedSubtopics);
  }

  /// Returns available registered pack keys
  List<String> getAvailablePacks() {
    return defaultPackAssets.keys.toList();
  }

  /// Backwards-compatible alias for getAvailablePacks
  List<String> getAvailableLanguages() {
    return _questionsByPack.keys.toList();
  }

  /// Returns list of all defined category names
  List<String> getAvailableCategories() {
    return categoryPacks.keys.toList();
  }

  /// Returns pack keys belonging to a category
  List<String> getPacksByCategory(String category) {
    return categoryPacks[category] ?? [];
  }

  /// Returns category name for a given pack key
  String? getCategoryForPack(String packKey) {
    return packCategoryMap[packKey.toLowerCase().trim()];
  }

  /// Returns human-readable display title for a pack
  String getPackDisplayName(String packKey) {
    final key = packKey.toLowerCase().trim();
    return packDisplayNames[key] ??
        (key.isNotEmpty ? '${key[0].toUpperCase()}${key.substring(1)}' : key);
  }

  /// Returns all questions belonging to all packs within a given category,
  /// optionally filtered by [difficulty].
  List<Question> getQuestionsByCategory(String category, [String? difficulty, Map<String, List<String>>? activeSubtopics]) {
    final packs = getPacksByCategory(category);
    final List<Question> result = [];
    for (final packKey in packs) {
      final allowedSub = activeSubtopics?[packKey.toLowerCase().trim()];
      final questions = getQuestionsByPack(packKey, difficulty, allowedSub);
      result.addAll(questions);
    }
    return result;
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

  /// Returns all questions that are due, optionally filtered by pack, difficulty, and allowed subtopics
  List<Question> getDueQuestions([String? packKey, String? difficulty, List<String>? allowedSubtopics]) {
    final candidateQuestions = (packKey != null && packKey.isNotEmpty)
        ? getQuestionsByPack(packKey, difficulty, allowedSubtopics)
        : filterByDifficulty(getAllQuestions(), difficulty);

    return candidateQuestions.where((q) => isQuestionDue(q.id)).toList();
  }

  /// Returns all questions that are due within a specific category, optionally filtered by difficulty
  List<Question> getDueQuestionsByCategory(String category, [String? difficulty, Map<String, List<String>>? activeSubtopics]) {
    final candidateQuestions = getQuestionsByCategory(category, difficulty, activeSubtopics);
    return candidateQuestions.where((q) => isQuestionDue(q.id)).toList();
  }

  /// Returns a single question due for review, prioritizing overdue reviews then new questions.
  /// If [packKey] is provided, restricts selection to that pack.
  /// If [fallbackToAny] is true, returns a random question when none are strictly due.
  /// If [difficulty] is specified, restricts candidate pool according to tiered difficulty rules.
  /// If [allowedSubtopics] is provided, only picks from active subtopics.
  Question? getDueQuestion([String? packKey, bool fallbackToAny = false, String? difficulty, List<String>? allowedSubtopics]) {
    final candidateQuestions = (packKey != null && packKey.isNotEmpty)
        ? getQuestionsByPack(packKey, difficulty, allowedSubtopics)
        : filterByDifficulty(getAllQuestions(), difficulty);

    return _pickDueQuestionFromList(candidateQuestions, fallbackToAny);
  }

  /// Returns a single question due for review within a specific category.
  Question? getDueQuestionByCategory(String category, [bool fallbackToAny = false, String? difficulty]) {
    final candidateQuestions = getQuestionsByCategory(category, difficulty);
    return _pickDueQuestionFromList(candidateQuestions, fallbackToAny);
  }

  Question? _pickDueQuestionFromList(List<Question> candidates, bool fallbackToAny) {
    if (candidates.isEmpty) return null;

    final now = DateTime.now();
    final List<Question> overdueQuestions = [];
    final List<Question> newQuestions = [];

    for (final q in candidates) {
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
      return candidates[random.nextInt(candidates.length)];
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

  /// Calculates mastery stats for a given topic pack:
  /// Returns a map with 'total', 'learned', 'mastered', 'masteryPercent' (0.0 - 1.0),
  /// and whether the user is ready to promote to the next difficulty ('canPromote').
  Map<String, dynamic> getTopicMasteryStats(String packKey, String currentDifficulty, [List<String>? allowedSubtopics]) {
    final questions = getQuestionsByPack(packKey, currentDifficulty, allowedSubtopics);
    if (questions.isEmpty) {
      return {
        'total': 0,
        'learned': 0,
        'mastered': 0,
        'masteryPercent': 0.0,
        'canPromote': false,
        'suggestedDifficulty': currentDifficulty,
      };
    }

    int learned = 0;
    int mastered = 0;
    for (final q in questions) {
      final prog = _progressMap[q.id];
      if (prog != null && prog.repetitions > 0) {
        learned++;
        if (prog.intervalDays >= 7) {
          mastered++;
        }
      }
    }

    final double masteryPercent = learned / questions.length;
    bool canPromote = false;
    String suggested = currentDifficulty;

    if (currentDifficulty.toLowerCase() == 'basic' && masteryPercent >= 0.70) {
      canPromote = true;
      suggested = 'medium';
    } else if (currentDifficulty.toLowerCase() == 'medium' && masteryPercent >= 0.75) {
      canPromote = true;
      suggested = 'advanced';
    }

    return {
      'total': questions.length,
      'learned': learned,
      'mastered': mastered,
      'masteryPercent': masteryPercent,
      'canPromote': canPromote,
      'suggestedDifficulty': suggested,
    };
  }
}

