# DataCacheX

[![pub package](https://img.shields.io/pub/v/your_package_name.svg)](https://pub.dev/packages/your_package_name)

A Flutter package for efficient API caching, built with Clean Architecture principles. This package provides a simple and robust way to cache API responses locally, improving the performance and user experience of your Flutter applications.

## Features

- **Local Caching**: Store API responses locally using `SharedPreferences` for quick access.
- **Clean Architecture**: Organized code structure that separates concerns into data, domain, and presentation layers.
- **Easy to Use**: Simple API for caching and retrieving data.
- **Robust Error Handling**: Built-in error handling to manage caching operations.
- **Extensible**: Easily extendable for additional features like cache expiration or different storage solutions.

## Installation

Add the following dependency to your `pubspec.yaml` file:

yaml
dependencies:
data_cache_x: ^0.1.0

Then run:

flutter pub get

## Usage

### Import the Package

import 'package:your_package_name/your_package_name.dart';

### Initialize the Cache Manager

Create an instance of the `CacheManager`:

```dart
final cacheManager = CacheManager(CacheRepository(LocalDataSource()));
```

### Caching Data

To cache data, use the `cacheData` method:

await cacheManager.cacheData('your_key', 'your_data');

### Retrieving Cached Data

To retrieve cached data, use the `getCachedData` method:

String? cachedData = await cacheManager.getCachedData('your_key');
if (cachedData != null) {
print('Cached Data: $cachedData');
} else {
print('No data found for the given key.');
}

### Clearing Cached Data

To clear cached data, use the `clearCache` method:

await cacheManager.clearCache('your_key');

## Example

Here’s a simple example of how to use the package in a Flutter application:

import 'package:flutter/material.dart';
import 'package:your_package_name/your_package_name.dart';

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

## Contributing

Contributions are welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For any inquiries, please reach out to [your_email@example.com](mailto:your_email@example.com).

---
