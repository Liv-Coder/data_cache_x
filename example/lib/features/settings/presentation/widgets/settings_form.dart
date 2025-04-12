import 'package:data_cache_x/data_cache_x.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../data/models/cache_settings.dart';

class SettingsForm extends StatefulWidget {
  final CacheSettings settings;
  final Function(CacheSettings) onUpdateSettings;
  final Function(CacheSettings) onApplySettings;
  final VoidCallback onResetSettings;

  const SettingsForm({
    super.key,
    required this.settings,
    required this.onUpdateSettings,
    required this.onApplySettings,
    required this.onResetSettings,
  });

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  late CacheSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  void didUpdateWidget(SettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      setState(() {
        _settings = widget.settings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCleanupFrequencySlider(),
            const SizedBox(height: 16),
            _buildMaxItemsSlider(),
            const SizedBox(height: 16),
            _buildDefaultExpirySlider(),
            const SizedBox(height: 16),
            _buildCompressionDropdown(),
            const SizedBox(height: 16),
            _buildPriorityDropdown(),
            const SizedBox(height: 16),
            _buildEvictionStrategyDropdown(),
            const SizedBox(height: 16),
            _buildEncryptionSwitch(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onUpdateSettings(_settings),
                    icon: const Icon(Ionicons.save_outline),
                    label: const Text('Save Settings'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onApplySettings(_settings),
                    icon: const Icon(Ionicons.checkmark_outline),
                    label: const Text('Apply Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onResetSettings,
                icon: const Icon(Ionicons.refresh_outline),
                label: const Text('Reset to Defaults'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanupFrequencySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Ionicons.time_outline, size: 16),
            const SizedBox(width: 8),
            Text(
              'Cleanup Frequency: ${_settings.cleanupFrequency.inMinutes} minutes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        Slider(
          value: _settings.cleanupFrequency.inMinutes.toDouble(),
          min: 5,
          max: 120,
          divisions: 23,
          label: '${_settings.cleanupFrequency.inMinutes} minutes',
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(
                cleanupFrequency: Duration(minutes: value.toInt()),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildMaxItemsSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Ionicons.list_outline, size: 16),
            const SizedBox(width: 8),
            Text(
              'Max Items: ${_settings.maxItems}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        Slider(
          value: _settings.maxItems.toDouble(),
          min: 100,
          max: 10000,
          divisions: 99,
          label: '${_settings.maxItems}',
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(
                maxItems: value.toInt(),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildDefaultExpirySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Ionicons.hourglass_outline, size: 16),
            const SizedBox(width: 8),
            Text(
              'Default Expiry: ${_settings.defaultExpiry.inMinutes} minutes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        Slider(
          value: _settings.defaultExpiry.inMinutes.toDouble(),
          min: 1,
          max: 240,
          divisions: 239,
          label: '${_settings.defaultExpiry.inMinutes} minutes',
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(
                defaultExpiry: Duration(minutes: value.toInt()),
              );
            });
          },
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
          'Default Compression:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<CompressionMode>(
            value: _settings.defaultCompression,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _settings = _settings.copyWith(
                    defaultCompression: value,
                  );
                });
              }
            },
            items: const [
              DropdownMenuItem<CompressionMode>(
                value: CompressionMode.auto,
                child: Text('Auto'),
              ),
              DropdownMenuItem<CompressionMode>(
                value: CompressionMode.always,
                child: Text('Always'),
              ),
              DropdownMenuItem<CompressionMode>(
                value: CompressionMode.never,
                child: Text('Never'),
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
          'Default Priority:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<CachePriority>(
            value: _settings.defaultPriority,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _settings = _settings.copyWith(
                    defaultPriority: value,
                  );
                });
              }
            },
            items: const [
              DropdownMenuItem<CachePriority>(
                value: CachePriority.low,
                child: Text('Low'),
              ),
              DropdownMenuItem<CachePriority>(
                value: CachePriority.normal,
                child: Text('Normal'),
              ),
              DropdownMenuItem<CachePriority>(
                value: CachePriority.high,
                child: Text('High'),
              ),
              DropdownMenuItem<CachePriority>(
                value: CachePriority.critical,
                child: Text('Critical'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEvictionStrategyDropdown() {
    return Row(
      children: [
        const Icon(Ionicons.trash_outline, size: 16),
        const SizedBox(width: 8),
        Text(
          'Eviction Strategy:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<EvictionStrategy>(
            value: _settings.evictionStrategy,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _settings = _settings.copyWith(
                    evictionStrategy: value,
                  );
                });
              }
            },
            items: const [
              DropdownMenuItem<EvictionStrategy>(
                value: EvictionStrategy.lru,
                child: Text('LRU (Least Recently Used)'),
              ),
              DropdownMenuItem<EvictionStrategy>(
                value: EvictionStrategy.lfu,
                child: Text('LFU (Least Frequently Used)'),
              ),
              DropdownMenuItem<EvictionStrategy>(
                value: EvictionStrategy.fifo,
                child: Text('FIFO (First In First Out)'),
              ),
              DropdownMenuItem<EvictionStrategy>(
                value: EvictionStrategy.ttl,
                child: Text('TTL Based'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEncryptionSwitch() {
    return Row(
      children: [
        const Icon(Ionicons.lock_closed_outline, size: 16),
        const SizedBox(width: 8),
        Text(
          'Enable Encryption:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        Switch(
          value: _settings.encryptionEnabled,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(
                encryptionEnabled: value,
              );
            });
          },
        ),
      ],
    );
  }
}
