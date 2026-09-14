class AppSettings {
  final int frequencyMinutes;
  final List<String> activeLanguages;
  final String difficulty;
  final bool fullScreenLock;

  const AppSettings({
    this.frequencyMinutes = 60,
    this.activeLanguages = const ['Python', 'Java'],
    this.difficulty = 'medium',
    this.fullScreenLock = true,
  });

  AppSettings copyWith({
    int? frequencyMinutes,
    List<String>? activeLanguages,
    String? difficulty,
    bool? fullScreenLock,
  }) {
    return AppSettings(
      frequencyMinutes: frequencyMinutes ?? this.frequencyMinutes,
      activeLanguages: activeLanguages ?? this.activeLanguages,
      difficulty: difficulty ?? this.difficulty,
      fullScreenLock: fullScreenLock ?? this.fullScreenLock,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      frequencyMinutes: json['frequencyMinutes'] as int? ?? 60,
      activeLanguages: (json['activeLanguages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Python', 'Java'],
      difficulty: json['difficulty'] as String? ?? 'medium',
      fullScreenLock: json['fullScreenLock'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequencyMinutes': frequencyMinutes,
      'activeLanguages': activeLanguages,
      'difficulty': difficulty,
      'fullScreenLock': fullScreenLock,
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
          _listEquals(activeLanguages, other.activeLanguages);

  @override
  int get hashCode =>
      frequencyMinutes.hashCode ^
      activeLanguages.fold(0, (prev, element) => prev ^ element.hashCode) ^
      difficulty.hashCode ^
      fullScreenLock.hashCode;

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
    return 'AppSettings(frequencyMinutes: $frequencyMinutes, activeLanguages: $activeLanguages, difficulty: $difficulty, fullScreenLock: $fullScreenLock)';
  }
}
