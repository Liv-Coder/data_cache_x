import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/cache_settings.dart';
import '../../data/repositories/settings_repository.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/metrics_card.dart';
import '../widgets/settings_form.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text('Error loading settings: ${snapshot.error}'),
            ),
          );
        }

        return BlocProvider(
          create: (context) => SettingsBloc(
            settingsRepository: SettingsRepository(
              prefs: snapshot.data!,
            ),
          )..add(LoadSettingsEvent()),
          child: const _SettingsPageContent(),
        );
      },
    );
  }
}

class _SettingsPageContent extends StatelessWidget {
  const _SettingsPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.refresh_outline),
            onPressed: () =>
                context.read<SettingsBloc>().add(LoadSettingsEvent()),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Ionicons.information_circle_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Info',
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsInitial) {
            return const Center(
              child: Text('Loading settings...'),
            );
          } else if (state is SettingsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SettingsLoaded) {
            return _buildSettingsContent(context, state);
          } else if (state is SettingsError) {
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

  Widget _buildSettingsContent(BuildContext context, SettingsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.metrics != null) ...[
            Text(
              'Cache Metrics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            MetricsCard(metrics: state.metrics!),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.read<SettingsBloc>().add(ResetMetricsEvent()),
                    icon: const Icon(Ionicons.refresh_outline),
                    label: const Text('Reset Metrics'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmClearCache(context),
                    icon: const Icon(Ionicons.trash_outline),
                    label: const Text('Clear Cache'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Cache Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          SettingsForm(
            settings: state.settings,
            onUpdateSettings: (settings) {
              context.read<SettingsBloc>().add(UpdateSettingsEvent(settings));
            },
            onApplySettings: (settings) {
              _confirmApplySettings(context, settings);
            },
            onResetSettings: () {
              _confirmResetSettings(context);
            },
          ),
        ],
      ),
    );
  }

  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
            'Are you sure you want to clear the cache? This will remove all cached data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SettingsBloc>().add(ClearCacheEvent());
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmApplySettings(BuildContext context, CacheSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Settings'),
        content: const Text(
          'Are you sure you want to apply these settings? Some settings may require restarting the app to take effect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SettingsBloc>().add(ApplySettingsEvent(settings));
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _confirmResetSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
            'Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SettingsBloc>().add(ResetSettingsEvent());
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings Demo'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This demo allows you to configure the cache behavior.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Features demonstrated:'),
              SizedBox(height: 8),
              Text('• Configure cache policies'),
              Text('• Set expiry times'),
              Text('• Enable/disable compression'),
              Text('• Configure eviction strategies'),
              Text('• View cache metrics'),
              Text('• Clear cache'),
              Text('• Reset metrics'),
              SizedBox(height: 16),
              Text(
                  'Note: Some settings may require restarting the app to take full effect.'),
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
