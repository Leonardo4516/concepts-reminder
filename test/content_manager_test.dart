import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:concepts_reminder/core/content_manager.dart';
import 'package:concepts_reminder/models/question.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JSON Question Packs validation', () {
    test('python_basico.json exists and has valid questions', () {
      final file = File('assets/packs/python_basico.json');
      expect(file.existsSync(), isTrue);

      final jsonContent = file.readAsStringSync();
      final List<dynamic> decoded = jsonDecode(jsonContent);
      expect(decoded.length, greaterThanOrEqualTo(5));

      for (final item in decoded) {
        final q = Question.fromJson(Map<String, dynamic>.from(item as Map));
        expect(q.id, isNotEmpty);
        expect(q.question, isNotEmpty);
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
        expect(q.hint, isNotEmpty);
      }
    });

    test('java_basico.json exists and has valid questions', () {
      final file = File('assets/packs/java_basico.json');
      expect(file.existsSync(), isTrue);

      final jsonContent = file.readAsStringSync();
      final List<dynamic> decoded = jsonDecode(jsonContent);
      expect(decoded.length, greaterThanOrEqualTo(5));

      for (final item in decoded) {
        final q = Question.fromJson(Map<String, dynamic>.from(item as Map));
        expect(q.id, isNotEmpty);
        expect(q.question, isNotEmpty);
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
        expect(q.hint, isNotEmpty);
      }
    });

    test('ia_generativa_llms.json exists and has valid questions', () {
      final file = File('assets/packs/ia_generativa_llms.json');
      expect(file.existsSync(), isTrue);

      final jsonContent = file.readAsStringSync();
      final List<dynamic> decoded = jsonDecode(jsonContent);
      expect(decoded.length, greaterThanOrEqualTo(5));

      for (final item in decoded) {
        final q = Question.fromJson(Map<String, dynamic>.from(item as Map));
        expect(q.id, isNotEmpty);
        expect(q.question, isNotEmpty);
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
        expect(q.hint, isNotEmpty);
      }
    });

    test('ia_machine_learning.json exists and has valid questions', () {
      final file = File('assets/packs/ia_machine_learning.json');
      expect(file.existsSync(), isTrue);

      final jsonContent = file.readAsStringSync();
      final List<dynamic> decoded = jsonDecode(jsonContent);
      expect(decoded.length, greaterThanOrEqualTo(5));

      for (final item in decoded) {
        final q = Question.fromJson(Map<String, dynamic>.from(item as Map));
        expect(q.id, isNotEmpty);
        expect(q.question, isNotEmpty);
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
        expect(q.hint, isNotEmpty);
      }
    });
  });

  group('ContentManager functionality', () {
    test('parses questions JSON correctly', () {
      final manager = ContentManager();
      const rawJson = '''
      [
        {
          "id": "test_01",
          "question": "Pregunta de prueba",
          "options": ["Opcion A", "Opcion B"],
          "correct_index": 0,
          "hint": "Pista test"
        }
      ]
      ''';
      final questions = manager.parseQuestionsJson(rawJson);
      expect(questions.length, 1);
      expect(questions.first.id, "test_01");
      expect(questions.first.correctIndex, 0);
    });

    test('querying questions by language and SRS due checks', () {
      final manager = ContentManager();
      
      // Load both JSON files directly into manager using parseQuestionsJson
      final pyFile = File('assets/packs/python_basico.json');
      final javaFile = File('assets/packs/java_basico.json');

      final pyQuestions = manager.parseQuestionsJson(pyFile.readAsStringSync());
      final javaQuestions = manager.parseQuestionsJson(javaFile.readAsStringSync());

      expect(pyQuestions.length, greaterThanOrEqualTo(5));
      expect(javaQuestions.length, greaterThanOrEqualTo(5));

      // Test SRS logic
      final qId = pyQuestions.first.id;
      // Initially not answered, so should be due
      expect(manager.isQuestionDue(qId), isTrue);

      // Record correct answer
      manager.recordAnswer(qId, true);
      final progress = manager.getProgress(qId);
      expect(progress, isNotNull);
      expect(progress!.repetitions, 1);
      expect(progress.intervalDays, 1);

      // Now nextReview is ~1 day in future, so it shouldn't be due
      expect(manager.isQuestionDue(qId), isFalse);

      // getDueQuestion with language filter
      final duePy = manager.getDueQuestion('python');
      expect(duePy, isNotNull);
      expect(duePy!.id, isNot(qId)); // qId is no longer due
    });

    test('validates database packs and tiered difficulty filtering', () {
      final manager = ContentManager();
      
      final dbFiles = [
        'assets/packs/postgresql_avanzado.json',
        'assets/packs/mysql_avanzado.json',
        'assets/packs/mongodb_avanzado.json',
        'assets/packs/redis_avanzado.json',
        'assets/packs/sqlite_avanzado.json',
        'assets/packs/bases_de_datos.json',
      ];

      for (final filePath in dbFiles) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue, reason: '$filePath must exist');

        final decoded = jsonDecode(file.readAsStringSync()) as List<dynamic>;
        expect(decoded.length, greaterThanOrEqualTo(12), reason: '$filePath must have at least 12 questions');

        for (final item in decoded) {
          final q = Question.fromJson(Map<String, dynamic>.from(item as Map));
          expect(q.id, isNotEmpty);
          expect(q.question, isNotEmpty);
          expect(q.options.length, 4);
          expect(q.correctIndex, inInclusiveRange(0, 3));
          expect(q.hint, isNotEmpty);
          expect(['basic', 'medium', 'advanced'], contains(q.difficulty));
        }
      }

      // Test tiered difficulty logic
      final testQuestions = [
        Question(id: '1', question: 'q1', options: ['a', 'b'], correctIndex: 0, hint: 'h', difficulty: 'basic'),
        Question(id: '2', question: 'q2', options: ['a', 'b'], correctIndex: 0, hint: 'h', difficulty: 'medium'),
        Question(id: '3', question: 'q3', options: ['a', 'b'], correctIndex: 0, hint: 'h', difficulty: 'advanced'),
      ];

      final basicOnly = manager.filterByDifficulty(testQuestions, 'basic');
      expect(basicOnly.map((q) => q.id), ['1']);

      final mediumTier = manager.filterByDifficulty(testQuestions, 'medium');
      expect(mediumTier.map((q) => q.id), ['1', '2']);

      final advancedTier = manager.filterByDifficulty(testQuestions, 'advanced');
      expect(advancedTier.map((q) => q.id), ['1', '2', '3']);
    });
  });
}
