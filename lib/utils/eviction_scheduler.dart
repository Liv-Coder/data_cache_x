import 'dart:async';
import 'dart:math';

import 'package:data_cache_x/utils/cache_eviction.dart';
import 'package:logging/logging.dart';

/// Defines when the eviction should run.
enum EvictionTiming {
  /// Run eviction at regular intervals.
  periodic,

  /// Run eviction at specific times of day.
  scheduled,

  /// Run eviction when the app is idle.
  onIdle,

  /// Run eviction when the app is in the background.
  inBackground,

  /// Run eviction when the device is charging.
  whileCharging,

  /// Run eviction when the device is connected to Wi-Fi.
  onWifi,
}

/// A class that schedules cache eviction based on various conditions.
class EvictionScheduler {
  /// The logger instance.
  final _log = Logger('EvictionScheduler');

  // The cache instance is not directly used but is kept for reference
  // and potential future use.

  /// The eviction instance.
  final CacheEviction? _eviction;

  /// The timer for periodic eviction.
  Timer? _periodicTimer;

  /// The timer for scheduled eviction.
  Timer? _scheduledTimer;

  /// The stream subscription for idle detection.
  StreamSubscription? _idleSubscription;

  /// The stream subscription for background detection.
  StreamSubscription? _backgroundSubscription;

  /// The stream subscription for charging detection.
  StreamSubscription? _chargingSubscription;

  /// The stream subscription for connectivity detection.
  StreamSubscription? _connectivitySubscription;

  /// Whether the scheduler is running.
  bool _isRunning = false;

  /// The last time eviction was run.
  DateTime? _lastEvictionTime;

  /// The scheduled eviction times.
  final List<TimeOfDay> _scheduledTimes = [];

  /// The conditions that must be met for eviction to run.
  final Set<EvictionTiming> _conditions = {};

  /// The minimum interval between evictions.
  Duration _minInterval = Duration(minutes: 5);

  /// The jitter to add to scheduled times to avoid thundering herd.
  final Duration _jitter = Duration(minutes: 2);

  /// Creates a new instance of [EvictionScheduler].
  EvictionScheduler(dynamic cache) : _eviction = cache.eviction;

  /// Gets whether the scheduler is running.
  bool get isRunning => _isRunning;

  /// Gets the last time eviction was run.
  DateTime? get lastEvictionTime => _lastEvictionTime;

  /// Gets the scheduled eviction times.
  List<TimeOfDay> get scheduledTimes => List.unmodifiable(_scheduledTimes);

  /// Gets the conditions that must be met for eviction to run.
  Set<EvictionTiming> get conditions => Set.unmodifiable(_conditions);

  /// Schedules eviction to run periodically.
  ///
  /// The [frequency] parameter determines how often eviction should run.
  /// The [minInterval] parameter sets a minimum time between evictions to prevent
  /// excessive cleanup operations.
  void schedulePeriodic(Duration frequency, {Duration? minInterval}) {
    if (_isRunning) {
      _log.warning('Scheduler is already running. Stop it first.');
      return;
    }

    if (frequency < Duration(minutes: 1)) {
      _log.warning('Frequency is too short. Setting to 1 minute.');
      frequency = Duration(minutes: 1);
    }

    if (minInterval != null) {
      _minInterval = minInterval;
    }

    _conditions.add(EvictionTiming.periodic);
    _periodicTimer = Timer.periodic(frequency, (_) => _checkAndEvict());
    _isRunning = true;
    _log.info(
        'Scheduled periodic eviction every ${frequency.inMinutes} minutes');
  }

  /// Schedules eviction to run at specific times of day.
  ///
  /// The [times] parameter is a list of times when eviction should run.
  void scheduleAtTimes(List<TimeOfDay> times) {
    if (_isRunning) {
      _log.warning('Scheduler is already running. Stop it first.');
      return;
    }

    if (times.isEmpty) {
      _log.warning('No times provided. Scheduling will not be effective.');
      return;
    }

    _scheduledTimes.clear();
    _scheduledTimes.addAll(times);
    _conditions.add(EvictionTiming.scheduled);
    _scheduleNextEviction();
    _isRunning = true;
    _log.info(
        'Scheduled eviction at specific times: ${times.map((t) => '${t.hour}:${t.minute}').join(', ')}');
  }

  /// Schedules eviction to run when the app is idle.
  ///
  /// This requires integration with a platform-specific idle detection mechanism.
  void scheduleOnIdle() {
    if (_isRunning) {
      _log.warning('Scheduler is already running. Stop it first.');
      return;
    }

    _conditions.add(EvictionTiming.onIdle);
    // This would typically involve setting up a listener for app idle events
    // For now, we'll just log a message
    _log.info('Scheduled eviction when app is idle (not implemented)');
    _isRunning = true;
  }

  /// Schedules eviction to run when the app is in the background.
  ///
  /// This requires integration with a platform-specific background detection mechanism.
  void scheduleInBackground() {
    if (_isRunning) {
      _log.warning('Scheduler is already running. Stop it first.');
      return;
    }

    _conditions.add(EvictionTiming.inBackground);
    // This would typically involve setting up a listener for app lifecycle events
    // For now, we'll just log a message
    _log.info('Scheduled eviction when app is in background (not implemented)');
    _isRunning = true;
  }

