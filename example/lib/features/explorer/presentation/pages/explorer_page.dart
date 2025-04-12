import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import '../../data/repositories/explorer_repository.dart';
import '../bloc/explorer_bloc.dart';
import '../widgets/cache_entry_card.dart';
import '../widgets/stats_card.dart';

class ExplorerPage extends StatelessWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExplorerBloc(
        explorerRepository: ExplorerRepository(),
      )..add(LoadEntriesEvent()),
      child: const _ExplorerPageContent(),
    );
  }
}

class _ExplorerPageContent extends StatelessWidget {
  const _ExplorerPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.refresh_outline),
            onPressed: () =>
                context.read<ExplorerBloc>().add(LoadEntriesEvent()),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Ionicons.trash_outline),
            onPressed: () => _confirmClearAll(context),
            tooltip: 'Clear All',
          ),
          IconButton(
            icon: const Icon(Ionicons.information_circle_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Info',
          ),
        ],
      ),
      body: BlocBuilder<ExplorerBloc, ExplorerState>(
        builder: (context, state) {
          if (state is ExplorerInitial) {
            return const Center(
              child: Text('No cache entries available'),
            );
          } else if (state is ExplorerLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is EntriesLoaded) {
            return _buildEntriesContent(context, state);
          } else if (state is EntryValueLoaded) {
            return _buildEntryValueContent(context, state);
          } else if (state is ExplorerError) {
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

  Widget _buildEntriesContent(BuildContext context, EntriesLoaded state) {
    if (state.entries.isEmpty) {
      return const Center(
        child: Text('No cache entries found'),
      );
    }

    return Column(
      children: [
        _buildStatsSection(context, state),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.entries.length,
            itemBuilder: (context, index) {
              final entry = state.entries[index];
              return CacheEntryCard(
                entry: entry,
                onTap: () => context
                    .read<ExplorerBloc>()
                    .add(GetEntryValueEvent(entry.key)),
                onDelete: () => _confirmDeleteEntry(context, entry.key),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, EntriesLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cache Statistics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Entries',
                  value: '${state.stats['totalEntries']}',
                  icon: Ionicons.list_outline,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Total Size',
                  value: _formatBytes(state.stats['totalSize']),
                  icon: Ionicons.server_outline,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Compressed',
                  value: '${state.stats['compressedCount']}',
                  icon: Ionicons.archive_outline,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Encrypted',
                  value: '${state.stats['encryptedCount']}',
                  icon: Ionicons.lock_closed_outline,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntryValueContent(BuildContext context, EntryValueLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Ionicons.arrow_back),
                onPressed: () =>
                    context.read<ExplorerBloc>().add(LoadEntriesEvent()),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Entry: ${state.key}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Value:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              child: SingleChildScrollView(
                child: Text(
                  state.value ?? 'No value found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              ),
            ),
          ),
        ],
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

  void _confirmDeleteEntry(BuildContext context, String key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete the entry "$key"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ExplorerBloc>().add(DeleteEntryEvent(key));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Entries'),
        content:
            const Text('Are you sure you want to clear all cache entries?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ExplorerBloc>().add(ClearAllEntriesEvent());
              Navigator.of(context).pop();
            },
            child: const Text('Clear All'),
          ),
        ],
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
                'This demo allows you to explore and manipulate cached data.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Features demonstrated:'),
              SizedBox(height: 8),
              Text('• Browse cached items'),
              Text('• View item details (expiry, size, etc.)'),
              Text('• View cache entry values'),
              Text('• Delete individual items'),
              Text('• Clear all cache entries'),
              SizedBox(height: 16),
              Text('Tap on an entry to view its value.'),
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
