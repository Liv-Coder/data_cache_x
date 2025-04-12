import 'package:flutter/material.dart';

class KeyValueList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String keyLabel;
  final String valueLabel;
  final String keyField;
  final String valueField;
  final int maxItems;

  const KeyValueList({
    super.key,
    required this.items,
    required this.keyLabel,
    required this.valueLabel,
    required this.keyField,
    required this.valueField,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = items.isEmpty ? [] : items.take(maxItems).toList();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: displayItems.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('No data available'),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          keyLabel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          valueLabel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...displayItems.map((item) => _buildListItem(context, item)),
              ],
            ),
    );
  }

  Widget _buildListItem(BuildContext context, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item[keyField].toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item[valueField].toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
