# System Patterns: DataCacheX

## Architecture Overview

DataCacheX follows a modular architecture with clear separation of concerns:

```
┌─────────────────┐
│   DataCacheX    │ <── Main API interface
└────────┬────────┘
         │
         │ delegates to
         ▼
┌─────────────────┐
│  Cache Adapter  │ <── Abstract adapter interface
└────────┬────────┘
         │
         │ implemented by
         ▼
┌─────────────────────────────────────────────┐
│                                             │
│  ┌─────────┐  ┌─────────┐  ┌─────────────┐  │
│  │  Hive   │  │ Memory  │  │    SQLite   │  │ <── Concrete adapters
│  │ Adapter │  │ Adapter │  │   Adapter   │  │
│  └─────────┘  └─────────┘  └─────────────┘  │
│                                             │
└─────────────────────────────────────────────┘
```

## Key Components

### 1. Core API (DataCacheX)
- Main entry point for client applications
- Provides methods for cache operations (put, get, delete, clear)
- Delegates actual storage to the configured adapter

### 2. Cache Adapters
- Abstract interface defining operations all adapters must implement
- Concrete implementations for different storage backends:
  - HiveAdapter: Uses Hive NoSQL database
  - MemoryAdapter: In-memory storage using Map
  - SQLiteAdapter: Uses SQLite database
  - SharedPreferencesAdapter: Uses SharedPreferences

### 3. Cache Items
- Model representing items stored in cache
- Contains value and optional expiry time
- Handles expiry logic

### 4. Data Serializers
- Convert complex data types to storable formats
- Abstract interface with implementations for different types
- JsonDataSerializer for default serialization

### 5. Service Locator
- Uses get_it for dependency injection
- Registers adapters, serializers, and other components
- Provides type adapter registry for Hive

### 6. Background Cleanup
- Periodic task for removing expired items
- Configurable cleanup frequency

## Key Technical Decisions

### 1. Adapter Pattern
DataCacheX uses the Adapter pattern to abstract away the details of different storage backends, allowing clients to use a consistent API regardless of the underlying storage mechanism.

### 2. Dependency Injection
The library uses get_it for dependency injection, making it easy to swap out different components (adapters, serializers) at runtime or for testing.

### 3. Type Safety
Despite Dart being dynamically typed, DataCacheX aims to provide type safety through:
- Generic methods (`put<T>`, `get<T>`)
- Type adapters for Hive
- Custom serializers for complex types

### 4. Serialization Strategy
- Simple types stored directly
- Complex types serialized to JSON or other formats
- Custom serializers can be registered for specific types

### 5. Error Handling
- Custom exception hierarchy for different error scenarios
- Clear error messages for debugging
- Graceful fallback mechanisms where appropriate

## Data Flow

1. **Storage Flow**:
   ```
   Client → DataCacheX.put() → CacheAdapter.put() → Storage Backend
   ```

2. **Retrieval Flow**:
   ```
   Client → DataCacheX.get() → CacheAdapter.get() → Storage Backend → Expiry Check → Client
   ```

3. **Cleanup Flow**:
   ```
   BackgroundCleanup → CacheAdapter.getAll() → Expiry Check → CacheAdapter.delete() → Storage Backend
   ``` 