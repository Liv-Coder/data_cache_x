import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../widgets/feature_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CacheHub'),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.information_circle_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Cache X Showcase',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore the full potential of the data_cache_x package',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(179), // 0.7 * 255 = 179
                  ),
            ),
            const SizedBox(height: 24),
            const _FeatureGrid(),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About CacheHub'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CacheHub is a showcase app demonstrating the capabilities of the data_cache_x package.',
              ),
              SizedBox(height: 16),
              Text(
                'Features demonstrated:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                  '• Multiple cache adapters (Hive, SQLite, SharedPreferences, Memory)'),
              Text('• Different cache policies and eviction strategies'),
              Text('• Data compression and encryption'),
              Text('• Cache analytics and monitoring'),
              Text('• Background cleanup of expired items'),
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

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: const [
        FeatureCard(
          title: 'News Feed',
          description: 'API caching with different policies',
          icon: Ionicons.newspaper_outline,
          color: Color(0xFF4A6FFF),
          route: '/news',
        ),
        FeatureCard(
          title: 'Image Gallery',
          description: 'Binary data caching for images',
          icon: Ionicons.images_outline,
          color: Color(0xFF00C8B8),
          route: '/gallery',
        ),
        FeatureCard(
          title: 'Analytics',
          description: 'Cache performance metrics',
          icon: Ionicons.bar_chart_outline,
          color: Color(0xFFFF5252),
          route: '/analytics',
        ),
        FeatureCard(
          title: 'Cache Explorer',
          description: 'Explore and manipulate cached data',
          icon: Ionicons.search_outline,
          color: Color(0xFFFFAA00),
          route: '/explorer',
        ),
        FeatureCard(
          title: 'Adapter Playground',
          description: 'Compare different cache adapters',
          icon: Ionicons.layers_outline,
          color: Color(0xFF9C27B0),
          route: '/playground',
        ),
        FeatureCard(
          title: 'Settings',
          description: 'Configure cache behavior',
          icon: Ionicons.settings_outline,
          color: Color(0xFF607D8B),
          route: '/settings',
        ),
      ],
    );
  }
}
