# Changelog

## 1.0.0 (Unreleased)

- Implemented comprehensive tag-based cache management system
  - Added support for tagging cache items with multiple labels
  - Implemented methods for retrieving items by tag or tag combinations
  - Added support for tag-based operations (getByTag, deleteByTag)
  - Enhanced models to include tag fields and serialization support
- Added batch operations for improved performance
  - Implemented putAll, getAll, and deleteAll methods
  - Added BatchProcessData model for tracking batch operations
  - Optimized batch operations in all adapters
  - Added benchmarking tools for comparing standard vs batch operations
- Implemented advanced cache synchronization
  - Added SyncRepository for managing sync operations
  - Created SyncBloc for handling sync state management
  - Developed SyncPage UI for displaying sync status and controls
  - Integrated sync feature with main app navigation
- Enhanced eviction scheduling capabilities
  - Added ScheduleType enum (periodic, scheduled, onIdle, inBackground)
  - Implemented time-based scheduling for cache cleanup
  - Added UI controls for configuring scheduled eviction times
  - Enhanced CacheSettings model with eviction scheduling properties
- Enhanced example app with new features
  - Added tag support to Image Gallery feature
    - Updated GalleryImage model with tags field
    - Implemented tag filtering and management in UI
    - Added tag visualization on image cards
  - Added tag support to News Feed feature
    - Updated Article model with tags field
    - Implemented cross-category content discovery through tags
    - Added tag filtering interface
  - Enhanced Playground feature with batch operation benchmarking
    - Added UI controls for selecting and running batch benchmarks
    - Implemented visual comparison of standard vs batch performance
  - Added Settings feature with eviction scheduling configuration
    - Created UI for configuring scheduled eviction times
    - Implemented time picker for precise scheduling
  - Enhanced repositories with tag-based operations
  - Updated BLoCs to handle tag-related events and states
- Improved documentation with usage examples for all new features

## 0.1.5

- Added comprehensive analytics for cache performance monitoring
- Implemented multiple eviction strategies (LRU, LFU, FIFO, TTL)
- Added support for data compression with configurable compression levels
- Introduced cache policies for fine-grained control over caching behavior
- Enhanced background cleanup with configurable frequency
- Added support for sliding expiry that extends item lifetime on access
- Implemented priority-based cache management
- Fixed type error in CacheItemAdapter for List\<String\> handling
- Improved error handling and logging
- Enhanced example app with more demonstrations

## 0.1.4

- Introduced configurable options for `Hive` box name and `background` cleanup frequency
- Improved type safety by using generics for `CacheItem` and a type registry for `HiveAdapter`
- Made `setupDataCacheX` asynchronous to handle potential initialization delays
- Enhanced error handling in background cleanup with logging
- Added support for multiple cache adapters, including an in-memory option
- Implemented sliding expiration, cache invalidation by key or custom condition, and data encryption
- Exposed metrics for cache usage, including hit count, miss count, and hit rate
- Implemented custom object serialization using `DataSerializer` and `JsonDataSerializer`
- Introduced custom exceptions for better error handling in `TypeAdapterRegistry`
- Enhanced `setupDataCacheX` and `BackgroundCleanup` to be more configurable, allowing custom adapters and serializers
- Improved encryption in `MemoryAdapter` by using AES encryption with a configurable key
- The encryption key for both `MemoryAdapter` and `HiveAdapter` is now configurable
- Added support for more storage adapters, including `SQLite` and `shared preferences`
- Implemented a more robust background cleanup mechanism that processes cache items in batches

## 0.1.3+1

- Included Readme.md

## 0.1.3

- Migrated storage backend to Hive database for better performance
- Added update operation for modifying existing data
- Improved data persistence and reliability
- Enhanced error handling for database operations

## 0.1.2

- Implemented data expiry feature
- Added support for setting TTL (Time To Live) on cached data
- Added automatic cleanup of expired data
- Added example todo app demonstrating all features

## 0.1.0

- Initial release with basic functionality
- Added simple get operation to retrieve data
- Added save operation to store data
- Added delete operation to remove data
