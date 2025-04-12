import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../data/models/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // In a real app, this would navigate to the article detail page
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        article.source,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(article.publishedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.8),
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          article.author.isNotEmpty
                              ? article.author[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          article.author,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // In a real app, this would navigate to the article detail page
                        },
                        child: const Text('Read More'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: 100.ms)
      .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat.yMMMd().format(date);
    } catch (e) {
      return '';
    }
  }
}
