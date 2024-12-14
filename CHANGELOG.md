## 0.1.0

- Initial release with basic functionality
- Added simple get operation to retrieve data
- Added save operation to store data
- Added delete operation to remove data

## 0.1.2

- Implemented data expiry feature
- Added support for setting TTL (Time To Live) on cached data
- Added automatic cleanup of expired data
- Added example todo app demonstrating all features

## 0.1.3

- Migrated storage backend to Hive database for better performance
- Added update operation for modifying existing data
- Improved data persistence and reliability
- Enhanced error handling for database operations

## 0.1.3+1

- Included Readme.md

## 0.1.4

- Added configuration options for `Hive box name` and `background cleanup` frequency.
- Improved type safety by making `CacheItem` generic.
- Ensured type safety in `HiveAdapter` using a type registry.
- Made the `setupDataCacheX` function asynchronous to handle potential delays in initializing Hive.
- Improved error handling in `background cleanup` by logging errors.
- Added support for `multiple cache adapters`, including an `in-memory` adapter.
- Users can now choose between `Hive` and `in-memory storage`.
- Implemented `sliding expiration`, resetting the `expiry time` on each access.
- Implemented `cache invalidation` feature.
- Added methods to `invalidate cache` entries by `key` or by a `custom condition`.
- Added an option to encrypt sensitive data stored in the cache.
- Users can now enable encryption for both Hive and in-memory adapters.
- Exposed metrics for cache usage, including hit count, miss count, and hit rate, to help users monitor the cache's performance.
- Implemented custom object serialization using `DataSerializer` and `JsonDataSerializer`.
- Introduced custom exceptions for better error handling in `TypeAdapterRegistry`, providing more specific error information.
- Enhanced the `setupDataCacheX` function to be more configurable, allowing users to register their own custom adapters and serializers.
- Made `BackgroundCleanup` more configurable by allowing users to specify the `CacheAdapter` to use for cleanup.
- Clarified the usage of `enableEncryption` in `MemoryAdapter`, which uses a simple XOR encryption.
- Refactored `_CacheItemAdapter` to be a generic class, and updated `setupDataCacheX` to register it correctly, resolving code duplication issues.
