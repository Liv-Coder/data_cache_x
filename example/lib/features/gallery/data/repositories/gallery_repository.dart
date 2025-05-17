import 'dart:convert';
import 'dart:math';

import 'package:data_cache_x/data_cache_x.dart';
import 'package:get_it/get_it.dart';

import '../models/gallery_image.dart';

class GalleryRepository {
  final DataCacheX _cache;

  // Cache keys
  static const String _imagesKey = 'gallery_images';

  // Cache policies
  static const CachePolicy _standardPolicy = CachePolicy(
    expiry: Duration(days: 1),
    priority: CachePriority.normal,
    compression: CompressionMode.auto,
  );

  static const CachePolicy _compressedPolicy = CachePolicy(
    expiry: Duration(days: 7),
    priority: CachePriority.normal,
    compression: CompressionMode.always,
    compressionLevel: 9,
  );

  static const CachePolicy _highPriorityPolicy = CachePolicy(
    expiry: Duration(days: 30),
    priority: CachePriority.high,
    compression: CompressionMode.auto,
  );

  GalleryRepository({DataCacheX? cache})
      : _cache = cache ?? GetIt.I<DataCacheX>();

  /// Fetches all images from the cache
  Future<List<GalleryImage>> getImages() async {
    try {
      // Try to get from cache first
      final cachedData = await _cache.get<String>(_imagesKey);

      if (cachedData != null) {
        final List<dynamic> imagesJson = jsonDecode(cachedData);
        return imagesJson.map((json) => GalleryImage.fromJson(json)).toList();
      }

      // If not in cache, return empty list
      return [];
    } catch (e) {
      // If there's an error, return empty list
      return [];
    }
  }

  /// Adds a new image to the gallery
  Future<void> addImage(GalleryImage image) async {
    try {
      // Get existing images
      final images = await getImages();

      // Add new image
      images.add(image);

      // Save to cache
      final imagesJson = jsonEncode(images.map((img) => img.toJson()).toList());

      // Choose policy based on image properties
      CachePolicy policy;
      if (image.size > 500 * 1024) {
        // Larger than 500KB
        policy = _compressedPolicy;
      } else if (image.isFavorite) {
        policy = _highPriorityPolicy;
      } else {
        policy = _standardPolicy;
      }

      await _cache.put<String>(_imagesKey, imagesJson, policy: policy);
    } catch (e) {
      rethrow;
    }
  }

  /// Toggles the favorite status of an image
  Future<void> toggleFavorite(String id) async {
    try {
      // Get existing images
      final images = await getImages();

      // Find and update the image
      final index = images.indexWhere((img) => img.id == id);
      if (index != -1) {
        images[index] = images[index].copyWith(
          isFavorite: !images[index].isFavorite,
        );

        // Save to cache
        final imagesJson =
            jsonEncode(images.map((img) => img.toJson()).toList());
        await _cache.put<String>(_imagesKey, imagesJson);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes an image from the gallery
  Future<void> deleteImage(String id) async {
    try {
      // Get existing images
      final images = await getImages();

      // Remove the image
      images.removeWhere((img) => img.id == id);

      // Save to cache
      final imagesJson = jsonEncode(images.map((img) => img.toJson()).toList());
      await _cache.put<String>(_imagesKey, imagesJson);
    } catch (e) {
      rethrow;
    }
  }

  /// Clears all images from the gallery
  Future<void> clearGallery() async {
    try {
      await _cache.delete(_imagesKey);
    } catch (e) {
      rethrow;
    }
  }

  /// Gets all available tags from the gallery images
  Future<Set<String>> getAllTags() async {
    try {
      final images = await getImages();
      final allTags = <String>{};

      for (final image in images) {
        allTags.addAll(image.tags);
      }

      return allTags;
    } catch (e) {
      return {};
    }
  }

  /// Gets images by tag
  Future<List<GalleryImage>> getImagesByTag(String tag) async {
    try {
      final images = await getImages();
      return images.where((image) => image.tags.contains(tag)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Adds a tag to an image
  Future<void> addTagToImage(String imageId, String tag) async {
    try {
      final images = await getImages();
      final index = images.indexWhere((img) => img.id == imageId);

      if (index != -1) {
        final updatedTags = {...images[index].tags, tag};
        images[index] = images[index].copyWith(tags: updatedTags);

        // Save to cache
        final imagesJson =
            jsonEncode(images.map((img) => img.toJson()).toList());
        await _cache.put<String>(_imagesKey, imagesJson);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Removes a tag from an image
  Future<void> removeTagFromImage(String imageId, String tag) async {
    try {
      final images = await getImages();
      final index = images.indexWhere((img) => img.id == imageId);

      if (index != -1) {
        final updatedTags = {...images[index].tags}..remove(tag);
        images[index] = images[index].copyWith(tags: updatedTags);

        // Save to cache
        final imagesJson =
            jsonEncode(images.map((img) => img.toJson()).toList());
        await _cache.put<String>(_imagesKey, imagesJson);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Generates sample images for testing
  Future<void> generateSampleImages(int count) async {
    try {
      final random = Random();
      final images = <GalleryImage>[];

      // Sample tags for images
      final sampleTags = [
        'nature',
        'landscape',
        'portrait',
        'architecture',
        'abstract',
        'animals',
        'food',
        'travel',
        'people',
        'urban',
        'macro',
        'night',
        'vintage',
        'black_and_white',
        'underwater'
      ];

      for (int i = 0; i < count; i++) {
        const width = 800;
        const height = 600;
        final id =
            DateTime.now().millisecondsSinceEpoch.toString() + i.toString();

        // Generate 1-3 random tags for each image
        final imageTags = <String>{};
        final tagCount = random.nextInt(3) + 1; // 1 to 3 tags
        for (int t = 0; t < tagCount; t++) {
          imageTags.add(sampleTags[random.nextInt(sampleTags.length)]);
        }

        // Add size-based tag
        final size = random.nextInt(1000) * 1024; // Random size up to ~1MB
        if (size < 200 * 1024) {
          imageTags.add('small');
        } else if (size > 500 * 1024) {
          imageTags.add('large');
        }

        images.add(
          GalleryImage(
            id: id,
            url: 'https://picsum.photos/seed/${random.nextInt(1000)}/800/600',
            title: 'Sample Image $i',
            description:
                'This is a sample image for testing the gallery feature',
            uploadDate:
                DateTime.now().subtract(Duration(days: random.nextInt(30))),
            size: size,
            width: width,
            height: height,
            isFavorite: random.nextBool(),
            tags: imageTags,
          ),
        );
      }

      // Save to cache
      final imagesJson = jsonEncode(images.map((img) => img.toJson()).toList());
      await _cache.put<String>(_imagesKey, imagesJson, policy: _standardPolicy);
    } catch (e) {
      rethrow;
    }
  }
}
