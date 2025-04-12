import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class PlaygroundPage extends StatelessWidget {
  const PlaygroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adapter Playground'),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.information_circle_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Playground Page - Coming Soon',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adapter Playground Demo'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This demo will allow you to compare different cache adapters.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Features to be implemented:'),
              SizedBox(height: 8),
              Text('• Compare performance of different adapters'),
              Text('• Test different cache policies'),
              Text('• Benchmark operations'),
              Text('• Visualize adapter differences'),
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
