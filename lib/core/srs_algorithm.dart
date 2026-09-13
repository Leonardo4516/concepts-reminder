import '../models/progress.dart';

class SrsAlgorithm {
  /// SuperMemo-2 Implementation
  /// Quality: 0 to 5 (0 = blackout, 5 = perfect)
  static void updateProgress(Progress progress, bool correct) {
    int quality = correct ? 4 : 1;

    if (quality >= 3) {
      if (progress.repetitions == 0) {
        progress.intervalDays = 1;
      } else if (progress.repetitions == 1) {
        progress.intervalDays = 6;
      } else {
        progress.intervalDays = (progress.intervalDays * progress.easeFactor).round();
      }
      progress.repetitions++;
    } else {
      progress.repetitions = 0;
      progress.intervalDays = 1;
    }

    progress.easeFactor = progress.easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (progress.easeFactor < 1.3) {
      progress.easeFactor = 1.3;
    }

    progress.nextReview = DateTime.now().add(Duration(days: progress.intervalDays));
  }
}
