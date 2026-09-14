import 'dart:async';
import 'package:flutter/foundation.dart';

/// Scheduler responsible for triggering concept reminder questions at regular intervals.
class ReminderScheduler {
  static final ReminderScheduler _instance = ReminderScheduler._internal();

  /// Factory constructor returning the singleton instance.
  factory ReminderScheduler() => _instance;

  ReminderScheduler._internal();

  Timer? _timer;
  int _frequencyMinutes = 60;
  Duration? _overrideInterval;
  bool _isRunning = false;

  /// Optional callback executed when a reminder is triggered.
  void Function()? onTrigger;

  final StreamController<DateTime> _reminderStreamController =
      StreamController<DateTime>.broadcast();

  /// Stream emitting timestamps whenever a reminder should be shown.
  Stream<DateTime> get onReminder => _reminderStreamController.stream;

  /// Notifier keeping track of total reminder triggers fired.
  final ValueNotifier<int> triggerCountNotifier = ValueNotifier<int>(0);

  /// Notifier containing the timestamp of the last triggered reminder.
  final ValueNotifier<DateTime?> lastTriggerNotifier = ValueNotifier<DateTime?>(null);

  /// Whether the scheduler is currently active.
  bool get isRunning => _isRunning;

  /// Configured frequency in minutes.
  int get frequencyMinutes => _frequencyMinutes;

  /// Active interval duration between triggers.
  Duration get activeInterval => _overrideInterval ?? Duration(minutes: _frequencyMinutes);

  /// Starts or restarts the periodic reminder timer.
  ///
  /// [frequencyMinutes] sets the interval in minutes.
  /// [customInterval] can be provided to override the interval (especially useful for testing or fine-grained timers).
  /// [onTriggerCallback] sets or updates the callback executed on trigger.
  void start({
    int? frequencyMinutes,
    Duration? customInterval,
    void Function()? onTriggerCallback,
  }) {
    if (frequencyMinutes != null && frequencyMinutes > 0) {
      _frequencyMinutes = frequencyMinutes;
    }
    if (customInterval != null) {
      _overrideInterval = customInterval;
    }
    if (onTriggerCallback != null) {
      onTrigger = onTriggerCallback;
    }

    // Cancel any existing running timer before starting
    stop();

    _isRunning = true;
    _timer = Timer.periodic(activeInterval, (_) {
      _fireTrigger();
    });
  }

  /// Stops the active timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  /// Updates the reminder frequency.
  /// If the scheduler is currently running, restarts the timer with the updated interval.
  void updateFrequency(int newFrequencyMinutes, {Duration? customInterval}) {
    if (newFrequencyMinutes > 0) {
      _frequencyMinutes = newFrequencyMinutes;
    }
    _overrideInterval = customInterval;

    if (_isRunning) {
      start();
    }
  }

  /// Manually triggers a reminder immediately without resetting the timer interval.
  void triggerNow() {
    _fireTrigger();
  }

  void _fireTrigger() {
    final now = DateTime.now();
    triggerCountNotifier.value++;
    lastTriggerNotifier.value = now;
    _reminderStreamController.add(now);
    onTrigger?.call();
  }

  /// Disposes internal controllers and notifiers.
  void dispose() {
    stop();
    _reminderStreamController.close();
    triggerCountNotifier.dispose();
    lastTriggerNotifier.dispose();
  }
}
