import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:concepts_reminder/models/app_settings.dart';
import 'package:concepts_reminder/models/progress.dart';
import 'package:concepts_reminder/core/storage_service.dart';
import 'package:concepts_reminder/core/reminder_scheduler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSettings Model Tests', () {
    test('default values are as expected', () {
      const settings = AppSettings();
      expect(settings.frequencyMinutes, 60);
      expect(settings.activeLanguages, ['Python', 'Java']);
      expect(settings.difficulty, 'medium');
      expect(settings.fullScreenLock, true);
    });

    test('toJson and fromJson serialize properly', () {
      const original = AppSettings(
        frequencyMinutes: 30,
        activeLanguages: ['Python', 'Dart', 'Rust'],
        difficulty: 'hard',
        fullScreenLock: false,
      );

      final json = original.toJson();
      final fromJson = AppSettings.fromJson(json);

      expect(fromJson.frequencyMinutes, 30);
      expect(fromJson.activeLanguages, ['Python', 'Dart', 'Rust']);
      expect(fromJson.difficulty, 'hard');
      expect(fromJson.fullScreenLock, false);
      expect(fromJson, original);
    });

    test('copyWith works properly', () {
      const original = AppSettings();
      final updated = original.copyWith(
        frequencyMinutes: 15,
        difficulty: 'easy',
      );

      expect(updated.frequencyMinutes, 15);
      expect(updated.difficulty, 'easy');
      expect(updated.activeLanguages, ['Python', 'Java']);
      expect(updated.fullScreenLock, true);
    });
  });

  group('StorageService Tests', () {
    late StorageService storageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
    });

    test('saves and loads AppSettings', () async {
      final initialSettings = await storageService.loadSettings();
      expect(initialSettings.frequencyMinutes, 60);

      const customSettings = AppSettings(
        frequencyMinutes: 45,
        activeLanguages: ['Dart'],
        difficulty: 'advanced',
        fullScreenLock: false,
      );

      await storageService.saveSettings(customSettings);
      final loaded = await storageService.loadSettings();

      expect(loaded.frequencyMinutes, 45);
      expect(loaded.activeLanguages, ['Dart']);
      expect(loaded.difficulty, 'advanced');
      expect(loaded.fullScreenLock, false);
    });

    test('saves and loads Progress Map', () async {
      final initialMap = await storageService.loadProgressMap();
      expect(initialMap.isEmpty, true);

      final progress1 = Progress(
        questionId: 'q_001',
        repetitions: 2,
        easeFactor: 2.6,
        intervalDays: 4,
        nextReview: DateTime(2026, 9, 15, 10, 0),
      );
      final progress2 = Progress(
        questionId: 'q_002',
        repetitions: 1,
        easeFactor: 2.5,
        intervalDays: 1,
        nextReview: DateTime(2026, 9, 14, 10, 0),
      );

      final mapToSave = {
        'q_001': progress1,
        'q_002': progress2,
      };

      await storageService.saveProgressMap(mapToSave);

      final loadedMap = await storageService.loadProgressMap();
      expect(loadedMap.length, 2);
      expect(loadedMap['q_001']?.questionId, 'q_001');
      expect(loadedMap['q_001']?.repetitions, 2);
      expect(loadedMap['q_001']?.easeFactor, 2.6);
      expect(loadedMap['q_001']?.intervalDays, 4);
      expect(loadedMap['q_002']?.repetitions, 1);
    });

    test('saves single progress item and loads it', () async {
      final progress = Progress(
        questionId: 'py_101',
        repetitions: 3,
        easeFactor: 2.7,
        intervalDays: 10,
        nextReview: DateTime(2026, 9, 20),
      );

      await storageService.saveProgress(progress);
      final loaded = await storageService.getProgress('py_101');
      expect(loaded, isNotNull);
      expect(loaded?.questionId, 'py_101');
      expect(loaded?.repetitions, 3);
      expect(loaded?.intervalDays, 10);
    });

    test('clearAll removes settings and progress', () async {
      await storageService.saveSettings(const AppSettings(frequencyMinutes: 20));
      await storageService.saveProgress(Progress(
        questionId: 'temp',
        repetitions: 1,
        easeFactor: 2.5,
        intervalDays: 1,
        nextReview: DateTime.now(),
      ));

      await storageService.clearAll();

      final settings = await storageService.loadSettings();
      expect(settings.frequencyMinutes, 60);

      final progressMap = await storageService.loadProgressMap();
      expect(progressMap.isEmpty, true);
    });
  });

  group('ReminderScheduler Tests', () {
    late ReminderScheduler scheduler;

    setUp(() {
      scheduler = ReminderScheduler();
      scheduler.stop();
    });

    tearDown(() {
      scheduler.stop();
    });

    test('initial state and starting scheduler', () {
      expect(scheduler.isRunning, false);

      scheduler.start(frequencyMinutes: 30);
      expect(scheduler.isRunning, true);
      expect(scheduler.frequencyMinutes, 30);

      scheduler.stop();
      expect(scheduler.isRunning, false);
    });

    test('updateFrequency changes frequency and restarts if running', () {
      scheduler.start(frequencyMinutes: 20);
      expect(scheduler.frequencyMinutes, 20);

      scheduler.updateFrequency(45);
      expect(scheduler.frequencyMinutes, 45);
      expect(scheduler.isRunning, true);

      scheduler.stop();
      scheduler.updateFrequency(15);
      expect(scheduler.frequencyMinutes, 15);
      expect(scheduler.isRunning, false);
    });

    test('triggerNow fires callback, stream, and updates notifiers', () async {
      bool callbackFired = false;
      DateTime? streamedTime;

      scheduler.onTrigger = () {
        callbackFired = true;
      };

      final sub = scheduler.onReminder.listen((time) {
        streamedTime = time;
      });

      final initialCount = scheduler.triggerCountNotifier.value;
      scheduler.triggerNow();

      await Future.delayed(const Duration(milliseconds: 10));

      expect(callbackFired, true);
      expect(streamedTime, isNotNull);
      expect(scheduler.triggerCountNotifier.value, initialCount + 1);
      expect(scheduler.lastTriggerNotifier.value, isNotNull);

      await sub.cancel();
    });

    test('periodic timer triggers as expected with customInterval', () async {
      int triggerCount = 0;

      scheduler.start(
        customInterval: const Duration(milliseconds: 50),
        onTriggerCallback: () {
          triggerCount++;
        },
      );

      await Future.delayed(const Duration(milliseconds: 140));
      scheduler.stop();

      expect(triggerCount, greaterThanOrEqualTo(2));
    });

    test('validates real streak calculation and session recording', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();

      // Initially, streak is 0
      final initialStreak = await storage.getStreak();
      expect(initialStreak, 0);

      // Record first session today
      final streakDay1 = await storage.recordStudySession();
      expect(streakDay1, 1);

      // Subsequent session on the same day maintains streak
      final sameDayStreak = await storage.recordStudySession();
      expect(sameDayStreak, 1);

      final currentStreak = await storage.getStreak();
      expect(currentStreak, 1);
    });

    test('validates AppSettings new mobile and granular difficulty fields', () {
      const settings = AppSettings(
        topicDifficulties: {'java': 'advanced', 'python': 'basic'},
        hapticsEnabled: true,
        soundEnabled: false,
        quietHoursEnabled: true,
        quietStartHour: 23,
        quietEndHour: 7,
      );

      final json = settings.toJson();
      final fromJson = AppSettings.fromJson(json);

      expect(fromJson.topicDifficulties['java'], 'advanced');
      expect(fromJson.topicDifficulties['python'], 'basic');
      expect(fromJson.hapticsEnabled, isTrue);
      expect(fromJson.soundEnabled, isFalse);
      expect(fromJson.quietHoursEnabled, isTrue);
      expect(fromJson.quietStartHour, 23);
      expect(fromJson.quietEndHour, 7);
    });
  });
}

