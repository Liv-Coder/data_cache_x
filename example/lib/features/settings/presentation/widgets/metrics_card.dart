import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class MetricsCard extends StatelessWidget {
  final Map<String, dynamic> metrics;

  const MetricsCard({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Hit Rate',
                    '${(metrics['hitRate'] * 100).toStringAsFixed(1)}%',
                    Ionicons.analytics_outline,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Total Size',
                    _formatBytes(metrics['totalSize']),
                    Ionicons.server_outline,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Hits',
                    '${metrics['hitCount']}',
                    Ionicons.checkmark_circle_outline,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Misses',
                    '${metrics['missCount']}',
                    Ionicons.close_circle_outline,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricItem(
              context,
              'Average Item Size',
              _formatBytes(metrics['averageItemSize']),
              Ionicons.resize_outline,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(dynamic bytes) {
    if (bytes == null) return '0 B';
    
    final double value = bytes is int ? bytes.toDouble() : bytes;
    
    if (value < 1024) {
      return '${value.toStringAsFixed(1)} B';
    } else if (value < 1024 * 1024) {
      return '${(value / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