  /// Schedules eviction to run when the device is charging.
  ///
  /// This requires integration with a platform-specific charging detection mechanism.
  void scheduleWhileCharging() {
    if (_isRunning) {
      _log.warning('Scheduler is already running. Stop it first.');
      return;
    }

    _conditions.add(EvictionTiming.whileCharging);
    // This would typically involve setting up a listener for charging events
    // For now, we'll just log a message
    _log.info('Scheduled eviction when device is charging (not implemented)');
    _isRunning = true;
  }

  /// Schedules eviction to run when the device is connected to Wi-Fi.
  ///
  /// This requires integration with a platform-specific connectivity detection mechanism.
  void scheduleOnWifi() {
    if (_isRunning) {
      _log.warning('Scheduler is already running. Stop it first.');
      return;
    }

    _conditions.add(EvictionTiming.onWifi);
    // This would typically involve setting up a listener for connectivity events
    // For now, we'll just log a message
    _log.info('Scheduled eviction when device is on Wi-Fi (not implemented)');
    _isRunning = true;
  }

  /// Stops the scheduler.
  void stop() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _scheduledTimer?.cancel();
    _scheduledTimer = null;
    _idleSubscription?.cancel();
    _idleSubscription = null;
    _backgroundSubscription?.cancel();
    _backgroundSubscription = null;
    _chargingSubscription?.cancel();
    _chargingSubscription = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _isRunning = false;
    _log.info('Eviction scheduler stopped');
  }

  /// Runs eviction immediately, regardless of conditions.
  Future<void> evictNow() async {
    if (_eviction == null) {
      _log.warning('No eviction strategy available');
      return;
    }

    try {
      _log.info('Running eviction now');
      await _eviction.checkAndEvict();
      _lastEvictionTime = DateTime.now();
      _log.info('Eviction completed');
    } catch (e) {
      _log.severe('Error during eviction: $e');
    }
  }

  /// Checks if eviction should run and runs it if conditions are met.
  Future<void> _checkAndEvict() async {
    if (_eviction == null) {
      _log.warning('No eviction strategy available');
      return;
    }

    // Check if minimum interval has elapsed
    if (_lastEvictionTime != null) {
      final elapsed = DateTime.now().difference(_lastEvictionTime!);
      if (elapsed < _minInterval) {
        _log.fine('Skipping eviction, minimum interval not elapsed');
        return;
      }
    }

    try {
      _log.fine('Running scheduled eviction');
      await _eviction.checkAndEvict();
      _lastEvictionTime = DateTime.now();
      _log.fine('Scheduled eviction completed');
    } catch (e) {
      _log.severe('Error during scheduled eviction: $e');
    }
  }

  /// Schedules the next eviction based on the scheduled times.
  void _scheduleNextEviction() {
    if (_scheduledTimes.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final currentTimeOfDay = TimeOfDay(hour: now.hour, minute: now.minute);

    // Find the next scheduled time
    TimeOfDay? nextTime;
    for (final time in _scheduledTimes) {
      if (_isTimeAfter(time, currentTimeOfDay)) {
        if (nextTime == null || _isTimeBefore(time, nextTime)) {
          nextTime = time;
        }
      }
    }

    // If no time is found for today, use the first time for tomorrow
    nextTime ??= _scheduledTimes.reduce((a, b) => _isTimeBefore(a, b) ? a : b);

    // Calculate the delay until the next scheduled time
    final nextDateTime = _timeOfDayToDateTime(nextTime, now);
    final delay = nextDateTime.difference(now);

    // Add some jitter to avoid thundering herd
    final random = Random();
    final jitterMillis = random.nextInt(_jitter.inMilliseconds);
    final jitteredDelay = delay + Duration(milliseconds: jitterMillis);

    // Schedule the next eviction
    _scheduledTimer?.cancel();
    _scheduledTimer = Timer(jitteredDelay, () {
      _checkAndEvict();
      _scheduleNextEviction(); // Schedule the next one
    });

    _log.fine(
        'Next eviction scheduled at ${nextTime.hour}:${nextTime.minute} (in ${jitteredDelay.inMinutes} minutes)');
  }

  /// Converts a [TimeOfDay] to a [DateTime] on the given day.
  DateTime _timeOfDayToDateTime(TimeOfDay time, DateTime day) {
    return DateTime(
      day.year,
      day.month,
      day.day,
      time.hour,
      time.minute,
    );
  }

  /// Checks if [time1] is before [time2].
  bool _isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) {
      return true;
    }
    if (time1.hour > time2.hour) {
      return false;
    }
    return time1.minute < time2.minute;
  }

  /// Checks if [time1] is after [time2].
  bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour > time2.hour) {
      return true;
    }
    if (time1.hour < time2.hour) {
      return false;
    }
    return time1.minute > time2.minute;
  }

  /// Disposes the scheduler.
  void dispose() {
    stop();
  }
}

/// Represents a time of day.
class TimeOfDay {
  /// The hour of the day (0-23).
  final int hour;

  /// The minute of the hour (0-59).
  final int minute;

  /// Creates a new instance of [TimeOfDay].
  TimeOfDay({
    required this.hour,
    required this.minute,
  })  : assert(hour >= 0 && hour < 24),
        assert(minute >= 0 && minute < 60);

  @override
  String toString() => '$hour:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeOfDay && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}
