/// `data_cache_x` is a versatile caching library for Dart and Flutter applications.
/// It provides a flexible and extensible way to store and retrieve data, with support for different storage adapters.
///
/// This library serves as the main entry point for `data_cache_x`, exporting the core classes and interfaces
/// that make up the public API.
///
/// The library is organized into several modules:
///
/// - **Core**: Contains the core `DataCacheX` class and custom exceptions.
///   - `DataCacheX`: The primary class for interacting with the cache. It provides methods for storing, retrieving, and deleting data.
///   - `CacheException`: The base class for all custom exceptions thrown by the library.
/// - **Adapters**: Defines the `CacheAdapter` interface and provides concrete implementations for different storage mechanisms.
///   - `CacheAdapter`: An abstract class that defines the interface for cache adapters.
///   - `HiveAdapter`: A concrete implementation of `CacheAdapter` that uses the Hive NoSQL database for storage.
///   - `MemoryAdapter`: A concrete implementation of `CacheAdapter` that uses an in-memory map for storage.
/// - **Models**: Contains the `CacheItem` and `CachePolicy` classes.
///   - `CacheItem`: A class that encapsulates the data to be stored in the cache, along with its optional expiry time.
///   - `CachePolicy`: A class that defines the caching policy for an item, including settings such as expiry time, priority, and refresh strategy.
///
/// - **Analytics**: Contains the `CacheAnalytics` class for tracking cache performance.
///   - `CacheAnalytics`: A class that tracks and provides analytics for cache operations.
///
/// - **Utils**: Contains utility classes for cache management.
///   - `CacheEviction`: A class that handles cache eviction strategies like LRU, LFU, FIFO, and TTL.
///   - `Compression`: A class that provides compression and decompression functionality.
/// - **Utils**: Provides utility functions for tasks such as background cleanup.
///   - `BackgroundCleanup`: A utility class that handles the background cleanup of expired cache items.
/// - **Service Locator**: Sets up dependency injection using the `get_it` package.
///   - `setupDataCacheX`: A function that initializes the library and registers the necessary dependencies with `get_it`.
library;

// Core
export 'package:data_cache_x/core/data_cache_x.dart';
export 'package:data_cache_x/core/exception.dart';

// Adapters
export 'package:data_cache_x/adapters/cache_adapter.dart';
export 'package:data_cache_x/adapters/hive/hive_adapter.dart';
export 'package:data_cache_x/adapters/memory_adapter.dart';

// Models
export 'package:data_cache_x/models/cache_item.dart';
export 'package:data_cache_x/models/cache_policy.dart';

// Analytics
export 'package:data_cache_x/analytics/cache_analytics.dart';

// Utils
export 'package:data_cache_x/utils/cache_eviction.dart';
export 'package:data_cache_x/utils/compression.dart';

// Serializers
export 'package:data_cache_x/serializers/data_serializer.dart';

// Utils
export 'package:data_cache_x/utils/background_cleanup.dart';
export 'package:data_cache_x/utils/time_helper.dart';
