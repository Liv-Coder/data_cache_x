import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.information_circle_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Gallery Page - Coming Soon',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Gallery Demo'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This demo will showcase caching of binary data (images) with different caching strategies.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Features to be implemented:'),
              SizedBox(height: 8),
              Text('• Caching images with different policies'),
              Text('• Compression of image data'),
              Text('• Cache size management'),
              Text('• Offline image viewing'),
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
