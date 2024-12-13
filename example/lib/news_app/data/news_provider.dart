import 'package:example/models/news_article.dart';

class NewsProvider {
  Future<List<NewsArticle>> fetchNews() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Hardcoded list of news articles
    final List<NewsArticle> articles = [
      const NewsArticle(
        title: "DataCacheX: A New Era of Data Caching",
        description:
            "Developers are excited about the new DataCacheX library, which promises to revolutionize data caching in Flutter applications.",
        url: "https://example.com/news1",
        urlToImage: "https://example.com/image1.jpg",
      ),
      const NewsArticle(
        title: "Flutter Forward: What's Next for Flutter Development",
        description:
            "The Flutter Forward event showcased the latest advancements in Flutter, including improved performance and new features for building beautiful UIs.",
        url: "https://example.com/news2",
        urlToImage: "https://example.com/image2.jpg",
      ),
      const NewsArticle(
        title: "Dart 3: A Look at the Latest Features",
        description:
            "Dart 3 introduces a host of new features, including enhanced type safety and improved performance, making it even easier to build robust applications.",
        url: "https://example.com/news3",
        urlToImage: "https://example.com/image3.jpg",
      ),
    ];

    return articles;
  }
}
