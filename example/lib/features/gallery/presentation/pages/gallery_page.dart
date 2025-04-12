import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../data/repositories/gallery_repository.dart';
import '../bloc/gallery_bloc.dart';
import '../widgets/image_card.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GalleryBloc(
        galleryRepository: GalleryRepository(),
      )..add(LoadGalleryEvent()),
      child: const _GalleryPageContent(),
    );
  }
}

class _GalleryPageContent extends StatelessWidget {
  const _GalleryPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.refresh_outline),
            onPressed: () =>
                context.read<GalleryBloc>().add(LoadGalleryEvent()),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Ionicons.trash_outline),
            onPressed: () => _confirmClearGallery(context),
            tooltip: 'Clear Gallery',
          ),
          IconButton(
            icon: const Icon(Ionicons.information_circle_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Info',
          ),
        ],
      ),
      body: BlocBuilder<GalleryBloc, GalleryState>(
        builder: (context, state) {
          if (state is GalleryInitial) {
            return const Center(
              child: Text('No images available'),
            );
          } else if (state is GalleryLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is GalleryLoaded) {
            return _buildGalleryContent(context, state);
          } else if (state is GalleryError) {
            return Center(
              child: Text(state.message),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.read<GalleryBloc>().add(const GenerateSampleImagesEvent()),
        tooltip: 'Generate Sample Images',
        child: const Icon(Ionicons.add_outline),
      ),
    );
  }

  Widget _buildGalleryContent(BuildContext context, GalleryLoaded state) {
    if (state.images.isEmpty) {
      return const Center(
        child: Text('No images in the gallery'),
      );
    }

    return Column(
      children: [
        _buildGalleryHeader(context, state),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.images.length,
            itemBuilder: (context, index) {
              final image = state.images[index];
              return ImageCard(
                image: image,
                onFavoriteToggle: () => context
                    .read<GalleryBloc>()
                    .add(ToggleFavoriteEvent(image.id)),
                onDelete: () => _confirmDeleteImage(context, image.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryHeader(BuildContext context, GalleryLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.imageCount} Images',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Size: ${_formatBytes(state.totalSize)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Ionicons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  '${state.images.where((img) => img.isFavorite).length} Favorites',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  void _confirmDeleteImage(BuildContext context, String imageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<GalleryBloc>().add(DeleteImageEvent(imageId));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmClearGallery(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Gallery'),
        content:
            const Text('Are you sure you want to clear the entire gallery?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<GalleryBloc>().add(ClearGalleryEvent());
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Gallery Demo'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This demo showcases caching of binary data (images) with different caching strategies.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Features demonstrated:'),
              SizedBox(height: 8),
              Text('• Caching images with different policies'),
              Text('• Compression of image data based on size'),
              Text('• Priority-based caching for favorites'),
              Text('• Offline image viewing'),
              SizedBox(height: 16),
              Text(
                  'Use the floating action button to generate sample images for testing.'),
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
