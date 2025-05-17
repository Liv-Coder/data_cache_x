# Advanced Eviction Scheduling

## Overview

Advanced eviction scheduling gives you fine-grained control over when and how cache cleanup happens. This is useful for:

- Optimizing cache performance by scheduling cleanup during idle times
- Reducing battery usage by scheduling cleanup when the device is charging
- Minimizing user impact by scheduling cleanup during off-peak hours
- Implementing custom cleanup strategies based on your application's needs

## Basic Usage

### Creating an Eviction Scheduler

```dart
import 'package:data_cache_x/data_cache_x.dart';

// Create a cache instance
final cache = DataCacheX(...);

// Create an eviction scheduler
final scheduler = EvictionScheduler(cache);
```

### Periodic Scheduling

To schedule eviction to run at regular intervals:

```dart
// Run eviction every 30 minutes
scheduler.schedulePeriodic(Duration(minutes: 30));
```

### Scheduled Times

To schedule eviction to run at specific times of day:

```dart
// Run eviction at 3:00 AM and 3:00 PM
scheduler.scheduleAtTimes([
  TimeOfDay(hour: 3, minute: 0),
  TimeOfDay(hour: 15, minute: 0),
]);
```

### Manual Eviction

To run eviction immediately:

```dart
// Run eviction now
await scheduler.evictNow();
```

### Stopping the Scheduler

To stop all scheduled evictions:

```dart
// Stop the scheduler
scheduler.stop();
```

## Advanced Usage

### Minimum Interval

You can set a minimum interval between evictions to prevent excessive cleanup operations:

```dart
// Run eviction every hour, but ensure at least 15 minutes between runs
scheduler.schedulePeriodic(
  Duration(hours: 1),
  minInterval: Duration(minutes: 15),
);
```

### Conditional Scheduling

The `EvictionScheduler` supports various conditions for when eviction should run:

```dart
// Run eviction when the app is idle
scheduler.scheduleOnIdle();

// Run eviction when the app is in the background
scheduler.scheduleInBackground();

// Run eviction when the device is charging
scheduler.scheduleWhileCharging();

// Run eviction when the device is connected to Wi-Fi
scheduler.scheduleOnWifi();
```

Note: Some of these conditions require platform-specific integration. See the "Platform Integration" section below for details.

### Monitoring Eviction

You can monitor when eviction was last run:

```dart
// Get the last time eviction was run
final lastEvictionTime = scheduler.lastEvictionTime;

if (lastEvictionTime != null) {
  final elapsed = DateTime.now().difference(lastEvictionTime);
  print('Last eviction was $elapsed ago');
}
```

## Implementation Details

### Eviction Process

The eviction process works as follows:

1. Check if the minimum interval has elapsed since the last eviction
2. Check if all required conditions are met
3. Run the eviction strategy (LRU, LFU, FIFO, or TTL)
4. Update the last eviction time

### Scheduled Times with Jitter

When scheduling eviction at specific times, a small random jitter is added to prevent all instances from running at exactly the same time (the "thundering herd" problem). This is especially important for server applications or applications with many instances.

### Condition Checking

The scheduler checks all conditions before running eviction. If any condition is not met, eviction will not run. This allows you to combine multiple conditions, such as "run every hour, but only when the device is charging and connected to Wi-Fi."

## Platform Integration

### Idle Detection

To integrate with platform-specific idle detection:

```dart
// Android example using WorkManager
void setupIdleDetection(EvictionScheduler scheduler) {
  // Set up WorkManager to run when the device is idle
  // This is a simplified example - actual implementation will vary
  final workManager = WorkManager.instance;
  workManager.enqueue(
    OneTimeWorkRequest.Builder()
      .setConstraints(Constraints.Builder()
        .setRequiresDeviceIdle(true)
        .build())
      .build(),
  );
  
  // When the work is executed, run eviction
  workManager.getWorkInfoByIdLiveData(workId).observe((workInfo) {
    if (workInfo.state == WorkInfo.State.SUCCEEDED) {
      scheduler.evictNow();
    }
  });
}
```

### Background Detection

To integrate with platform-specific background detection:

```dart
// Flutter example using AppLifecycleState
void setupBackgroundDetection(EvictionScheduler scheduler) {
  WidgetsBinding.instance.addObserver(AppLifecycleObserver(
    onBackground: () {
      scheduler.evictNow();
    },
  ));
}

class AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onBackground;
  
  AppLifecycleObserver({required this.onBackground});
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      onBackground();
    }
  }
}
```

## Example: Battery-Friendly Cleanup

Here's an example of implementing a battery-friendly cleanup strategy:

```dart
class BatteryFriendlyCache {
  final DataCacheX cache;
  final EvictionScheduler scheduler;

  BatteryFriendlyCache({
    required this.cache,
  }) : scheduler = EvictionScheduler(cache);

  // Set up battery-friendly cleanup
  void setupCleanup() {
    // Run every 2 hours
    scheduler.schedulePeriodic(Duration(hours: 2));
    
    // Also run when device is charging
    scheduler.scheduleWhileCharging();
    
    // Also run at 3:00 AM when the user is likely sleeping
    scheduler.scheduleAtTimes([
      TimeOfDay(hour: 3, minute: 0),
    ]);
  }
}
```

## Cleaning Up

Don't forget to dispose the scheduler when you're done with it:

```dart
// Dispose the scheduler
scheduler.dispose();
```

This will cancel all timers and subscriptions, preventing memory leaks.
