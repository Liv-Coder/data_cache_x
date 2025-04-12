import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ionicons/ionicons.dart';

import '../../data/repositories/news_repository.dart';
import '../bloc/news_bloc.dart';
import '../widgets/article_card.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewsBloc(
        newsRepository: NewsRepository(),
      )..add(FetchHeadlinesEvent()),
      child: const _NewsPageContent(),
    );
  }
}

class _NewsPageContent extends StatelessWidget {
  const _NewsPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Feed'),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.trash_outline),
            onPressed: () {
              context.read<NewsBloc>().add(ClearCacheEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Clear Cache',
          ),
          IconButton(
            icon: const Icon(Ionicons.information_circle_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Info',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryTabs(context),
          Expanded(
            child: BlocBuilder<NewsBloc, NewsState>(
              builder: (context, state) {
                if (state is NewsInitial) {
                  return const Center(
                    child: Text('Select a category to load news'),
                  );
                } else if (state is NewsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is NewsLoaded) {
                  return _buildNewsList(context, state);
                } else if (state is NewsError) {
                  return Center(
                    child: Text(state.message),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _CategoryTab(
            title: 'Headlines',
            icon: Ionicons.newspaper_outline,
            onTap: () => context.read<NewsBloc>().add(FetchHeadlinesEvent()),
          ),
          _CategoryTab(
            title: 'Technology',
            icon: Ionicons.hardware_chip_outline,
            onTap: () => context.read<NewsBloc>().add(FetchTechNewsEvent()),
          ),
          _CategoryTab(
            title: 'Business',
            icon: Ionicons.briefcase_outline,
            onTap: () => context.read<NewsBloc>().add(FetchBusinessNewsEvent()),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, NewsLoaded state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                state.category,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Cache Policy: ${state.cachePolicy}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.articles.isEmpty
              ? const Center(
                  child: Text('No articles found'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.articles.length,
                  itemBuilder: (context, index) {
                    return ArticleCard(article: state.articles[index]);
                  },
                ),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('News Feed Cache Demo'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This demo showcases different caching policies for API responses:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                  '• Headlines: Standard policy (15 min expiry, stale-while-revalidate)'),
              Text(
                  '• Technology: Long-term policy (2 hour expiry, sliding window)'),
              Text('• Business: Critical policy (30 min expiry, compression)'),
              SizedBox(height: 16),
              Text(
                'The first load fetches data from the "API" (simulated), while subsequent loads within the cache lifetime will be instant.',
              ),
              SizedBox(height: 8),
              Text(
                'Try switching between categories and observe the loading behavior. Use the trash icon to clear the cache.',
              ),
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

class _CategoryTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
