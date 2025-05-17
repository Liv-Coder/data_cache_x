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
  final Set<String> tags;

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
    this.tags = const {},
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    // Handle tags from JSON
    Set<String> tags = {};
    if (json['tags'] != null) {
      tags = Set<String>.from(json['tags']);
    }

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
      tags: tags,
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
      'tags': tags.toList(),
    };
  }
}
