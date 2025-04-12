import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.information_circle_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Analytics Page - Coming Soon',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache Analytics Demo'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This demo will visualize cache performance metrics.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Features to be implemented:'),
              SizedBox(height: 8),
              Text('• Hit/miss rate visualization'),
              Text('• Cache size monitoring'),
              Text('• Most frequently accessed items'),
              Text('• Performance metrics over time'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
