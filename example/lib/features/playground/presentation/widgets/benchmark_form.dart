import 'package:data_cache_x/data_cache_x.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../data/models/adapter_benchmark.dart';

class BenchmarkForm extends StatefulWidget {
  final Function(AdapterBenchmark) onRunBenchmark;

  const BenchmarkForm({
    super.key,
    required this.onRunBenchmark,
  });

  @override
  State<BenchmarkForm> createState() => _BenchmarkFormState();
}

class _BenchmarkFormState extends State<BenchmarkForm> {
  int _itemCount = 100;
  int _itemSize = 100;
  Duration? _expiry;
  CachePriority _priority = CachePriority.normal;
  CompressionMode _compression = CompressionMode.auto;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPresetButtons(),
            const SizedBox(height: 16),
            _buildItemCountSlider(),
            const SizedBox(height: 16),
            _buildItemSizeSlider(),
            const SizedBox(height: 16),
            _buildExpiryDropdown(),
            const SizedBox(height: 16),
            _buildPriorityDropdown(),
            const SizedBox(height: 16),
            _buildCompressionDropdown(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _runBenchmark,
                icon: const Icon(Ionicons.play_outline),
                label: const Text('Run Benchmark'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _applyPreset(AdapterBenchmark.small()),
            child: const Text('Small'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _applyPreset(AdapterBenchmark.medium()),
            child: const Text('Medium'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _applyPreset(AdapterBenchmark.large()),
            child: const Text('Large'),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCountSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Ionicons.list_outline, size: 16),
            const SizedBox(width: 8),
            Text(
              'Item Count: $_itemCount',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        Slider(
          value: _itemCount.toDouble(),
          min: 10,
          max: 1000,
          divisions: 99,
          label: _itemCount.toString(),
          onChanged: (value) {
            setState(() {
              _itemCount = value.toInt();
            });
          },
        ),
      ],
    );
  }

  Widget _buildItemSizeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Ionicons.resize_outline, size: 16),
            const SizedBox(width: 8),
            Text(
              'Item Size: $_itemSize bytes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        Slider(
          value: _itemSize.toDouble(),
          min: 10,
          max: 1000,
          divisions: 99,
          label: _itemSize.toString(),
          onChanged: (value) {
            setState(() {
              _itemSize = value.toInt();
            });
          },
        ),
      ],
    );
  }

  Widget _buildExpiryDropdown() {
    return Row(
      children: [
        const Icon(Ionicons.time_outline, size: 16),
        const SizedBox(width: 8),
        Text(
          'Expiry:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<Duration?>(
            value: _expiry,
            isExpanded: true,
            hint: const Text('No expiry'),
            onChanged: (value) {
              setState(() {
                _expiry = value;
              });
            },
            items: [
              const DropdownMenuItem<Duration?>(
                value: null,
                child: Text('No expiry'),
              ),
              DropdownMenuItem<Duration?>(
                value: const Duration(minutes: 5),
                child: const Text('5 minutes'),
              ),
              DropdownMenuItem<Duration?>(
                value: const Duration(minutes: 15),
                child: const Text('15 minutes'),
              ),
              DropdownMenuItem<Duration?>(
                value: const Duration(minutes: 30),
                child: const Text('30 minutes'),
              ),
              DropdownMenuItem<Duration?>(
                value: const Duration(hours: 1),
                child: const Text('1 hour'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown() {
    return Row(
      children: [
        const Icon(Ionicons.flag_outline, size: 16),
        const SizedBox(width: 8),
        Text(
          'Priority:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<CachePriority>(
            value: _priority,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _priority = value;
                });
              }
            },
            items: [
              DropdownMenuItem<CachePriority>(
                value: CachePriority.low,
                child: const Text('Low'),
              ),
              DropdownMenuItem<CachePriority>(
                value: CachePriority.normal,
                child: const Text('Normal'),
              ),
              DropdownMenuItem<CachePriority>(
                value: CachePriority.high,
                child: const Text('High'),
              ),
              DropdownMenuItem<CachePriority>(
                value: CachePriority.critical,
                child: const Text('Critical'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompressionDropdown() {
    return Row(
      children: [
        const Icon(Ionicons.archive_outline, size: 16),
        const SizedBox(width: 8),
        Text(
          'Compression:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<CompressionMode>(
            value: _compression,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _compression = value;
                });
              }
            },
            items: [
              DropdownMenuItem<CompressionMode>(
                value: CompressionMode.auto,
                child: const Text('Auto'),
              ),
              DropdownMenuItem<CompressionMode>(
                value: CompressionMode.always,
                child: const Text('Always'),
              ),
              DropdownMenuItem<CompressionMode>(
                value: CompressionMode.never,
                child: const Text('Never'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _applyPreset(AdapterBenchmark benchmark) {
    setState(() {
      _itemCount = benchmark.itemCount;
      _itemSize = benchmark.itemSize;
      _expiry = benchmark.expiry;
      _priority = benchmark.priority;
      _compression = benchmark.compression;
    });
  }

  void _runBenchmark() {
    final benchmark = AdapterBenchmark(
      itemCount: _itemCount,
      itemSize: _itemSize,
      expiry: _expiry,
      priority: _priority,
      compression: _compression,
    );
    
    widget.onRunBenchmark(benchmark);
  }
}
