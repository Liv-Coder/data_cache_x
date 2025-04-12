import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../data/repositories/analytics_repository.dart';
import '../bloc/analytics_bloc.dart';
import '../widgets/analytics_card.dart';
import '../widgets/key_value_list.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc(
        analyticsRepository: AnalyticsRepository(),
      )..add(LoadAnalyticsEvent()),
      child: const _AnalyticsPageContent(),
    );
  }
}

class _AnalyticsPageContent extends StatelessWidget {
  const _AnalyticsPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.refresh_outline),
            onPressed: () =>
                context.read<AnalyticsBloc>().add(LoadAnalyticsEvent()),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Ionicons.trash_outline),
            onPressed: () =>
                context.read<AnalyticsBloc>().add(ResetMetricsEvent()),
            tooltip: 'Reset Metrics',
          ),
          IconButton(
            icon: const Icon(Ionicons.information_circle_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Info',
          ),
        ],
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsInitial) {
            return const Center(
              child: Text('No analytics data available'),
            );
          } else if (state is AnalyticsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AnalyticsLoaded) {
            return _buildAnalyticsContent(context, state);
          } else if (state is AnalyticsError) {
            return Center(
              child: Text(state.message),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.read<AnalyticsBloc>().add(GenerateSampleDataEvent()),
        tooltip: 'Generate Sample Data',
        child: const Icon(Ionicons.add_outline),
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, AnalyticsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cache Performance Metrics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildMetricsGrid(context, state),
          const SizedBox(height: 24),
          Text(
            'Hit/Miss Rate',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _buildHitRateChart(context, state),
          const SizedBox(height: 24),
          Text(
            'Most Frequently Accessed Keys',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          KeyValueList(
            items: state.mostFrequentlyAccessedKeys,
            keyLabel: 'Key',
            valueLabel: 'Access Count',
            keyField: 'key',
            valueField: 'accessCount',
          ),
          const SizedBox(height: 24),
          Text(
            'Largest Items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          KeyValueList(
            items: state.largestItems,
            keyLabel: 'Key',
            valueLabel: 'Size (bytes)',
            keyField: 'key',
            valueField: 'size',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, AnalyticsLoaded state) {
    final summary = state.summary;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        AnalyticsCard(
          title: 'Hit Rate',
          value: '${state.hitRate.toStringAsFixed(1)}%',
          icon: Ionicons.checkmark_circle_outline,
          color: Colors.green,
        ),
        AnalyticsCard(
          title: 'Cache Size',
          value: _formatBytes(state.totalSize),
          icon: Ionicons.server_outline,
          color: Colors.blue,
        ),
        AnalyticsCard(
          title: 'Item Count',
          value: '${summary['itemCount']}',
          icon: Ionicons.list_outline,
          color: Colors.orange,
        ),
        AnalyticsCard(
          title: 'Operations',
          value:
              '${summary['hitCount'] + summary['missCount'] + summary['putCount']}',
          icon: Ionicons.pulse_outline,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildHitRateChart(BuildContext context, AnalyticsLoaded state) {
    final summary = state.summary;
    final hitCount = summary['hitCount'] as int;
    final missCount = summary['missCount'] as int;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
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
      child: hitCount + missCount > 0
          ? PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: hitCount.toDouble(),
                    title: 'Hits\n$hitCount',
                    color: Colors.green,
                    radius: 80,
                  ),
                  PieChartSectionData(
                    value: missCount.toDouble(),
                    title: 'Misses\n$missCount',
                    color: Colors.red,
                    radius: 80,
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            )
          : const Center(
              child: Text('No hit/miss data available'),
            ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
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
                'This demo visualizes cache performance metrics from the data_cache_x package.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Features demonstrated:'),
              SizedBox(height: 8),
              Text('• Hit/miss rate visualization'),
              Text('• Cache size monitoring'),
              Text('• Most frequently accessed items'),
              Text('• Largest items in the cache'),
              SizedBox(height: 16),
              Text(
                  'Use the floating action button to generate sample data for testing.'),
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
