# DataCacheX

[![pub package](https://img.shields.io/pub/v/your_package_name.svg)](https://pub.dev/packages/data_cache_x)

A Flutter package for efficient API caching, built with Clean Architecture principles. This package provides a simple and robust way to cache API responses locally, improving the performance and user experience of your Flutter applications.

## Features

- **Local Caching**: Store API responses locally using `SharedPreferences` for quick access.
- **Clean Architecture**: Organized code structure that separates concerns into data, domain, and presentation layers.
- **Easy to Use**: Simple API for caching and retrieving data.
- **Robust Error Handling**: Built-in error handling to manage caching operations.
- **Extensible**: Easily extendable for additional features like cache expiration or different storage solutions.

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  data_cache_x: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Import the Package

```dart
import 'package:data_cache_x/data_cache_x.dart';
```

### Initialize the Cache Manager

Create an instance of the `CacheManager`:

```dart
final cacheManager = CacheManager(CacheRepository(LocalDataSource()));
```

### Caching Data

To cache data, use the `cacheData` method:

```dart
await cacheManager.cacheData('your_key', 'your_data');
```

### Retrieving Cached Data

To retrieve cached data, use the `getCachedData` method:

```dart
String? cachedData = await cacheManager.getCachedData('your_key');
if (cachedData != null) {
  print('Cached Data: $cachedData');
} else {
  print('No data found for the given key.');
}
```

### Clearing Cached Data

To clear cached data, use the `clearCache` method:

```dart
await cacheManager.clearCache('your_key');
```

## Example

Here’s a simple example of how to use the package in a Flutter application:

```dart
import 'package:flutter/material.dart';
import 'package:data_cache_x/data_cache_x.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cacheManager = CacheManager(CacheRepository(LocalDataSource()));

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('API Cache Example')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await cacheManager.cacheData('example_key', 'Hello, World!');
              String? data = await cacheManager.getCachedData('example_key');
              print(data); // Output: Hello, World!
            },
            child: Text('Cache Data'),
          ),
        ),
      ),
    );
  }
}
```
