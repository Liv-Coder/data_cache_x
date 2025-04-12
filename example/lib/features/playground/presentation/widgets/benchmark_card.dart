import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../data/models/benchmark_result.dart';

class BenchmarkCard extends StatelessWidget {
  final BenchmarkResult result;

  const BenchmarkCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 32),
            _buildPerformanceSection(context),
            const Divider(height: 32),
            _buildConfigSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (result.adapterName) {
      case 'memory':
        color = Colors.blue;
        icon = Ionicons.hardware_chip_outline;
        break;
      case 'hive':
        color = Colors.orange;
        icon = Ionicons.file_tray_full_outline;
        break;
      case 'sqlite':
        color = Colors.green;
        icon = Ionicons.server_outline;
        break;
      case 'shared_prefs':
        color = Colors.purple;
        icon = Ionicons.document_text_outline;
        break;
      default:
        color = Colors.grey;
        icon = Ionicons.cube_outline;
    }
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.adapterDisplayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Total time: ${result.formattedTotalTime}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildPerformanceGrid(context),
      ],
    );
  }

  Widget _buildPerformanceGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildPerformanceItem(
          context,
          'Write',
          result.formattedWriteTime,
          result.formattedWriteOpsPerSecond,
          Ionicons.create_outline,
          Colors.blue,
        ),
        _buildPerformanceItem(
          context,
          'Read',
          result.formattedReadTime,
          result.formattedReadOpsPerSecond,
          Ionicons.eye_outline,
          Colors.green,
        ),
        _buildPerformanceItem(
          context,
          'Delete',
          result.formattedDeleteTime,
          result.formattedDeleteOpsPerSecond,
          Ionicons.trash_outline,
          Colors.red,
        ),
        _buildPerformanceItem(
          context,
          'Average',
          result.formattedTotalTime,
          result.formattedAverageOpsPerSecond,
          Ionicons.speedometer_outline,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(
    BuildContext context,
    String title,
    String time,
    String opsPerSecond,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  opsPerSecond,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuration',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          context,
          'Items',
          '${result.itemCount}',
          Ionicons.list_outline,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          'Item Size',
          '${result.itemSize} bytes',
          Ionicons.resize_outline,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          'Total Size',
          result.formattedTotalSize,
          Ionicons.server_outline,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          'Hit Rate',
          result.formattedHitRate,
          Ionicons.analytics_outline,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          'Compression',
          _getCompressionString(result.compression),
          Ionicons.archive_outline,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          'Priority',
          _getPriorityString(result.priority),
          Ionicons.flag_outline,
        ),
        if (result.expiry != null) ...[
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            'Expiry',
            '${result.expiry!.inMinutes} minutes',
            Ionicons.time_outline,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary.withAlpha(179),
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
              ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  String _getCompressionString(dynamic compression) {
    switch (compression.toString()) {
      case 'CompressionMode.auto':
        return 'Auto';
      case 'CompressionMode.always':
        return 'Always';
      case 'CompressionMode.never':
        return 'Never';
      default:
        return 'Auto';
    }
  }

  String _getPriorityString(dynamic priority) {
    switch (priority.toString()) {
      case 'CachePriority.low':
        return 'Low';
      case 'CachePriority.normal':
        return 'Normal';
      case 'CachePriority.high':
        return 'High';
      case 'CachePriority.critical':
        return 'Critical';
      default:
        return 'Normal';
    }
  }
}
