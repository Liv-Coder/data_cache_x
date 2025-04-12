class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String author;
  final String publishedAt;
  final String url;
  final String imageUrl;
  final String source;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.publishedAt,
    required this.url,
    required this.imageUrl,
    required this.source,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? 'Unknown',
      publishedAt: json['publishedAt'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      source: json['source']?['name'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'publishedAt': publishedAt,
      'url': url,
      'urlToImage': imageUrl,
      'source': {'name': source},
    };
  }
}
