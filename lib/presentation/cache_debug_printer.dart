import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';

class CacheDebugTablePrinter {
  static const int _keyWidth = 20;
  static const int _dataPreviewWidth = 30;
  static const int _expirationWidth = 20;
  static const int _compressedWidth = 10;
  static const int _totalWidth =
      _keyWidth + _dataPreviewWidth + _expirationWidth + _compressedWidth + 13;

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: false,
      printTime: false,
    ),
  );

  static void printCacheContents(List<Map<String, dynamic>> cacheEntries) {
    if (cacheEntries.isEmpty) {
      _logger.i('The cache is empty.');
      return;
    }

    final StringBuffer table = StringBuffer();

    _addTableHeader(table);

    for (var entry in cacheEntries) {
      _addTableRow(table, entry);
    }

    _addTableFooter(table);

    _logger.i(table.toString());
  }

  static void _addTableHeader(StringBuffer buffer) {
    buffer.writeln('┌${'─' * _totalWidth}┐');
    buffer.writeln(
        '│ ${'Key'.padRight(_keyWidth)} │ ${'Data Preview'.padRight(_dataPreviewWidth)} │ ${'Expiration'.padRight(_expirationWidth)} │ ${'Compressed'.padRight(_compressedWidth)} │');
    buffer.writeln(
        '├${'─' * _keyWidth}┼${'─' * (_dataPreviewWidth + 2)}┼${'─' * (_expirationWidth + 2)}┼${'─' * (_compressedWidth + 2)}┤');
  }

  static void _addTableRow(StringBuffer buffer, Map<String, dynamic> entry) {
    final key = entry['key'] as String;
    final data = entry['data'];
    final isCompressed = entry['isCompressed'] == 1;
    final expirationDuration = entry['expirationDuration'] as int;
    final timestamp = entry['timestamp'] as int;

    String dataPreview;
    if (data is List<int>) {
      if (isCompressed) {
        dataPreview = utf8.decode(gzip.decode(data));
      } else {
        dataPreview = utf8.decode(data);
      }
    } else {
      dataPreview = data.toString();
    }

    dataPreview = _truncateString(dataPreview, _dataPreviewWidth);
    final expirationDate =
        DateTime.fromMillisecondsSinceEpoch(timestamp + expirationDuration);
    final isExpired = DateTime.now().isAfter(expirationDate);

    buffer.writeln(
        '│ ${key.padRight(_keyWidth)} │ ${dataPreview.padRight(_dataPreviewWidth)} │ ${_formatDate(expirationDate).padRight(_expirationWidth)} │ ${(isCompressed ? 'Yes' : 'No').padRight(_compressedWidth)} │');

    if (isExpired) {
      buffer.writeln(
          '│ ${' '.padRight(_keyWidth)} │ ${'EXPIRED'.padRight(_dataPreviewWidth)} │ ${' '.padRight(_expirationWidth)} │ ${' '.padRight(_compressedWidth)} │');
    }

    buffer.writeln(
        '├${'─' * _keyWidth}┼${'─' * (_dataPreviewWidth + 2)}┼${'─' * (_expirationWidth + 2)}┼${'─' * (_compressedWidth + 2)}┤');
  }

  static void _addTableFooter(StringBuffer buffer) {
    buffer.writeln('└${'─' * _totalWidth}┘');
  }

  static String _truncateString(String str, int size) {
    if (str.length <= size) return str;
    return '${str.substring(0, size - 3)}...';
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
