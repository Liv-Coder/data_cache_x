import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import '../../data/repositories/playground_repository.dart';
import '../bloc/playground_bloc.dart';
import '../widgets/benchmark_card.dart';
import '../widgets/benchmark_form.dart';
import '../widgets/comparison_chart.dart';

class PlaygroundPage extends StatelessWidget {
  const PlaygroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlaygroundBloc(
        playgroundRepository: PlaygroundRepository(),
      )..add(LoadAdaptersEvent()),
      child: const _PlaygroundPageContent(),
    );
  }
}

class _PlaygroundPageContent extends StatelessWidget {
  const _PlaygroundPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adapter Playground'),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.refresh_outline),
            onPressed: () =>
                context.read<PlaygroundBloc>().add(LoadAdaptersEvent()),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Ionicons.information_circle_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Info',
          ),
        ],
      ),
      body: BlocBuilder<PlaygroundBloc, PlaygroundState>(
        builder: (context, state) {
          if (state is PlaygroundInitial) {
            return const Center(
              child: Text('Loading adapters...'),
            );
          } else if (state is PlaygroundLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AdaptersLoaded) {
            return _buildAdaptersContent(context, state);
          } else if (state is BenchmarkRunning) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Running benchmark for ${state.adapter}...'),
                ],
              ),
            );
          } else if (state is BenchmarkCompleted) {
            return _buildBenchmarkResult(context, state);
          } else if (state is ComparisonBenchmarkCompleted) {
            return _buildComparisonResult(context, state);
          } else if (state is PlaygroundError) {
            return Center(
              child: Text(state.message),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildAdaptersContent(BuildContext context, AdaptersLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Adapters',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select an adapter to benchmark or run a comparison benchmark.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _buildAdapterGrid(context, state.adapters),
          const SizedBox(height: 24),
          Text(
            'Comparison Benchmark',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Run a benchmark on all available adapters to compare their performance.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          BenchmarkForm(
            onRunBenchmark: (benchmark) {
              context.read<PlaygroundBloc>().add(
                    RunComparisonBenchmarkEvent(
                      benchmark: benchmark,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdapterGrid(BuildContext context, List<String> adapters) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: adapters.length,
      itemBuilder: (context, index) {
        final adapter = adapters[index];
        return _buildAdapterCard(context, adapter);
      },
    );
  }

  Widget _buildAdapterCard(BuildContext context, String adapter) {
    String displayName;
    IconData icon;
    Color color;

    switch (adapter) {
      case 'memory':
        displayName = 'Memory';
        icon = Ionicons.hardware_chip_outline;
        color = Colors.blue;
        break;
      case 'hive':
        displayName = 'Hive';
        icon = Ionicons.file_tray_full_outline;
        color = Colors.orange;
        break;
      case 'sqlite':
        displayName = 'SQLite';
        icon = Ionicons.server_outline;
        color = Colors.green;
        break;
      case 'shared_prefs':
        displayName = 'SharedPreferences';
        icon = Ionicons.document_text_outline;
        color = Colors.purple;
        break;
      default:
        displayName = adapter;
        icon = Ionicons.cube_outline;
        color = Colors.grey;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showBenchmarkDialog(context, adapter, displayName),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () =>
                    _showBenchmarkDialog(context, adapter, displayName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Benchmark'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBenchmarkDialog(
      BuildContext context, String adapter, String displayName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Benchmark $displayName Adapter'),
        content: BenchmarkForm(
          onRunBenchmark: (benchmark) {
            Navigator.of(context).pop();
            context.read<PlaygroundBloc>().add(
                  RunBenchmarkEvent(
                    adapter: adapter,
                    benchmark: benchmark,
                  ),
                );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkResult(BuildContext context, BenchmarkCompleted state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Ionicons.arrow_back),
                onPressed: () =>
                    context.read<PlaygroundBloc>().add(LoadAdaptersEvent()),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Benchmark Results',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BenchmarkCard(result: state.result),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<PlaygroundBloc>().add(LoadAdaptersEvent()),
            icon: const Icon(Ionicons.refresh_outline),
            label: const Text('Run Another Benchmark'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonResult(
      BuildContext context, ComparisonBenchmarkCompleted state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Ionicons.arrow_back),
                onPressed: () =>
                    context.read<PlaygroundBloc>().add(LoadAdaptersEvent()),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Comparison Results',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Performance Comparison',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ComparisonChart(results: state.results),
          const SizedBox(height: 24),
          Text(
            'Detailed Results',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...state.results.map((result) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BenchmarkCard(result: result),
              )),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<PlaygroundBloc>().add(LoadAdaptersEvent()),
            icon: const Icon(Ionicons.refresh_outline),
            label: const Text('Run Another Comparison'),
          ),
        ],
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
                'This demo allows you to compare different cache adapters.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Features demonstrated:'),
              SizedBox(height: 8),
              Text('• Compare performance of different adapters'),
              Text('• Test different cache policies'),
              Text('• Benchmark operations (read, write, delete)'),
              Text('• Visualize adapter differences with charts'),
              SizedBox(height: 16),
              Text(
                  'Select an adapter to benchmark it individually, or run a comparison benchmark to compare all adapters.'),
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
