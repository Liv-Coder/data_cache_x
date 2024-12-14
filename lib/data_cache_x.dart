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
/// - **Models**: Contains the `CacheItem` class, which represents a single item in the cache.
///   - `CacheItem`: A class that encapsulates the data to be stored in the cache, along with its optional expiry time.
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

// Models
export 'package:data_cache_x/models/cache_item.dart';

// Serializers
// export 'package:data_cache_x/src/serializers/data_serializer.dart';

// Utils
export 'package:data_cache_x/utils/background_cleanup.dart';

// Service Locator
export 'package:data_cache_x/service_locator.dart';
