class AppSettings {
  final int frequencyMinutes;
  final List<String> activeLanguages;
  final String difficulty;
  final bool fullScreenLock;
  final Map<String, List<String>> activeSubtopics;
  final Map<String, String> topicDifficulties;
  final bool hapticsEnabled;
  final bool soundEnabled;
  final bool quietHoursEnabled;
  final int quietStartHour;
  final int quietEndHour;

  const AppSettings({
    this.frequencyMinutes = 60,
    this.activeLanguages = const ['Python', 'Java'],
    this.difficulty = 'medium',
    this.fullScreenLock = true,
    this.activeSubtopics = const {},
    this.topicDifficulties = const {},
    this.hapticsEnabled = true,
    this.soundEnabled = true,
    this.quietHoursEnabled = false,
    this.quietStartHour = 22,
    this.quietEndHour = 8,
  });

  AppSettings copyWith({
    int? frequencyMinutes,
    List<String>? activeLanguages,
    String? difficulty,
    bool? fullScreenLock,
    Map<String, List<String>>? activeSubtopics,
    Map<String, String>? topicDifficulties,
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? quietHoursEnabled,
    int? quietStartHour,
    int? quietEndHour,
  }) {
    return AppSettings(
      frequencyMinutes: frequencyMinutes ?? this.frequencyMinutes,
      activeLanguages: activeLanguages ?? this.activeLanguages,
      difficulty: difficulty ?? this.difficulty,
      fullScreenLock: fullScreenLock ?? this.fullScreenLock,
      activeSubtopics: activeSubtopics ?? this.activeSubtopics,
      topicDifficulties: topicDifficulties ?? this.topicDifficulties,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietEndHour: quietEndHour ?? this.quietEndHour,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> subtopics = {};
    if (json['activeSubtopics'] != null && json['activeSubtopics'] is Map) {
      final rawMap = json['activeSubtopics'] as Map;
      rawMap.forEach((key, value) {
        if (value is List) {
          subtopics[key.toString().toLowerCase()] =
              value.map((e) => e.toString().toLowerCase()).toList();
        }
      });
    }

    Map<String, String> diffs = {};
    if (json['topicDifficulties'] != null && json['topicDifficulties'] is Map) {
      final rawMap = json['topicDifficulties'] as Map;
      rawMap.forEach((key, value) {
        diffs[key.toString().toLowerCase()] = value.toString().toLowerCase();
      });
    }

    return AppSettings(
      frequencyMinutes: json['frequencyMinutes'] as int? ?? 60,
      activeLanguages: (json['activeLanguages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Python', 'Java'],
      difficulty: json['difficulty'] as String? ?? 'medium',
      fullScreenLock: json['fullScreenLock'] as bool? ?? true,
      activeSubtopics: subtopics,
      topicDifficulties: diffs,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? false,
      quietStartHour: json['quietStartHour'] as int? ?? 22,
      quietEndHour: json['quietEndHour'] as int? ?? 8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequencyMinutes': frequencyMinutes,
      'activeLanguages': activeLanguages,
      'difficulty': difficulty,
      'fullScreenLock': fullScreenLock,
      'activeSubtopics': activeSubtopics,
      'topicDifficulties': topicDifficulties,
      'hapticsEnabled': hapticsEnabled,
      'soundEnabled': soundEnabled,
      'quietHoursEnabled': quietHoursEnabled,
      'quietStartHour': quietStartHour,
      'quietEndHour': quietEndHour,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          frequencyMinutes == other.frequencyMinutes &&
          difficulty == other.difficulty &&
          fullScreenLock == other.fullScreenLock &&
          hapticsEnabled == other.hapticsEnabled &&
          soundEnabled == other.soundEnabled &&
          quietHoursEnabled == other.quietHoursEnabled &&
          quietStartHour == other.quietStartHour &&
          quietEndHour == other.quietEndHour &&
          _listEquals(activeLanguages, other.activeLanguages);

  @override
  int get hashCode =>
      frequencyMinutes.hashCode ^
      activeLanguages.fold(0, (prev, element) => prev ^ element.hashCode) ^
      difficulty.hashCode ^
      fullScreenLock.hashCode ^
      activeSubtopics.hashCode ^
      topicDifficulties.hashCode ^
      hapticsEnabled.hashCode ^
      soundEnabled.hashCode ^
      quietHoursEnabled.hashCode ^
      quietStartHour.hashCode ^
      quietEndHour.hashCode;

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'AppSettings(frequencyMinutes: $frequencyMinutes, activeLanguages: $activeLanguages, topicDifficulties: $topicDifficulties, fullScreenLock: $fullScreenLock, activeSubtopics: $activeSubtopics)';
  }
}

