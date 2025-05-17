import 'package:data_cache_x/adapters/memory_adapter.dart';
import 'package:data_cache_x/core/data_cache_x.dart';
import 'package:data_cache_x/models/cache_policy.dart';
import 'package:data_cache_x/utils/eviction_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DataCacheX cache;
  late EvictionScheduler scheduler;

  setUp(() async {
    cache = DataCacheX(
      MemoryAdapter(),
      maxItems: 100,
      evictionStrategy: EvictionStrategy.lru,
    );
    
    scheduler = EvictionScheduler(cache);
  });

  tearDown(() {
    scheduler.dispose();
  });

  group('EvictionScheduler', () {
    test('evictNow runs eviction immediately', () async {
      // Setup: Add data to cache
      for (int i = 0; i < 50; i++) {
        await cache.put('key$i', 'value$i');
      }
      
      // Act: Run eviction now
      await scheduler.evictNow();
      
      // Assert: Eviction should have run (no way to verify directly, but we can check lastEvictionTime)
      expect(scheduler.lastEvictionTime, isNotNull);
    });

    test('schedulePeriodic sets up periodic eviction', () async {
      // Act: Schedule periodic eviction
      scheduler.schedulePeriodic(Duration(minutes: 1));
      
      // Assert: Scheduler should be running
      expect(scheduler.isRunning, isTrue);
      expect(scheduler.conditions.contains(EvictionTiming.periodic), isTrue);
      
      // Cleanup
      scheduler.stop();
      expect(scheduler.isRunning, isFalse);
    });

    test('scheduleAtTimes sets up scheduled eviction', () async {
      // Setup: Create times
      final times = [
        TimeOfDay(hour: 12, minute: 0),
        TimeOfDay(hour: 18, minute: 0),
      ];
      
      // Act: Schedule at specific times
      scheduler.scheduleAtTimes(times);
      
      // Assert: Scheduler should be running
      expect(scheduler.isRunning, isTrue);
      expect(scheduler.conditions.contains(EvictionTiming.scheduled), isTrue);
      expect(scheduler.scheduledTimes, equals(times));
      
      // Cleanup
      scheduler.stop();
      expect(scheduler.isRunning, isFalse);
    });

    test('stop cancels all scheduled evictions', () async {
      // Setup: Schedule periodic eviction
      scheduler.schedulePeriodic(Duration(minutes: 1));
      expect(scheduler.isRunning, isTrue);
      
      // Act: Stop the scheduler
      scheduler.stop();
      
      // Assert: Scheduler should not be running
      expect(scheduler.isRunning, isFalse);
    });

    test('TimeOfDay equality works correctly', () {
      // Setup: Create times
      final time1 = TimeOfDay(hour: 12, minute: 0);
      final time2 = TimeOfDay(hour: 12, minute: 0);
      final time3 = TimeOfDay(hour: 18, minute: 0);
      
      // Assert: Equal times should be equal
      expect(time1, equals(time2));
      expect(time1.hashCode, equals(time2.hashCode));
      
      // Assert: Different times should not be equal
      expect(time1, isNot(equals(time3)));
      expect(time1.hashCode, isNot(equals(time3.hashCode)));
    });

    test('TimeOfDay toString formats correctly', () {
      // Setup: Create times
      final time1 = TimeOfDay(hour: 12, minute: 0);
      final time2 = TimeOfDay(hour: 9, minute: 5);
      
      // Assert: toString should format correctly
      expect(time1.toString(), equals('12:00'));
      expect(time2.toString(), equals('9:05'));
    });
  });
}
