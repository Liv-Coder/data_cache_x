import 'package:data_cache_x/utils/isolate_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IsolateRunner', () {
    test('runWithThreshold runs synchronously when below threshold', () async {
      final result = await IsolateRunner.runWithThreshold<String, int>(
        function: (data) => data.length,
        message: 'test',
        dataSize: 4,
        asyncThreshold: 10,
      );

      expect(result, equals(4));
    });

    test('runWithThreshold runs in isolate when above threshold', () async {
      final result = await IsolateRunner.runWithThreshold<String, int>(
        function: (data) => data.length,
        message: 'test',
        dataSize: 20,
        asyncThreshold: 10,
      );

      expect(result, equals(4));
    });

    test('run executes function in isolate', () async {
      final result = await IsolateRunner.run<String, int>(
        function: (data) => data.length,
        message: 'test',
      );

      expect(result, equals(4));
    });

    test('runBatch processes items in batches', () async {
      final items = List.generate(100, (index) => 'item$index');
      final results = await IsolateRunner.runBatch<String, int>(
        function: (data) => data.length,
        items: items,
        batchSize: 20,
      );

      expect(results.length, equals(100));
      for (int i = 0; i < 100; i++) {
        expect(results[i], equals(items[i].length));
      }
    });

    test('runBatch handles empty list', () async {
      final results = await IsolateRunner.runBatch<String, int>(
        function: (data) => data.length,
        items: [],
        batchSize: 20,
      );

      expect(results, isEmpty);
    });

    test('runBatch processes small batches in a single isolate', () async {
      final items = List.generate(10, (index) => 'item$index');
      final results = await IsolateRunner.runBatch<String, int>(
        function: (data) => data.length,
        items: items,
        batchSize: 20,
      );

      expect(results.length, equals(10));
      for (int i = 0; i < 10; i++) {
        expect(results[i], equals(items[i].length));
      }
    });

    test('run handles exceptions gracefully', () async {
      expect(
        () => IsolateRunner.run<String, int>(
          function: (data) => throw Exception('Test exception'),
          message: 'test',
        ),
        throwsException,
      );
    });

    test('runWithThreshold handles exceptions gracefully', () async {
      expect(
        () => IsolateRunner.runWithThreshold<String, int>(
          function: (data) => throw Exception('Test exception'),
          message: 'test',
          dataSize: 20,
          asyncThreshold: 10,
        ),
        throwsException,
      );
    });

    test('runBatch handles exceptions in individual items', () async {
      final items = ['valid', 'invalid', 'valid2'];
      
      expect(
        () => IsolateRunner.runBatch<String, int>(
          function: (data) {
            if (data == 'invalid') {
              throw Exception('Test exception');
            }
            return data.length;
          },
          items: items,
          batchSize: 1,
        ),
        throwsException,
      );
    });
  });
}
