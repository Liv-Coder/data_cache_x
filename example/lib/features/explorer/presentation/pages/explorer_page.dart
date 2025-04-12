import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ExplorerPage extends StatelessWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.information_circle_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Explorer Page - Coming Soon',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache Explorer Demo'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This demo will allow you to explore and manipulate cached data.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Features to be implemented:'),
              SizedBox(height: 8),
              Text('• Browse cached items'),
              Text('• View item details (expiry, size, etc.)'),
              Text('• Modify cache entries'),
              Text('• Delete individual items'),
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
