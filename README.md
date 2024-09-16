# DataCacheX

DataCacheX is a Dart package designed to simplify offline data caching and synchronization for Flutter applications. It provides a robust solution for caching API data and other resources, with automatic synchronization when the app reconnects to the internet.

## Features

- **Basic API Data Caching**: Cache API responses for offline access.
- **Persistent Storage**: Use SQLite for persistent data storage.
- **Configurable Caching Strategies**: Time-based, version-based, and more.
- **Automatic Background Sync**: Sync data automatically when online.
- **Support for JSON, Images, and Files**: Cache various data types.
- **Conflict Resolution**: Basic and advanced strategies.
- **Encryption**: Secure sensitive data in the cache.
- **Performance Analytics**: Monitor cache performance and usage.

## Getting Started

### Prerequisites

- Dart SDK
- Flutter SDK

### Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  data_cache_x: ^0.1.0
```
