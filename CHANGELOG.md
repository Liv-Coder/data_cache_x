# Changelog

## 0.1.6 (Upcoming)

- Added enhanced encryption support with AES-256
- Implemented secure key storage with flutter_secure_storage
- Added key derivation from passwords using PBKDF2
- Introduced tag-based cache management for selective invalidation
- Added methods to retrieve, delete, and manage cache items by tags
- Enhanced security with configurable encryption options
- Improved encryption key management with secure random key generation
- Updated all adapters to support the new encryption and tagging features

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
