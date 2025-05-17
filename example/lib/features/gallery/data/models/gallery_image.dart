class GalleryImage {
  final String id;
  final String url;
  final String title;
  final String description;
  final DateTime uploadDate;
  final int size; // in bytes
  final int width;
  final int height;
  final bool isFavorite;
  final Set<String> tags;

  GalleryImage({
    required this.id,
    required this.url,
    required this.title,
    required this.description,
    required this.uploadDate,
    required this.size,
    required this.width,
    required this.height,
    this.isFavorite = false,
    this.tags = const {},
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    // Handle tags from JSON
    Set<String> tags = {};
    if (json['tags'] != null) {
      tags = Set<String>.from(json['tags']);
    }

    return GalleryImage(
      id: json['id'],
      url: json['url'],
      title: json['title'],
      description: json['description'],
      uploadDate: DateTime.parse(json['uploadDate']),
      size: json['size'],
      width: json['width'],
      height: json['height'],
      isFavorite: json['isFavorite'] ?? false,
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'description': description,
      'uploadDate': uploadDate.toIso8601String(),
      'size': size,
      'width': width,
      'height': height,
      'isFavorite': isFavorite,
      'tags': tags.toList(),
    };
  }

  GalleryImage copyWith({
    String? id,
    String? url,
    String? title,
    String? description,
    DateTime? uploadDate,
    int? size,
    int? width,
    int? height,
    bool? isFavorite,
    Set<String>? tags,
  }) {
    return GalleryImage(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      uploadDate: uploadDate ?? this.uploadDate,
      size: size ?? this.size,
      width: width ?? this.width,
      height: height ?? this.height,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }
}
