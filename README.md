# DataCacheX

[![pub package](https://img.shields.io/pub/v/data_cache_x.svg)](https://pub.dev/packages/data_cache_x)

A Flutter package for efficient API caching, built with Clean Architecture principles. This package provides a simple and robust way to cache API responses locally, improving the performance and user experience of your Flutter applications.

## Features

- **Local Caching**: Store API responses locally using SQLite for quick access.
- **Support for Various Data Types**: Cache strings, lists, maps, and JSON objects.
- **Easy to Use**: Simple API for caching and retrieving data.
- **Robust Error Handling**: Built-in error handling to manage caching operations.
- **Compression Support**: Optionally compress cached data to save space.
- **Cache Debugging**: Print the contents of the cache for debugging purposes.

## Installation

Add the following dependency to your `pubspec.yaml` file:


```yaml
dependencies:
  data_cache_x: ^0.1.3
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
await cacheManager.cacheData('your_key', yourData, Duration(minutes: 1));
```

### Retrieving Cached Data

To retrieve cached data, use the `getCachedData` method:

```dart
dynamic cachedData = await cacheManager.getCachedData('your_key');
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

### Clearing All Cached Data

To clear all cached data, use the `clearAllCache` method:

```dart
await cacheManager.clearAllCache();
```

### Printing Cached Contents

To print the contents of the cache for debugging purposes, use the `printCacheContents` method:

```dart
await cacheManager.printCacheContents();
```

## Example


This example provides a modern user interface for interacting with the cache, including:

- Text fields with outlined borders for entering cache keys and data
- Buttons with icons for better visual cues
- A card layout for organizing input fields and displaying cached data
- Responsive button layout using a wrap widget
- Snackbar notifications for user feedback

Run this example to see DataCacheX in action with a sleek, Material 3-based user interface.

```dart
import 'package:flutter/material.dart';
import 'package:data_cache_x/data_cache_x.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataCacheX Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CacheDemoPage(),
    );
  }
}

class CacheDemoPage extends StatefulWidget {
  const CacheDemoPage({Key? key}) : super(key: key);

  @override
  _CacheDemoPageState createState() => _CacheDemoPageState();
}

class _CacheDemoPageState extends State<CacheDemoPage> {
  final CacheManager cacheManager = CacheManager(CacheRepository(LocalDataSource()));
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  String _cachedData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DataCacheX Demo'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _keyController,
                      decoration: const InputDecoration(
                        labelText: 'Cache Key',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dataController,
                      decoration: const InputDecoration(
                        labelText: 'Data to Cache',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _cacheData,
                  icon: const Icon(Icons.save),
                  label: const Text('Cache Data'),
                ),
                ElevatedButton.icon(
                  onPressed: _getCachedData,
                  icon: const Icon(Icons.search),
                  label: const Text('Get Cached Data'),
                ),
                ElevatedButton.icon(
                  onPressed: _clearCache,
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear Cache'),
                ),
                ElevatedButton.icon(
                  onPressed: _printCacheContents,
                  icon: const Icon(Icons.print),
                  label: const Text('Print Cache Contents'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cached Data:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_cachedData),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cacheData() async {
    final key = _keyController.text;
    final data = _dataController.text;
    if (key.isNotEmpty && data.isNotEmpty) {
      await cacheManager.cacheData(key, data, const Duration(minutes: 5));
      _showSnackBar('Data cached successfully');
    }
  }

  Future<void> _getCachedData() async {
    final key = _keyController.text;
    if (key.isNotEmpty) {
      final data = await cacheManager.getCachedData(key);
      setState(() {
        _cachedData = data?.toString() ?? 'No data found';
      });
    }
  }

  Future<void> _clearCache() async {
    final key = _keyController.text;
    if (key.isNotEmpty) {
      await cacheManager.clearCache(key);
      _showSnackBar('Cache cleared for key: $key');
    }
  }

  Future<void> _printCacheContents() async {
    await cacheManager.printCacheContents();
    _showSnackBar('Cache contents printed to console');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```
