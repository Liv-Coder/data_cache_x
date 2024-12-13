import 'package:data_cache_x/core/data_cache_x.dart';
import 'package:example/models/news_article.dart';
import 'package:example/news_app/data/news_provider.dart';

class NewsRepository {
  final NewsProvider _newsProvider;
  final DataCacheX _dataCache;

  NewsRepository(this._newsProvider, this._dataCache);

  Future<List<NewsArticle>> getNews() async {
    // Try to get data from cache first
    final cachedData = await _dataCache.get('news');

    if (cachedData != null) {
      final List<NewsArticle> articles = (cachedData as List)
          .map((e) => NewsArticle.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return articles;
    }

    // If not in cache, fetch from provider
    final articles = await _newsProvider.fetchNews();

    // Cache the data
    await _dataCache.put(
      'news',
      articles.map((e) => e.toJson()).toList(),
    );

    return articles;
  }
}
