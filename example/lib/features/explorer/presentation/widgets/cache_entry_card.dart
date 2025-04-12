import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart';

import '../../data/models/cache_entry.dart';

class CacheEntryCard extends StatelessWidget {
  final CacheEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CacheEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Ionicons.trash_outline,
                      size: 18,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: const EdgeInsets.all(4),
                    iconSize: 18,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                'Size',
                entry.formattedSize,
                Ionicons.server_outline,
              ),
              const SizedBox(height: 4),
              _buildInfoRow(
                context,
                'Created',
                _formatDate(entry.createdAt),
                Ionicons.calendar_outline,
              ),
              const SizedBox(height: 4),
              _buildInfoRow(
                context,
                'Expires',
                entry.expiresAt != null ? entry.timeToExpiry : 'Never',
                Ionicons.time_outline,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTag(
                    context,
                    entry.priorityString,
                    _getPriorityColor(entry.priority),
                  ),
                  if (entry.isCompressed)
                    _buildTag(
                      context,
                      'Compressed',
                      Colors.purple,
                    ),
                  if (entry.isEncrypted)
                    _buildTag(
                      context,
                      'Encrypted',
                      Colors.green,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
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
          size: 14,
          color: Theme.of(context).colorScheme.primary.withAlpha(179),
        ),
        const SizedBox(width: 4),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
              ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withAlpha(77),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMd().add_Hm().format(date);
  }

  Color _getPriorityColor(dynamic priority) {
    switch (priority.toString()) {
      case 'CachePriority.low':
        return Colors.grey;
      case 'CachePriority.normal':
        return Colors.blue;
      case 'CachePriority.high':
        return Colors.orange;
      case 'CachePriority.critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
