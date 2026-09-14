import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/progress.dart';

/// Storage service using SharedPreferences for persisting user settings and SRS progress.
class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._internal([this._prefs]);

  /// Factory constructor to access singleton instance or inject custom SharedPreferences (useful for tests).
  factory StorageService({SharedPreferences? prefs}) {
    if (prefs != null) {
      return StorageService._internal(prefs);
    }
    _instance ??= StorageService._internal();
    return _instance!;
  }

  static const String _settingsKey = 'app_settings';
  static const String _progressKey = 'srs_progress_map';

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Saves the user configuration [AppSettings].
  Future<bool> saveSettings(AppSettings settings) async {
    final prefs = await _preferences;
    final jsonString = jsonEncode(settings.toJson());
    return await prefs.setString(_settingsKey, jsonString);
  }

  /// Loads the user configuration [AppSettings]. Returns default settings if not previously saved.
  Future<AppSettings> loadSettings() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_settingsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return const AppSettings();
    }
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return AppSettings.fromJson(jsonMap);
    } catch (_) {
      return const AppSettings();
    }
  }

  /// Saves the entire map of question IDs to [Progress] SRS records.
  Future<bool> saveProgressMap(Map<String, Progress> progressMap) async {
    final prefs = await _preferences;
    final Map<String, dynamic> serialized = progressMap.map(
      (key, progress) => MapEntry(key, progress.toJson()),
    );
    return await prefs.setString(_progressKey, jsonEncode(serialized));
  }

  /// Loads all saved SRS progress records keyed by question ID.
  Future<Map<String, Progress>> loadProgressMap() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_progressKey);
    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }
    try {
      final Map<String, dynamic> rawMap = jsonDecode(jsonString);
      final Map<String, Progress> resultMap = {};
      rawMap.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          resultMap[key] = Progress.fromJson(key, value);
        } else if (value is Map) {
          resultMap[key] = Progress.fromJson(key, Map<String, dynamic>.from(value));
        }
      });
      return resultMap;
    } catch (_) {
      return {};
    }
  }

  /// Saves or updates the SRS progress for a single question.
  Future<bool> saveProgress(Progress progress) async {
    final currentMap = await loadProgressMap();
    currentMap[progress.questionId] = progress;
    return await saveProgressMap(currentMap);
  }

  /// Retrieves SRS progress for a specific question ID, or null if none exists.
  Future<Progress?> getProgress(String questionId) async {
    final currentMap = await loadProgressMap();
    return currentMap[questionId];
  }

  /// Clears stored settings.
  Future<bool> clearSettings() async {
    final prefs = await _preferences;
    return await prefs.remove(_settingsKey);
  }

  /// Clears stored SRS progress.
  Future<bool> clearProgress() async {
    final prefs = await _preferences;
    return await prefs.remove(_progressKey);
  }

  /// Clears all settings and progress records.
  Future<bool> clearAll() async {
    final prefs = await _preferences;
    final s1 = await prefs.remove(_settingsKey);
    final s2 = await prefs.remove(_progressKey);
    return s1 && s2;
  }
}
