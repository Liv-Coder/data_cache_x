import 'dart:convert';

import 'package:data_cache_x/data_cache_x.dart';
import 'package:faker/faker.dart';
import 'package:get_it/get_it.dart';

import '../models/article.dart';

class NewsRepository {
  final DataCacheX _cache;

  // Cache keys
  static const String _headlinesKey = 'headlines';
  static const String _techNewsKey = 'tech_news';
  static const String _businessNewsKey = 'business_news';

  // Cache policies
  static const CachePolicy _standardPolicy = CachePolicy(
    expiry: Duration(minutes: 15),
    staleTime: Duration(minutes: 5),
    refreshStrategy: RefreshStrategy.backgroundRefresh,
    priority: CachePriority.normal,
  );

  static const CachePolicy _longTermPolicy = CachePolicy(
    expiry: Duration(hours: 2),
    slidingExpiry: Duration(minutes: 30),
    priority: CachePriority.low,
  );

  static const CachePolicy _criticalPolicy = CachePolicy(
    expiry: Duration(minutes: 30),
    priority: CachePriority.critical,
    compression: CompressionMode.always,
  );

  NewsRepository({
    DataCacheX? cache,
  }) : _cache = cache ?? GetIt.I<DataCacheX>();

  /// Fetches headlines with a standard cache policy (15 min expiry, stale-while-revalidate)
  Future<List<Article>> getHeadlines() async {
    return _getArticles(_headlinesKey, _standardPolicy);
  }

  /// Fetches tech news with a long-term cache policy (2 hour expiry, sliding window)
  Future<List<Article>> getTechNews() async {
    return _getArticles(_techNewsKey, _longTermPolicy);
  }

  /// Fetches business news with a critical cache policy (30 min expiry, compression)
  Future<List<Article>> getBusinessNews() async {
    return _getArticles(_businessNewsKey, _criticalPolicy);
  }

  /// Generic method to fetch articles with a specific cache policy
  Future<List<Article>> _getArticles(String key, CachePolicy policy) async {
    try {
      // Try to get from cache first
      final cachedData = await _cache.get<String>(key);

      if (cachedData != null) {
        final List<dynamic> articlesJson = jsonDecode(cachedData);
        return articlesJson.map((json) => Article.fromJson(json)).toList();
      }

      // If not in cache, fetch from API
      final articles = await _fetchArticlesFromApi();

      // Store in cache with the specified policy
      final articlesJson = jsonEncode(articles.map((a) => a.toJson()).toList());
      await _cache.put<String>(key, articlesJson, policy: policy);

      return articles;
    } catch (e) {
      // If there's an error, return empty list
      return [];
    }
  }

  /// Simulates fetching articles from an API
  /// In a real app, this would make an actual API call
  Future<List<Article>> _fetchArticlesFromApi() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate fake articles
    final faker = Faker();
    final articles = List.generate(
      20,
      (index) => Article(
        id: faker.guid.guid(),
        title: faker.lorem.sentence(),
        description: faker.lorem.sentences(2).join(' '),
        content: faker.lorem.sentences(5).join(' '),
        author: faker.person.name(),
        publishedAt: DateTime.now()
            .subtract(Duration(hours: faker.randomGenerator.integer(48)))
            .toIso8601String(),
        url: 'https://example.com/article/${faker.guid.guid()}',
        imageUrl:
            'https://picsum.photos/seed/${faker.randomGenerator.integer(1000)}/800/600',
        source: faker.company.name(),
      ),
    );

    return articles;
  }

  /// Clears all news caches
  Future<void> clearCache() async {
    await _cache.delete(_headlinesKey);
    await _cache.delete(_techNewsKey);
    await _cache.delete(_businessNewsKey);
  }
}
